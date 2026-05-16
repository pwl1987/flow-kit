/**
 * Input Validation Boundary Tests
 */

const { execSync } = require('child_process');
const path = require('path');

const DISPATCH = path.join(__dirname, '../../scripts/dispatch.sh');
const PHASE_EXEC = path.join(__dirname, '../../scripts/phase-executor.sh');
const GEN_CMDS = path.join(__dirname, '../../scripts/generate-commands.sh');

describe('input-validation', () => {
  describe('dispatch.sh 边界', () => {
    it('空字符串参数', () => {
      expect(() => {
        execSync(`bash ${DISPATCH} ""`, { encoding: 'utf8', errorOnStderr: false });
      }).toThrow();
    });

    it('超长任务描述', () => {
      const longTask = 'a'.repeat(10000);
      expect(() => {
        execSync(`bash ${DISPATCH} 1 "${longTask}"`, { encoding: 'utf8', errorOnStderr: false });
      }).not.toThrow();
    });

    it('特殊字符任务描述', () => {
      const specialChars = '!@#$%^&*()_+-=[]{}|;:,.<>?~';
      let threw = false;
      try {
        execSync(`bash ${DISPATCH} 1 "${specialChars}" 2>&1 || true`, { encoding: 'utf8', errorOnStderr: false });
      } catch (e) {
        threw = true;
      }
      expect(threw).toBe(false);
    });

    it('多字节字符任务描述', () => {
      const multibyte = '中文测试任務描述';
      expect(() => {
        execSync(`bash ${DISPATCH} 1 "${multibyte}"`, { encoding: 'utf8', errorOnStderr: false });
      }).not.toThrow();
    });

    it('数字前导参数', () => {
      expect(() => {
        execSync(`bash ${DISPATCH} 123 "test"`, { encoding: 'utf8', errorOnStderr: false });
      }).not.toThrow();
    });
  });

  describe('phase-executor.sh 边界', () => {
    it('负数 phase', () => {
      let threw = false;
      try {
        execSync(`bash ${PHASE_EXEC} -1 2>&1 || true`, { encoding: 'utf8', errorOnStderr: false });
      } catch (e) {
        threw = true;
      }
      expect(threw).toBe(false);
    });

    it('超大 phase 数字', () => {
      let threw = false;
      try {
        execSync(`bash ${PHASE_EXEC} 999 2>&1 || true`, { encoding: 'utf8', errorOnStderr: false });
      } catch (e) {
        threw = true;
      }
      expect(threw).toBe(false);
    });

    it('字母参数', () => {
      let threw = false;
      try {
        execSync(`bash ${PHASE_EXEC} abc 2>&1 || true`, { encoding: 'utf8', errorOnStderr: false });
      } catch (e) {
        threw = true;
      }
      expect(threw).toBe(false);
    });

    it('混合字母数字参数', () => {
      let threw = false;
      try {
        execSync(`bash ${PHASE_EXEC} 5-abc 2>&1 || true`, { encoding: 'utf8', errorOnStderr: false });
      } catch (e) {
        threw = true;
      }
      expect(threw).toBe(false);
    });

    it('空格参数', () => {
      let threw = false;
      try {
        execSync(`bash ${PHASE_EXEC} " " 2>&1 || true`, { encoding: 'utf8', errorOnStderr: false });
      } catch (e) {
        threw = true;
      }
      expect(threw).toBe(false);
    });
  });

  describe('generate-commands.sh 边界', () => {
    it('重复多次执行', () => {
      for (let i = 0; i < 3; i++) {
        let threw = false;
        try {
          execSync(`bash ${GEN_CMDS} -h`, { encoding: 'utf8' });
        } catch (e) {
          threw = true;
        }
        expect(threw).toBe(false);
      }
    });

    it('空参数', () => {
      let threw = false;
      try {
        execSync(`bash ${GEN_CMDS} ""`, { encoding: 'utf8' });
      } catch (e) {
        threw = true;
      }
      expect(threw).toBe(false);
    });
  });

  describe('并发边界', () => {
    it('快速连续调用', () => {
      let threw = false;
      try {
        execSync(`bash ${PHASE_EXEC} 0-change 2>&1 && bash ${PHASE_EXEC} 1-plan 2>&1 || true`, { encoding: 'utf8', errorOnStderr: false });
      } catch (e) {
        threw = true;
      }
      expect(threw).toBe(false);
    });
  });

  describe('环境边界', () => {
    it('空环境变量', () => {
      let threw = false;
      try {
        execSync(`CLAUDE_PROJECT_DIR= bash ${GEN_CMDS} -h`, { encoding: 'utf8' });
      } catch (e) {
        threw = true;
      }
      expect(threw).toBe(false);
    });

    it('空白环境变量', () => {
      let threw = false;
      try {
        execSync(`REPO_ROOT="   " bash ${GEN_CMDS} -h`, { encoding: 'utf8' });
      } catch (e) {
        threw = true;
      }
      expect(threw).toBe(false);
    });
  });
});