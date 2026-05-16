import { describe, it, expect, beforeEach, afterAll } from 'vitest'
import { execSync } from 'child_process'
import path from 'path'
import fs from 'fs'
import os from 'os'

const AUTO_PILOT = path.resolve(__dirname, '../../scripts/auto-pilot.sh')
const PRD_PARSER = path.resolve(__dirname, '../../scripts/prd-parser.sh')
const SECURITY = path.resolve(__dirname, '../../lib/security-scanner.sh')
const FRONT_MATTER = path.resolve(__dirname, '../../lib/front-matter.sh')
const PHASES = path.resolve(__dirname, '../../phases')

function exec(cmd, env = {}) {
  const envStr = Object.entries(env).map(([k, v]) => `${k}="${v}"`).join(' ')
  try {
    return { stdout: execSync(`${envStr} ${cmd} 2>&1`, { encoding: 'utf-8', timeout: 15000 }), exitCode: 0 }
  } catch (e) {
    return { stdout: (e.stdout || '') + (e.stderr || ''), exitCode: e.status || 1 }
  }
}

describe('端到端：front matter → auto-pilot → validate → evidence', () => {
  const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'full-pipe-'))
  const flowKitDir = path.join(tmpDir, '.flow-kit')
  const env = { CLAUDE_PROJECT_DIR: tmpDir }

  beforeEach(() => { fs.mkdirSync(flowKitDir, { recursive: true }) })
  afterAll(() => { fs.rmSync(tmpDir, { recursive: true, force: true }) })

  it('完整流程：初始化 → 执行 → 验证 → 推进', () => {
    // Phase 0: 初始化
    fs.writeFileSync(path.join(flowKitDir, 'session-state.json'), JSON.stringify({ phase: '0-change' }))
    exec(`bash "${AUTO_PILOT}"`, env)
    const plan = JSON.parse(fs.readFileSync(path.join(flowKitDir, 'auto-plan.json'), 'utf-8'))
    expect(plan.current_phase).toBe(0)

    // 创建产出物
    fs.writeFileSync(path.join(flowKitDir, 'change-proposal.md'), '# 变更提案')

    // 再次运行验证
    const r1 = exec(`bash "${AUTO_PILOT}"`, env)
    expect(r1.stdout).toContain('推荐')

    // 推进到 Phase 1
    exec(`bash "${AUTO_PILOT}" --next`, env)
    const plan2 = JSON.parse(fs.readFileSync(path.join(flowKitDir, 'auto-plan.json'), 'utf-8'))
    expect(plan2.current_phase).toBe(1)
    const session = JSON.parse(fs.readFileSync(path.join(flowKitDir, 'session-state.json'), 'utf-8'))
    expect(session.phase).toContain('1-')
  })

  it('front matter 解析 → 阶段信息提取', () => {
    const result = exec(`bash -c 'source "${FRONT_MATTER}" && parse_front_matter "${PHASES}/4-dev/brownfield.md"'`)
    const json = JSON.parse(result.stdout)
    expect(json.phase).toBe(4)
    expect(json.stage).toBe('execution')
    expect(json.allowed_operations).toBeInstanceOf(Array)
  })

  it('prd-parser 输出 JSON 可被 jq 消费', () => {
    const mdFile = path.join(tmpDir, 'test.md')
    fs.writeFileSync(mdFile, '# Test PRD\n## Section\n- item1\n- item2')
    const r = exec(`bash "${PRD_PARSER}" "${mdFile}"`)
    expect(r.exitCode).toBe(0)
    const json = JSON.parse(r.stdout)
    expect(json.format).toBe('markdown')
    expect(json.structure.headings.length).toBeGreaterThan(0)
  })

  it('secrets 检测在 pre-commit 场景', () => {
    const srcDir = path.join(tmpDir, 'src')
    fs.mkdirSync(srcDir, { recursive: true })
    fs.writeFileSync(path.join(srcDir, 'config.js'), 'const key = "ghp_1234567890abcdefghijklmn1234567890opqr";')
    const r = exec(`bash -c 'source "${SECURITY}" && SCAN_DIR="${tmpDir}" scan_secrets 2>&1'`)
    expect(r.stdout).toContain('[secrets]')
  })
})
