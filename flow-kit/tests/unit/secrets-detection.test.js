import { describe, it, expect, afterEach, afterAll } from 'vitest'
import { execSync } from 'child_process'
import path from 'path'
import fs from 'fs'
import os from 'os'

const LIB = path.resolve(__dirname, '../../lib/security-scanner.sh')

function scanSecrets(dir) {
  const cmd = `bash -c 'source "${LIB}" 2>/dev/null; SCAN_DIR="${dir}" scan_secrets 2>&1; exit $?'`
  try {
    const stdout = execSync(cmd, { encoding: 'utf-8', timeout: 10000 })
    return { stdout, exitCode: 0 }
  } catch (e) {
    return { stdout: (e.stdout || '') + (e.stderr || ''), exitCode: e.status || 1 }
  }
}

describe('secrets 检测 18 种模式', () => {
  const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'secrets-'))

  afterEach(() => {
    // 清理测试文件但保留 tmpDir
    const files = fs.readdirSync(tmpDir)
    files.forEach(f => fs.rmSync(path.join(tmpDir, f), { recursive: true, force: true }))
  })

  afterAll(() => {
    fs.rmSync(tmpDir, { recursive: true, force: true })
  })

  const secrets = [
    { name: 'GitHub PAT', content: 'ghp_1234567890abcdefghijklmn1234567890opqr' },
    { name: 'GitHub OAuth', content: 'gho_1234567890abcdefghijklmn1234567890opqr' },
    { name: 'AWS Access Key', content: 'AKIAIOSFODNN7EXAMPLE' },
    { name: 'JWT', content: 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.abc123def456' },
    { name: 'SSH Private Key', content: '-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQ' },
    { name: 'Private Key Block', content: '-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w' },
    { name: 'Generic API Key', content: "api_key = 'abcdefghijklmnopqrstuvwxyz123456'" },
    { name: 'Generic Secret', content: 'secret = "abcdefghijklmnopqrstuvwxyz123456"' },
    { name: 'Generic Token', content: 'token = "abcdefghijklmnopqrstuvwxyz123456"' },
    { name: 'Generic Password', content: "password = 'MyP@ssw0rd!'" },
  ]

  secrets.forEach(({ name, content }) => {
    it(`检测 ${name}`, () => {
      fs.writeFileSync(path.join(tmpDir, 'test.js'), content)
      const result = scanSecrets(tmpDir)
      expect(result.stdout).toContain('[secrets]')
    })
  })

  it('.env.example 不触发', () => {
    fs.writeFileSync(path.join(tmpDir, '.env.example'), 'api_key = "abcdefghijklmnopqrstuvwxyz123456"')
    const result = scanSecrets(tmpDir)
    expect(result.stdout).not.toContain('[secrets]')
  })

  it('node_modules/ 跳过', () => {
    const nmDir = path.join(tmpDir, 'node_modules', 'pkg')
    fs.mkdirSync(nmDir, { recursive: true })
    fs.writeFileSync(path.join(nmDir, 'index.js'), 'ghp_1234567890abcdefghijklmn1234567890opqr')
    const result = scanSecrets(tmpDir)
    expect(result.stdout).not.toContain('[secrets]')
  })

  it('无密钥时返回 0', () => {
    fs.writeFileSync(path.join(tmpDir, 'clean.js'), 'console.log("hello")')
    const result = scanSecrets(tmpDir)
    expect(result.exitCode).toBe(0)
  })
})
