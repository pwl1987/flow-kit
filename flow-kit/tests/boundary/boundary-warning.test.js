import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { execSync } from 'child_process'
import path from 'path'
import fs from 'fs'
import os from 'os'

const HOOK = path.resolve(__dirname, '../../hooks/post-edit-format.sh')

function runHook(toolName, filePath, env = {}) {
  const input = JSON.stringify({ tool_name: toolName, tool_input: { file_path: filePath } })
  const envStr = Object.entries(env).map(([k, v]) => `${k}="${v}"`).join(' ')
  try {
    const result = execSync(`echo '${input}' | ${envStr} bash "${HOOK}" 2>&1`, {
      encoding: 'utf-8',
      timeout: 10000
    })
    return { stdout: result, exitCode: 0 }
  } catch (e) {
    return { stdout: e.stdout || '', stderr: e.stderr || '', exitCode: e.status }
  }
}

describe('post-edit 边界警告', () => {
  const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'boundary-'))
  const flowKitDir = path.join(tmpDir, '.flow-kit')

  beforeEach(() => {
    fs.mkdirSync(flowKitDir, { recursive: true })
  })

  afterEach(() => {
    fs.rmSync(tmpDir, { recursive: true, force: true })
  })

  it('thinking phase 编辑 .flow-kit/ 文件 → 无警告', () => {
    const sessionFile = path.join(flowKitDir, 'session-state.json')
    fs.writeFileSync(sessionFile, JSON.stringify({ phase: '0-change' }))
    const editFile = path.join(flowKitDir, 'test.md')
    fs.writeFileSync(editFile, '# test')

    const result = runHook('Edit', editFile, {
      CLAUDE_PROJECT_DIR: tmpDir
    })
    expect(result.stdout).not.toContain('[boundary]')
  })

  it('thinking phase 编辑 src/ 文件 → 输出边界警告', () => {
    const sessionFile = path.join(flowKitDir, 'session-state.json')
    fs.writeFileSync(sessionFile, JSON.stringify({ phase: '0-change' }))
    const srcDir = path.join(tmpDir, 'src')
    fs.mkdirSync(srcDir, { recursive: true })
    const editFile = path.join(srcDir, 'index.ts')
    fs.writeFileSync(editFile, 'console.log(1)')

    const result = runHook('Edit', editFile, {
      CLAUDE_PROJECT_DIR: tmpDir
    })
    expect(result.stdout).toContain('[boundary]')
  })

  it('execution phase 编辑 src/ 文件 → 无警告', () => {
    const sessionFile = path.join(flowKitDir, 'session-state.json')
    fs.writeFileSync(sessionFile, JSON.stringify({ phase: '4-dev' }))
    const srcDir = path.join(tmpDir, 'src')
    fs.mkdirSync(srcDir, { recursive: true })
    const editFile = path.join(srcDir, 'index.ts')
    fs.writeFileSync(editFile, 'console.log(1)')

    const result = runHook('Edit', editFile, {
      CLAUDE_PROJECT_DIR: tmpDir
    })
    expect(result.stdout).not.toContain('[boundary]')
  })

  it('无 session-state.json → 静默跳过', () => {
    const srcDir = path.join(tmpDir, 'src')
    fs.mkdirSync(srcDir, { recursive: true })
    const editFile = path.join(srcDir, 'index.ts')
    fs.writeFileSync(editFile, 'console.log(1)')

    const result = runHook('Edit', editFile, {
      CLAUDE_PROJECT_DIR: tmpDir
    })
    expect(result.stdout).not.toContain('[boundary]')
  })

  it('非 Edit/Write 工具 → 不执行边界检查', () => {
    const sessionFile = path.join(flowKitDir, 'session-state.json')
    fs.writeFileSync(sessionFile, JSON.stringify({ phase: '0-change' }))
    const srcDir = path.join(tmpDir, 'src')
    fs.mkdirSync(srcDir, { recursive: true })
    const editFile = path.join(srcDir, 'index.ts')
    fs.writeFileSync(editFile, 'console.log(1)')

    const result = runHook('Read', editFile, {
      CLAUDE_PROJECT_DIR: tmpDir
    })
    expect(result.stdout).not.toContain('[boundary]')
  })
})
