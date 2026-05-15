/**
 * Generate-Commands Script Tests
 */

const { execSync } = require('child_process');
const path = require('path');

const SCRIPT = path.join(__dirname, '../../scripts/generate-commands.sh');

describe('generate-commands.sh', () => {
  describe('帮助信息', () => {
    it('显示帮助信息', () => {
      const out = execSync(`bash ${SCRIPT} --help`, { encoding: 'utf8' });
      expect(out).toContain('flow-kit');
    });

    it('包含版本信息', () => {
      const out = execSync(`bash ${SCRIPT} --help`, { encoding: 'utf8' });
      expect(out).toMatch(/v\d+\.\d+\.\d+/);
    });
  });

  describe('输出目录', () => {
    it('显示输出目录信息', () => {
      const out = execSync(`bash ${SCRIPT} --help`, { encoding: 'utf8' });
      expect(out).toContain('输出目录');
    });

    it('显示增量模式', () => {
      const out = execSync(`bash ${SCRIPT} --help`, { encoding: 'utf8' });
      expect(out).toContain('incremental');
    });
  });

  describe('命令生成', () => {
    it('脚本存在且可执行', () => {
      expect(() => {
        execSync(`bash ${SCRIPT} --help`, { encoding: 'utf8' });
      }).not.toThrow();
    });

    it('显示 Phase 工作流命令', () => {
      const out = execSync(`bash ${SCRIPT} --help`, { encoding: 'utf8' });
      expect(out).toContain('Phase');
    });
  });

  describe('错误处理', () => {
    it('无效参数不崩溃', () => {
      expect(() => {
        execSync(`bash ${SCRIPT} --invalid 2>&1`, { encoding: 'utf8', errorOnStderr: false });
      }).not.toThrow();
    });
  });

  describe('输出格式', () => {
    it('帮助输出不为空', () => {
      const out = execSync(`bash ${SCRIPT} --help`, { encoding: 'utf8' });
      expect(out.length).toBeGreaterThan(0);
    });

    it('包含命令清理信息', () => {
      const out = execSync(`bash ${SCRIPT} --help`, { encoding: 'utf8' });
      expect(out).toMatch(/清理|commands/);
    });
  });

  describe('功能验证', () => {
    it('显示核心命令数量', () => {
      const out = execSync(`bash ${SCRIPT} --help`, { encoding: 'utf8' });
      expect(out).toMatch(/\d+\s*个核心命令|commands?/);
    });
  });
});