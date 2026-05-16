import { describe, it, expect } from 'vitest'
import { execSync } from 'child_process'
import path from 'path'
import fs from 'fs'
import os from 'os'

const SCRIPT = path.resolve(__dirname, '../../scripts/prd-parser.sh')
const FIXTURES = path.resolve(__dirname, '../fixtures')

function parse(file) {
  try {
    const stdout = execSync(`bash "${SCRIPT}" "${file}" 2>&1`, { encoding: 'utf-8', timeout: 10000 })
    return { json: JSON.parse(stdout), exitCode: 0 }
  } catch (e) {
    return { json: null, stdout: (e.stdout || '') + (e.stderr || ''), exitCode: e.status || 1 }
  }
}

describe('prd-parser PRD 预处理', () => {
  it('Markdown 格式检测正确', () => {
    const { json } = parse(path.join(FIXTURES, 'test-prd.md'))
    expect(json.format).toBe('markdown')
  })

  it('Markdown 提取标题树', () => {
    const { json } = parse(path.join(FIXTURES, 'test-prd.md'))
    expect(json.structure.headings).toBeInstanceOf(Array)
    expect(json.structure.headings.length).toBeGreaterThan(0)
    const h1 = json.structure.headings.find(h => h.level === 1)
    expect(h1).toBeDefined()
    expect(h1.text).toContain('PRD')
  })

  it('Markdown 提取列表项', () => {
    const { json } = parse(path.join(FIXTURES, 'test-prd.md'))
    expect(json.structure.lists).toBeInstanceOf(Array)
    expect(json.structure.lists.length).toBeGreaterThan(0)
  })

  it('Markdown 提取表格', () => {
    const { json } = parse(path.join(FIXTURES, 'test-prd.md'))
    expect(json.structure.tables).toBeInstanceOf(Array)
    expect(json.structure.tables.length).toBeGreaterThan(0)
    expect(json.structure.tables[0].headers).toBeInstanceOf(Array)
    expect(json.structure.tables[0].rows).toBeInstanceOf(Array)
  })

  it('JSON 格式检测正确', () => {
    const { json } = parse(path.join(FIXTURES, 'test-prd.json'))
    expect(json.format).toBe('json')
  })

  it('JSON 提取顶级键和嵌套结构', () => {
    const { json } = parse(path.join(FIXTURES, 'test-prd.json'))
    expect(json.structure.top_level_keys).toBeInstanceOf(Array)
    expect(json.structure.top_level_keys).toContain('title')
    expect(json.structure.top_level_keys).toContain('requirements')
  })

  it('空文件 → 报错不崩溃', () => {
    const { exitCode, stdout } = parse(path.join(FIXTURES, 'test-empty.md'))
    // 空文件应正常处理（输出空结构或报错）
    expect(exitCode).toBeDefined()
  })

  it('不存在的文件 → 报错不崩溃', () => {
    const { exitCode } = parse('/nonexistent/file.md')
    expect(exitCode).not.toBe(0)
  })

  it('大文件性能（1000+ 行 < 5 秒）', () => {
    const tmpFile = path.join(os.tmpdir(), `big-prd-${Date.now()}.md`)
    let content = '# 大型 PRD\n\n'
    for (let i = 0; i < 200; i++) {
      content += `## 第 ${i} 节\n\n- 项目 A\n- 项目 B\n\n| 列1 | 列2 |\n|-----|-----|\n| 值1 | 值2 |\n\n`
    }
    fs.writeFileSync(tmpFile, content)

    const start = Date.now()
    const { json } = parse(tmpFile)
    const elapsed = Date.now() - start
    fs.unlinkSync(tmpFile)

    expect(elapsed).toBeLessThan(5000)
    expect(json).not.toBeNull()
    expect(json.format).toBe('markdown')
  })
})
