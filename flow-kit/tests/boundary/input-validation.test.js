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
      const specialChars = '!@#$%^&*()_+-=[]{}|;:,.<>?`~';
      expect(() => {
        execSync(`bash ${DISPATCH} 1 "${specialChars}"`, { encoding: 'utf8', errorOnStderr: false });
      }).not.toThrow();
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
      expect(() => {
        execSync(`bash ${PHASE_EXEC} -1`, { encoding: 'utf8', errorOnStderr: false });
      }).not.toThrow();
    });

    it('超大 phase 数字', () => {
      expect(() => {
        execSync(`bash ${PHASE_EXEC} 999`, { encoding: 'utf8', errorOnStderr: false });
      }).not.toThrow();
    });

    it('字母参数', () => {
      expect(() => {
        execSync(`bash ${PHASE_EXEC} abc`, { encoding: 'utf8', errorOnStderr: false });
      }).not.toThrow();
    });

    it('混合字母数字参数', () => {
      expect(() => {
        execSync(`bash ${PHASE_EXEC} 5-abc`, { encoding: 'utf8', errorOnStderr: false });
      }).not.toThrow();
    });

    it('空格参数', () => {
      expect(() => {
        execSync(`bash ${PHASE_EXEC} " "`, { encoding: 'utf8', errorOnStderr: false });
      }).not.toThrow();
    });
  });

  describe('generate-commands.sh 边界', () => {
    it('重复多次执行', () => {
      for (let i = 0; i < 3; i++) {
        expect(() => {
          execSync(`bash ${GEN_CMDS} --help`, { encoding: 'utf8' });
        }).not.toThrow();
      }
    });

    it('空参数', () => {
      expect(() => {
        execSync(`bash ${GEN_CMDS} ""`, { encoding: 'utf8', errorOnStderr: false });
      }).not.toThrow();
    });
  });

  describe('并发边界', () => {
    it('快速连续调用', () => {
      expect(() => {
        execSync(`bash ${PHASE_EXEC} 0-change && bash ${PHASE_EXEC} 1-plan`, { encoding: 'utf8', errorOnStderr: false });
      }).not.toThrow();
    });
  });

  describe('环境边界', () => {
    it('空环境变量', () => {
      expect(() => {
        execSync(`CLAUDE_PROJECT_DIR= bash ${GEN_CMDS} --help`, { encoding: 'utf8' });
      }).not.toThrow();
    });

    it('空白环境变量', () => {
      expect(() => {
        execSync(`REPO_ROOT="   " bash ${GEN_CMDS} --help`, { encoding: 'utf8' });
      }).not.toThrow();
    });
  });
});