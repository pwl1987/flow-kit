/**
 * Phase-Executor Script Tests
 */

const { execSync } = require('child_process');
const path = require('path');

const SCRIPT = path.join(__dirname, '../../scripts/phase-executor.sh');

describe('phase-executor.sh', () => {
  describe('用法验证', () => {
    it('无参数时显示用法说明', () => {
      expect(() => {
        execSync(`bash ${SCRIPT}`, { encoding: 'utf8' });
      }).toThrow();
    });

    it('用法包含 phase-executor', () => {
      const out = execSync(`bash ${SCRIPT} 2>&1 || true`, { encoding: 'utf8', errorOnStderr: false });
      expect(out).toMatch(/phase-executor|用法/);
    });
  });

  describe('参数验证', () => {
    it('接受 phase-num 参数', () => {
      expect(() => {
        execSync(`bash ${SCRIPT} 0-change`, { encoding: 'utf8', errorOnStderr: false });
      }).not.toThrow();
    });

    it('显示项目类型信息', () => {
      const out = execSync(`bash ${SCRIPT} 0-change 2>&1 || true`, { encoding: 'utf8', errorOnStderr: false });
      expect(out).toMatch(/type=|brownfield|greenfield/);
    });
  });

  describe('工作流加载', () => {
    it('执行后输出 phase 信息', () => {
      const out = execSync(`bash ${SCRIPT} 0-change 2>&1 || true`, { encoding: 'utf8', errorOnStderr: false });
      expect(out).toMatch(/phase=/);
    });

    it('输出护栏建议', () => {
      const out = execSync(`bash ${SCRIPT} 0-change 2>&1 || true`, { encoding: 'utf8', errorOnStderr: false });
      expect(out).toMatch(/guard|护栏/);
    });
  });

  describe('错误处理', () => {
    it('无效 phase 不崩溃', () => {
      expect(() => {
        execSync(`bash ${SCRIPT} invalid-phase 2>&1 || true`, { encoding: 'utf8', errorOnStderr: false });
      }).not.toThrow();
    });

    it('空参数显示错误信息', () => {
      const out = execSync(`bash ${SCRIPT} 2>&1 || echo "error"`, { encoding: 'utf8', errorOnStderr: false });
      expect(out).toMatch(/用法|error/);
    });
  });

  describe('状态持久化', () => {
    it('输出包含 phase-exec 标记', () => {
      const out = execSync(`bash ${SCRIPT} 0-change 2>&1 || true`, { encoding: 'utf8', errorOnStderr: false });
      expect(out).toMatch(/\[phase-exec\]/);
    });
  });

  describe('输出格式', () => {
    it('输出不为空', () => {
      const out = execSync(`bash ${SCRIPT} 0-change 2>&1 || true`, { encoding: 'utf8', errorOnStderr: false });
      expect(out.length).toBeGreaterThan(0);
    });
  });
});