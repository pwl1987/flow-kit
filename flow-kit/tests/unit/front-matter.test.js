import { describe, it, expect } from 'vitest'
import { execSync } from 'child_process'
import path from 'path'

const FIXTURES = path.resolve(__dirname, '../fixtures')
const LIB = path.resolve(__dirname, '../../lib/front-matter.sh')

function runShell(fn, args) {
  const cmd = `bash -c 'source "${LIB}" && ${fn} ${args}'`
  return execSync(cmd, { encoding: 'utf-8', timeout: 5000 })
}

function parseFrontMatter(file) {
  return runShell('parse_front_matter', `"${file}"`)
}

function getField(file, field) {
  return runShell('get_front_matter_field', `"${file}" "${field}"`).trim()
}

describe('front-matter 解析器', () => {
  const withFm = path.join(FIXTURES, 'phase-with-fm.md')
  const noFm = path.join(FIXTURES, 'phase-no-fm.md')
  const brokenFm = path.join(FIXTURES, 'phase-broken-fm.md')

  it('解析含 front matter 文件的所有字段', () => {
    const json = JSON.parse(parseFrontMatter(withFm))
    expect(json.phase).toBe(1)
    expect(json.name).toBe('研究与规划')
    expect(json.stage).toBe('research')
    expect(json.next_phase).toBe(2)
  })

  it('数组字段解析为 JSON array', () => {
    const json = JSON.parse(parseFrontMatter(withFm))
    expect(json.allowed_operations).toEqual(['read', 'search', 'web'])
    expect(json.forbidden_operations).toEqual(['write', 'edit'])
    expect(json.expected_artifacts).toEqual(['RESEARCH.md', 'PLAN.md'])
  })

  it('无 front matter 返回 {"phase":-1}', () => {
    const json = JSON.parse(parseFrontMatter(noFm))
    expect(json).toEqual({ phase: -1 })
  })

  it('格式错误文件不崩溃', () => {
    const json = JSON.parse(parseFrontMatter(brokenFm))
    expect(json.phase).toBe(1)
  })

  it('get_front_matter_field 提取单个字段', () => {
    expect(getField(withFm, 'phase')).toBe('1')
    expect(getField(withFm, 'name')).toBe('研究与规划')
    expect(getField(withFm, 'stage')).toBe('research')
  })

  it('get_front_matter_field 无 front matter 返回空', () => {
    expect(getField(noFm, 'phase')).toBe('-1')
  })

  it('19 个文件全部解析 < 1 秒', () => {
    const files = Array.from({ length: 19 }, () => withFm)
    const start = Date.now()
    files.forEach(f => parseFrontMatter(f))
    const elapsed = Date.now() - start
    expect(elapsed).toBeLessThan(1000)
  })
})
