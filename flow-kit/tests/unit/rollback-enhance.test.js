import { describe, it, expect } from 'vitest'
import fs from 'fs'
import path from 'path'

const PHASES = path.resolve(__dirname, '../../phases/8-rollback')

function readFile(name) {
  return fs.readFileSync(path.join(PHASES, name), 'utf-8')
}

describe('phase-8 增强回滚', () => {
  const files = ['brownfield.md', 'greenfield.md']

  files.forEach(file => {
    describe(file, () => {
      let content
      beforeAll(() => { content = readFile(file) })

      it('含三档分级判定流程', () => {
        expect(content).toContain('P0')
        expect(content).toContain('P1')
        expect(content).toContain('P2')
      })

      it('含 RCA 事故报告模板', () => {
        expect(content).toContain('事故报告')
        expect(content).toContain('根因分析')
      })

      it('含事后 5 件事检查清单', () => {
        expect(content).toContain('事后')
        expect(content).toContain('5')
      })

      it('P0 "先回滚再诊断"原则明确', () => {
        expect(content).toMatch(/先回滚.*再诊断/)
      })

      it('含三问澄清（P1）', () => {
        expect(content).toContain('影响')
        expect(content).toContain('绕过')
        expect(content).toContain('修复需要多久')
      })

      it('front matter 保留', () => {
        expect(content.startsWith('---')).toBe(true)
      })
    })
  })
})
