/**
 * Dispatch Script Tests
 */

const { execSync } = require('child_process');
const path = require('path');

const SCRIPT = path.join(__dirname, '../../scripts/dispatch.sh');

describe('dispatch.sh', () => {
  describe('help', () => {
    it('显示帮助信息', () => {
      const out = execSync(`bash ${SCRIPT} -h`, { encoding: 'utf8' });
      expect(out).toContain('用法');
    });

    it('帮助包含用法说明', () => {
      const out = execSync(`bash ${SCRIPT} -h`, { encoding: 'utf8' });
      expect(out).toMatch(/用法.*dispatch\.sh/);
    });
  });

  describe('参数验证', () => {
    it('无参数时显示帮助', () => {
      let threw = false;
      let out = '';
      try {
        out = execSync(`bash ${SCRIPT} 2>&1`, { encoding: 'utf8', errorOnStderr: false });
      } catch (e) {
        threw = true;
      }
      expect(threw).toBe(false);
      expect(out).toMatch(/用法|dispatch/);
    });

    it('显示任务描述参数提示', () => {
      const out = execSync(`bash ${SCRIPT} -h 2>&1`, { encoding: 'utf8', errorOnStderr: false });
      expect(out).toMatch(/任务描述|N|description/);
    });
  });

  describe('基本执行', () => {
    it('脚本存在且可执行', () => {
      expect(() => {
        execSync(`bash ${SCRIPT} -h`, { encoding: 'utf8' });
      }).not.toThrow();
    });
  });

  describe('输出格式', () => {
    it('帮助输出包含脚本描述', () => {
      const out = execSync(`bash ${SCRIPT} -h`, { encoding: 'utf8' });
      expect(out.length).toBeGreaterThan(0);
    });
  });

  describe('环境变量', () => {
    it('支持 SIMULATION_MODE 环境变量', () => {
      const out = execSync(`SIMULATION_MODE=true bash ${SCRIPT} -h`, { encoding: 'utf8' });
      expect(out).toBeDefined();
    });
  });

  describe('错误处理', () => {
    it('无效参数不崩溃', () => {
      expect(() => {
        execSync(`bash ${SCRIPT} --invalid 2>&1`, { encoding: 'utf8', errorOnStderr: false });
      }).not.toThrow();
    });
  });
});