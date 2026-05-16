import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { execSync } from 'child_process'
import path from 'path'
import fs from 'fs'
import os from 'os'

const SCRIPT = path.resolve(__dirname, '../../scripts/auto-pilot.sh')

function runAutoPilot(args = '', env = {}) {
  const envStr = Object.entries(env).map(([k, v]) => `${k}="${v}"`).join(' ')
  const cmd = `${envStr} bash "${SCRIPT}" ${args} 2>&1`
  try {
    const stdout = execSync(cmd, { encoding: 'utf-8', timeout: 10000 })
    return { stdout, exitCode: 0 }
  } catch (e) {
    return { stdout: (e.stdout || '') + (e.stderr || ''), exitCode: e.status || 1 }
  }
}

describe('auto-pilot 状态机', () => {
  const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'autopilot-'))
  const flowKitDir = path.join(tmpDir, '.flow-kit')

  beforeEach(() => {
    fs.mkdirSync(flowKitDir, { recursive: true })
  })

  afterEach(() => {
    fs.rmSync(tmpDir, { recursive: true, force: true })
  })

  it('无 auto-plan → 生成初始 plan', () => {
    const sessionFile = path.join(flowKitDir, 'session-state.json')
    fs.writeFileSync(sessionFile, JSON.stringify({ phase: '0-change' }))

    const result = runAutoPilot('', { CLAUDE_PROJECT_DIR: tmpDir })
    const planFile = path.join(flowKitDir, 'auto-plan.json')
    expect(fs.existsSync(planFile)).toBe(true)
    const plan = JSON.parse(fs.readFileSync(planFile, 'utf-8'))
    expect(plan.current_phase).toBe(0)
    expect(plan.phases).toBeInstanceOf(Array)
  })

  it('--status 显示当前状态', () => {
    const sessionFile = path.join(flowKitDir, 'session-state.json')
    fs.writeFileSync(sessionFile, JSON.stringify({ phase: '1-requirement' }))
    const planFile = path.join(flowKitDir, 'auto-plan.json')
    fs.writeFileSync(planFile, JSON.stringify({
      description: 'test',
      current_phase: 1,
      phases: [{ id: 0, name: '变更立项', status: 'completed' }]
    }))

    const result = runAutoPilot('--status', { CLAUDE_PROJECT_DIR: tmpDir })
    expect(result.stdout).toContain('[auto-pilot]')
  })

  it('无 session-state → 报错退出', () => {
    const result = runAutoPilot('', { CLAUDE_PROJECT_DIR: tmpDir })
    expect(result.exitCode).not.toBe(0)
  })

  it('quick 深度模式跳过 Phase 0-3', () => {
    const sessionFile = path.join(flowKitDir, 'session-state.json')
    fs.writeFileSync(sessionFile, JSON.stringify({ phase: '0-change' }))

    const result = runAutoPilot('--depth quick', { CLAUDE_PROJECT_DIR: tmpDir })
    const planFile = path.join(flowKitDir, 'auto-plan.json')
    if (fs.existsSync(planFile)) {
      const plan = JSON.parse(fs.readFileSync(planFile, 'utf-8'))
      expect(plan.current_phase).toBe(4)
    }
  })

  it('--next 推进到下一 phase', () => {
    const sessionFile = path.join(flowKitDir, 'session-state.json')
    fs.writeFileSync(sessionFile, JSON.stringify({ phase: '0-change' }))
    const planFile = path.join(flowKitDir, 'auto-plan.json')
    fs.writeFileSync(planFile, JSON.stringify({
      description: 'test',
      current_phase: 0,
      phases: [{ id: 0, name: '变更立项', status: 'completed', evidence: [] }]
    }))

    const result = runAutoPilot('--next', { CLAUDE_PROJECT_DIR: tmpDir })
    const plan = JSON.parse(fs.readFileSync(planFile, 'utf-8'))
    expect(plan.current_phase).toBe(1)
  })

  it('推荐下一步但不自动推进', () => {
    const sessionFile = path.join(flowKitDir, 'session-state.json')
    fs.writeFileSync(sessionFile, JSON.stringify({ phase: '0-change' }))

    const result = runAutoPilot('', { CLAUDE_PROJECT_DIR: tmpDir })
    expect(result.stdout).toContain('推荐')
  })
})
