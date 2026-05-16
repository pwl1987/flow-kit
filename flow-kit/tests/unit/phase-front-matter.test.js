import { describe, it, expect } from 'vitest'
import { execSync } from 'child_process'
import path from 'path'
import fs from 'fs'

const PHASES_DIR = path.resolve(__dirname, '../../phases')
const LIB = path.resolve(__dirname, '../../lib/front-matter.sh')

function parseFrontMatter(file) {
  const cmd = `bash -c 'source "${LIB}" && parse_front_matter "${file}"'`
  return JSON.parse(execSync(cmd, { encoding: 'utf-8', timeout: 5000 }))
}

function getPhaseFiles() {
  const out = execSync(`find "${PHASES_DIR}" -name "*.md" -type f | sort`, { encoding: 'utf-8' })
  return out.trim().split('\n').filter(Boolean)
}

describe('phase 文件 front matter', () => {
  it('所有 phase 文件含 front matter 且可解析', () => {
    const files = getPhaseFiles()
    expect(files.length).toBeGreaterThanOrEqual(19)

    for (const file of files) {
      const json = parseFrontMatter(file)
      expect(typeof json.phase === 'number' || typeof json.phase === 'string').toBe(true)
      expect(json).toHaveProperty('name')
      expect(json).toHaveProperty('stage')
      expect(['thinking', 'execution']).toContain(json.stage)
    }
  })

  it('front matter 包含 7 个字段', () => {
    const files = getPhaseFiles()
    for (const file of files) {
      const json = parseFrontMatter(file)
      expect(Object.keys(json).length).toBe(7)
      expect(json).toHaveProperty('phase')
      expect(json).toHaveProperty('name')
      expect(json).toHaveProperty('stage')
      expect(json).toHaveProperty('allowed_operations')
      expect(json).toHaveProperty('forbidden_operations')
      expect(json).toHaveProperty('expected_artifacts')
      expect(json).toHaveProperty('next_phase')
    }
  })

  it('brownfield 和 greenfield 对应文件有相同的 phase 值', () => {
    const dirs = execSync(`find "${PHASES_DIR}" -mindepth 1 -maxdepth 1 -type d | sort`, { encoding: 'utf-8' })
      .trim().split('\n').filter(Boolean)

    for (const dir of dirs) {
      const bf = path.join(dir, 'brownfield.md')
      const gf = path.join(dir, 'greenfield.md')
      if (fs.existsSync(bf) && fs.existsSync(gf)) {
        const bfJson = parseFrontMatter(bf)
        const gfJson = parseFrontMatter(gf)
        expect(bfJson.phase).toBe(gfJson.phase)
      }
    }
  })

  it('原文件内容在 front matter 之后保留', () => {
    const files = getPhaseFiles()
    for (const file of files) {
      const content = execSync(`cat "${file}"`, { encoding: 'utf-8' })
      // front matter 之后应有 markdown 标题或正文
      const afterFm = content.replace(/^---[\s\S]*?---\n*/, '')
      expect(afterFm.trim().length).toBeGreaterThan(0)
    }
  })

  it('parse_front_matter 对每个文件解析正确', () => {
    const files = getPhaseFiles()
    for (const file of files) {
      const json = parseFrontMatter(file)
      expect(json.allowed_operations).toBeInstanceOf(Array)
      expect(json.forbidden_operations).toBeInstanceOf(Array)
      expect(json.expected_artifacts).toBeInstanceOf(Array)
      expect(json.allowed_operations.length).toBeGreaterThan(0)
    }
  })
})
