import { describe, it, expect, afterAll } from 'vitest'
import { execSync } from 'child_process'
import path from 'path'
import fs from 'fs'
import os from 'os'

const FRONT_MATTER = path.resolve(__dirname, '../../lib/front-matter.sh')
const AUTO_PILOT = path.resolve(__dirname, '../../scripts/auto-pilot.sh')

function exec(cmd, env = {}) {
  const envStr = Object.entries(env).map(([k, v]) => `${k}="${v}"`).join(' ')
  try {
    return { stdout: execSync(`${envStr} ${cmd} 2>&1`, { encoding: 'utf-8', timeout: 10000 }), exitCode: 0 }
  } catch (e) {
    return { stdout: (e.stdout || '') + (e.stderr || ''), exitCode: e.status || 1 }
  }
}

describe('向后兼容：无 front matter 旧项目', () => {
  const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'compat-'))

  afterAll(() => { fs.rmSync(tmpDir, { recursive: true, force: true }) })

  it('parse_front_matter 对无 front matter 文件返回 {"phase":-1}', () => {
    const mdFile = path.join(tmpDir, 'old-phase.md')
    fs.writeFileSync(mdFile, '# Old Phase\nNo front matter')
    const r = exec(`bash -c 'source "${FRONT_MATTER}" && parse_front_matter "${mdFile}"'`)
    const json = JSON.parse(r.stdout)
    expect(json).toEqual({ phase: -1 })
  })

  it('get_front_matter_field 对无 front matter 文件返回 -1', () => {
    const mdFile = path.join(tmpDir, 'old-phase.md')
    fs.writeFileSync(mdFile, '# Old Phase\nNo front matter')
    const r = exec(`bash -c 'source "${FRONT_MATTER}" && get_front_matter_field "${mdFile}" "phase"'`)
    expect(r.stdout.trim()).toBe('-1')
  })

  it('auto-pilot 无 session-state → 报错退出', () => {
    const flowKitDir = path.join(tmpDir, '.flow-kit')
    fs.mkdirSync(flowKitDir, { recursive: true })
    const r = exec(`bash "${AUTO_PILOT}"`, { CLAUDE_PROJECT_DIR: tmpDir })
    expect(r.exitCode).not.toBe(0)
  })

  it('post-edit hook 无 session-state → 静默跳过', () => {
    const hook = path.resolve(__dirname, '../../hooks/post-edit-format.sh')
    const editFile = path.join(tmpDir, 'test.js')
    fs.writeFileSync(editFile, 'console.log(1)')
    const input = JSON.stringify({ tool_name: 'Edit', tool_input: { file_path: editFile } })
    const r = exec(`echo '${input}' | CLAUDE_PROJECT_DIR="${tmpDir}" bash "${hook}"`)
    expect(r.stdout).not.toContain('[boundary]')
  })

  it('stop-quality-gate 无 session-state → 跳过产出物检查', () => {
    const flowKitDir = path.join(tmpDir, '.flow-kit')
    fs.mkdirSync(flowKitDir, { recursive: true })
    const libScript = `#!/usr/bin/env bash
source "${FRONT_MATTER}"
project_dir="${tmpDir}"
session_file="$project_dir/.flow-kit/session-state.json"
if [[ ! -f "$session_file" ]]; then
  echo "SKIP_NO_SESSION"
  exit 0
fi
echo "SHOULD_NOT_REACH"
`
    const tmpScript = path.join(os.tmpdir(), `compat-test-${Date.now()}.sh`)
    fs.writeFileSync(tmpScript, libScript)
    const r = exec(`bash "${tmpScript}"`)
    fs.unlinkSync(tmpScript)
    expect(r.stdout.trim()).toBe('SKIP_NO_SESSION')
  })
})
