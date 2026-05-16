#!/usr/bin/env bash
# front-matter.sh — YAML front matter 解析器
set -euo pipefail

parse_front_matter() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo '{"phase":-1}'
    return 0
  fi

  local first_line
  first_line=$(head -1 "$file" 2>/dev/null | tr -d '\r')

  if [[ "$first_line" != "---" ]]; then
    echo '{"phase":-1}'
    return 0
  fi

  # 用 awk 提取两个 --- 之间的 YAML 块
  local yaml
  yaml=$(awk '/^---$/{n++; next} n==1{print} n>=2{exit}' "$file")

  if [[ -z "$yaml" ]]; then
    echo '{"phase":-1}'
    return 0
  fi

  # 用 awk 转为 JSON
  echo "$yaml" | awk '
    BEGIN { sep="" }
    /^---$/ { next }
    /^[a-zA-Z_][a-zA-Z0-9_]*:[[:space:]]*$/ {
      key = $1
      sub(/:$/, "", key)
      arrays[key] = ""
      cur_array = key
      next
    }
    /^[a-zA-Z_][a-zA-Z0-9_]*:[[:space:]]+/ {
      cur_array = ""
      key = $1
      sub(/:$/, "", key)
      val = $0
      sub(/^[^:]*:[[:space:]]*/, "", val)
      gsub(/"/, "", val)
      if (val ~ /^-?[0-9]+$/) {
        printf "%s\"%s\":%s", sep, key, val
      } else {
        printf "%s\"%s\":\"%s\"", sep, key, val
      }
      sep = ","
      next
    }
    /^[[:space:]]+-[[:space:]]+/ {
      val = $0
      sub(/^[[:space:]]+-[[:space:]]+/, "", val)
      gsub(/"/, "", val)
      if (arrays[cur_array] != "") arrays[cur_array] = arrays[cur_array] ","
      arrays[cur_array] = arrays[cur_array] "\"" val "\""
      next
    }
    END {
      for (k in arrays) {
        if (arrays[k] != "") {
          printf "%s\"%s\":[%s]", sep, k, arrays[k]
          sep = ","
        }
      }
    }
  ' | tr '\n' ' ' | sed 's/ *$//' | { printf '{'; cat; printf '}\n'; }
}

get_front_matter_field() {
  local file="$1"
  local field="$2"
  local json
  json=$(parse_front_matter "$file")
  echo "$json" | jq -r ".$field // empty" 2>/dev/null || echo ""
}
