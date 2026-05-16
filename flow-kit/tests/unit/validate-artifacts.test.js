import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { execSync } from 'child_process'
import path from 'path'
import fs from 'fs'
import os from 'os'

const LIB = path.resolve(__dirname, '../../lib/front-matter.sh')
const PHASES = path.resolve(__dirname, '../../phases')

function runValidateArtifacts(projectDir, phaseStr) {
  const script = `#!/usr/bin/env bash
set -euo pipefail
source "${LIB}"
project_dir="${projectDir}"
phases_dir="${PHASES}"
phase_file=$(find "$phases_dir" -name "*.md" -path "*${phaseStr}*" 2>/dev/null | head -1)
if [[ -z "$phase_file" ]]; then
  echo "NO_PHASE_FILE"
  exit 0
fi
artifacts_json=$(parse_front_matter "$phase_file" | jq -r '.expected_artifacts // []' 2>/dev/null)
count=$(echo "$artifacts_json" | jq 'length' 2>/dev/null || echo 0)
checks='[]'
missing='[]'
i=0
all_pass=true
while (( i < count )); do
  artifact=$(echo "$artifacts_json" | jq -r ".[$i]" 2>/dev/null)
  result="fail"
  if [[ -f "$project_dir/$artifact" ]]; then
    result="pass"
  else
    all_pass=false
    missing=$(echo "$missing" | jq --arg a "$artifact" '. + [$a]')
  fi
  checks=$(echo "$checks" | jq --arg art "$artifact" --arg res "$result" '. + [{"artifact": $art, "type": "file_exists", "result": $res}]')
  i=$((i + 1))
done
verdict="pass"
if [[ "$all_pass" == "false" ]]; then
  verdict="fail"
fi
now=$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "")
jq -n --argjson phase 0 --arg ts "$now" --argjson checks "$checks" --arg verdict "$verdict" --argjson missing "$missing" \
  '{phase: $phase, timestamp: $ts, checks: $checks, verdict: $verdict, missing: $missing}'
`
  const tmpScript = path.join(os.tmpdir(), `validate-test-${Date.now()}.sh`)
  fs.writeFileSync(tmpScript, script)
  try {
    const out = execSync(`bash "${tmpScript}"`, { encoding: 'utf-8', timeout: 10000 }).trim()
    if (out === 'NO_PHASE_FILE') return 'NO_PHASE_FILE'
    return JSON.parse(out)
  } catch (e) {
    return { verdict: 'error', checks: [], missing: [], error: e.message }
  } finally {
    fs.unlinkSync(tmpScript)
  }
}

describe('validate-phase 产出物增强', () => {
  const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'validate-'))
  const flowKitDir = path.join(tmpDir, '.flow-kit')

  beforeEach(() => {
    fs.mkdirSync(flowKitDir, { recursive: true })
  })

  afterEach(() => {
    fs.rmSync(tmpDir, { recursive: true, force: true })
  })

  it('所有 artifacts 存在 → verdict=pass，missing=[]', () => {
    fs.writeFileSync(path.join(flowKitDir, 'change-proposal.md'), '# test')
    const result = runValidateArtifacts(tmpDir, '0-change')
    expect(result.verdict).toBe('pass')
    expect(result.missing).toEqual([])
  })

  it('部分缺失 → verdict=fail，missing=[缺失列表]', () => {
    const result = runValidateArtifacts(tmpDir, '0-change')
    expect(result.verdict).toBe('fail')
    expect(result.missing.length).toBeGreaterThan(0)
    expect(result.missing).toContain('.flow-kit/change-proposal.md')
  })

  it('checks 包含 file_exists 类型和结果', () => {
    fs.writeFileSync(path.join(flowKitDir, 'change-proposal.md'), '# test')
    const result = runValidateArtifacts(tmpDir, '0-change')
    expect(result.checks).toBeInstanceOf(Array)
    expect(result.checks.length).toBeGreaterThan(0)
    expect(result.checks[0]).toHaveProperty('type', 'file_exists')
    expect(result.checks[0]).toHaveProperty('result')
  })

  it('无 front matter phase 文件 → 返回 NO_PHASE_FILE', () => {
    const result = runValidateArtifacts(tmpDir, '99-nonexistent')
    expect(result).toBe('NO_PHASE_FILE')
  })
})
