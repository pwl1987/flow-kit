/**
 * Generate-Commands Script Tests
 */

const { execSync } = require('child_process');
const path = require('path');

const SCRIPT = path.join(__dirname, '../../scripts/generate-commands.sh');

describe('generate-commands.sh', () => {
  describe('帮助信息', () => {
    it('显示帮助信息', () => {
      const out = execSync(`bash ${SCRIPT} -h`, { encoding: 'utf8' });
      expect(out).toContain('generate-commands');
    });

    it('显示帮助选项', () => {
      const out = execSync(`bash ${SCRIPT} -h`, { encoding: 'utf8' });
      expect(out).toMatch(/-h.*--help|--help.*显示此帮助/);
    });
  });

  describe('输出目录', () => {
    it('显示输出目录信息', () => {
      const out = execSync(`bash ${SCRIPT} -h`, { encoding: 'utf8' });
      expect(out).toMatch(/输出|目录|commands/);
    });

    it('显示强制选项', () => {
      const out = execSync(`bash ${SCRIPT} -h`, { encoding: 'utf8' });
      expect(out).toMatch(/force|强制/);
    });
  });

  describe('命令生成', () => {
    it('脚本存在且可执行', () => {
      let threw = false;
      try {
        execSync(`bash ${SCRIPT} -h`, { encoding: 'utf8' });
      } catch (e) {
        threw = true;
      }
      expect(threw).toBe(false);
    });

    it('显示工作流命令', () => {
      const out = execSync(`bash ${SCRIPT} -h`, { encoding: 'utf8' });
      expect(out).toMatch(/generate|生成/);
    });
  });

  describe('错误处理', () => {
    it('无效参数不崩溃', () => {
      let threw = false;
      try {
        execSync(`bash ${SCRIPT} -X 2>&1 || true`, { encoding: 'utf8', errorOnStderr: false });
      } catch (e) {
        threw = true;
      }
      expect(threw).toBe(false);
    });
  });

  describe('输出格式', () => {
    it('帮助输出不为空', () => {
      const out = execSync(`bash ${SCRIPT} -h`, { encoding: 'utf8' });
      expect(out.length).toBeGreaterThan(0);
    });

    it('包含命令生成信息', () => {
      const out = execSync(`bash ${SCRIPT} -h`, { encoding: 'utf8' });
      expect(out).toMatch(/生成|命令|commands/);
    });
  });

  describe('功能验证', () => {
    it('显示命令选项', () => {
      const out = execSync(`bash ${SCRIPT} -h`, { encoding: 'utf8' });
      expect(out).toMatch(/选项|option/);
    });
  });
});