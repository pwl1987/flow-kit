import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { execSync } from 'child_process'
import path from 'path'
import fs from 'fs'
import os from 'os'

const LIB = path.resolve(__dirname, '../../lib/front-matter.sh')
const PHASES = path.resolve(__dirname, '../../phases')

function runArtifactCheck(projectDir) {
  const script = `
source "${LIB}"
project_dir="${projectDir}"
session_file="$project_dir/.flow-kit/session-state.json"
[[ ! -f "$session_file" ]] && exit 0
current_phase=$(jq -r '.phase // empty' "$session_file" 2>/dev/null)
[[ -z "$current_phase" ]] && exit 0
phase_file=$(find "${PHASES}" -name "*.md" -path "*$current_phase*" 2>/dev/null | head -1)
[[ -z "$phase_file" ]] && exit 0
artifacts_json=$(parse_front_matter "$phase_file" | jq -r '.expected_artifacts // []' 2>/dev/null)
count=$(echo "$artifacts_json" | jq 'length' 2>/dev/null || echo 0)
i=0
while (( i < count )); do
  artifact=$(echo "$artifacts_json" | jq -r ".[$i]" 2>/dev/null)
  if [[ -n "$artifact" && ! -f "$project_dir/$artifact" ]]; then
    echo "[quality-gate] 产出物缺失：$artifact"
  fi
  i=$((i + 1))
done
`
  try {
    return execSync(`bash -c '${script.replace(/'/g, "'\\''")}'`, { encoding: 'utf-8', timeout: 10000 })
  } catch (e) {
    return e.stdout || ''
  }
}

describe('stop-gate 产出物检查', () => {
  const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'artifact-'))
  const flowKitDir = path.join(tmpDir, '.flow-kit')

  beforeEach(() => {
    fs.mkdirSync(flowKitDir, { recursive: true })
  })

  afterEach(() => {
    fs.rmSync(tmpDir, { recursive: true, force: true })
  })

  it('所有 expected_artifacts 存在 → 无缺失警告', () => {
    fs.writeFileSync(path.join(flowKitDir, 'session-state.json'), JSON.stringify({ phase: '0-change' }))
    fs.writeFileSync(path.join(flowKitDir, 'change-proposal.md'), '# test')

    const output = runArtifactCheck(tmpDir)
    expect(output).not.toContain('产出物缺失')
  })

  it('部分缺失 → 输出缺失列表', () => {
    fs.writeFileSync(path.join(flowKitDir, 'session-state.json'), JSON.stringify({ phase: '0-change' }))

    const output = runArtifactCheck(tmpDir)
    expect(output).toContain('产出物缺失')
  })

  it('无 session-state.json → 跳过检查', () => {
    const output = runArtifactCheck(tmpDir)
    expect(output).not.toContain('产出物缺失')
  })
})
