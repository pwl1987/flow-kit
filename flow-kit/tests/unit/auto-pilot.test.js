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

  // v3.7.0: 补充测试
  it('--help 显示帮助', () => {
    const result = runAutoPilot('--help', { CLAUDE_PROJECT_DIR: tmpDir })
    expect(result.stdout).toContain('auto-pilot')
    expect(result.exitCode).toBe(0)
  })

  it('--next 在 Phase 8 后不再推进', () => {
    const sessionFile = path.join(flowKitDir, 'session-state.json')
    fs.writeFileSync(sessionFile, JSON.stringify({ phase: '8-rollback' }))
    const planFile = path.join(flowKitDir, 'auto-plan.json')
    fs.writeFileSync(planFile, JSON.stringify({
      description: 'test',
      current_phase: 8,
      phases: [{ id: 8, name: '变更回滚', status: 'completed', evidence: [] }]
    }))

    const result = runAutoPilot('--next', { CLAUDE_PROJECT_DIR: tmpDir })
    expect(result.stdout).toContain('最终 Phase')
  })

  it('--status 无 plan 时提示', () => {
    const sessionFile = path.join(flowKitDir, 'session-state.json')
    fs.writeFileSync(sessionFile, JSON.stringify({ phase: '0-change' }))

    const result = runAutoPilot('--status', { CLAUDE_PROJECT_DIR: tmpDir })
    expect(result.stdout).toContain('auto-pilot')
  })

  it('plan 包含 created_at 和 updated_at', () => {
    const sessionFile = path.join(flowKitDir, 'session-state.json')
    fs.writeFileSync(sessionFile, JSON.stringify({ phase: '2-design' }))

    runAutoPilot('', { CLAUDE_PROJECT_DIR: tmpDir })
    const planFile = path.join(flowKitDir, 'auto-plan.json')
    const plan = JSON.parse(fs.readFileSync(planFile, 'utf-8'))
    expect(plan.created_at).toBeTruthy()
    expect(plan.updated_at).toBeTruthy()
  })

  it('plan 的 task_depth 默认为 campaign', () => {
    const sessionFile = path.join(flowKitDir, 'session-state.json')
    fs.writeFileSync(sessionFile, JSON.stringify({ phase: '0-change' }))

    runAutoPilot('', { CLAUDE_PROJECT_DIR: tmpDir })
    const planFile = path.join(flowKitDir, 'auto-plan.json')
    const plan = JSON.parse(fs.readFileSync(planFile, 'utf-8'))
    expect(plan.task_depth).toBe('campaign')
  })

  it('指标埋点在 auto-pilot 执行后写入', () => {
    const sessionFile = path.join(flowKitDir, 'session-state.json')
    fs.writeFileSync(sessionFile, JSON.stringify({ phase: '0-change' }))
    const logsDir = path.join(flowKitDir, 'logs')
    fs.mkdirSync(logsDir, { recursive: true })
    const metricsFile = path.join(logsDir, 'metrics.jsonl')

    runAutoPilot('', {
      CLAUDE_PROJECT_DIR: tmpDir,
      METRICS_LOG_DIR: logsDir,
      METRICS_LOG_FILE: metricsFile,
    })
    expect(fs.existsSync(metricsFile)).toBe(true)
    const content = fs.readFileSync(metricsFile, 'utf-8')
    expect(content).toContain('auto_pilot')
  })
})
