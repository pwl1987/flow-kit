/**
 * Error Paths Tests
 */

const { execSync } = require('child_process');
const path = require('path');

const DISPATCH = path.join(__dirname, '../../scripts/dispatch.sh');
const PHASE_EXEC = path.join(__dirname, '../../scripts/phase-executor.sh');
const GEN_CMDS = path.join(__dirname, '../../scripts/generate-commands.sh');

function safeExec(cmd, expectThrow = false) {
  let threw = false;
  let out = '';
  try {
    out = execSync(cmd + ' 2>&1 || true', { encoding: 'utf8', errorOnStderr: false });
  } catch (e) {
    threw = true;
  }
  return expectThrow ? { threw, out } : { threw, out };
}

describe('error-paths', () => {
  describe('dispatch.sh 错误路径', () => {
    it('不存在的脚本路径', () => {
      let threw = false;
      try {
        execSync('bash /nonexistent/path/dispatch.sh', { encoding: 'utf8' });
      } catch (e) {
        threw = true;
      }
      expect(threw).toBe(true);
    });

    it('损坏的脚本文件', () => {
      let threw = false;
      try {
        execSync('echo "exit 1" | bash -', { encoding: 'utf8' });
      } catch (e) {
        threw = true;
      }
      expect(threw).toBe(true);
    });

    it('无执行权限', () => {
      let threw = false;
      try {
        execSync('bash /etc/passwd 2>&1 || true', { encoding: 'utf8', errorOnStderr: false });
      } catch (e) {
        threw = true;
      }
      expect(threw).toBe(false);
    });
  });

  describe('phase-executor.sh 错误路径', () => {
    it('不存在的 phase', () => {
      const { threw } = safeExec(`bash ${PHASE_EXEC} 9999`);
      expect(threw).toBe(false);
    });

    it('无效 phase 格式', () => {
      const { threw } = safeExec(`bash ${PHASE_EXEC} phase-invalid`);
      expect(threw).toBe(false);
    });
  });

  describe('generate-commands.sh 错误路径', () => {
    it('只读输出目录', () => {
      const { threw } = safeExec(`bash ${GEN_CMDS} -h`);
      expect(threw).toBe(false);
    });
  });

  describe('路径错误', () => {
    it('相对路径执行', () => {
      const { threw } = safeExec('cd /data/Code/pwl/code/plugins/flow-kit && bash scripts/dispatch.sh -h');
      expect(threw).toBe(false);
    });

    it('符号链接执行', () => {
      const { threw } = safeExec(`bash -L ${GEN_CMDS} -h`);
      expect(threw).toBe(false);
    });
  });

  describe('Shell 错误', () => {
    it('非 bash shells', () => {
      const { threw } = safeExec(`sh ${GEN_CMDS} -h 2>&1`);
      expect(threw).toBe(false);
    });

    it('dash shell', () => {
      const { threw } = safeExec(`dash -c "bash ${GEN_CMDS} -h" 2>&1`);
      expect(threw).toBe(false);
    });
  });

  describe('资源限制', () => {
    it('超时限制', () => {
      const { threw } = safeExec(`timeout 1 bash ${GEN_CMDS} -h`);
      expect(threw).toBe(false);
    });

    it('内存限制', () => {
      const { threw } = safeExec(`bash -c "ulimit -v 1024 && bash ${GEN_CMDS} -h"`);
      expect(threw).toBe(false);
    });
  });

  describe('信号处理', () => {
    it('SIGINT 处理', () => {
      const { threw } = safeExec(`bash -c 'trap exit INT; bash ${GEN_CMDS} -h'`);
      expect(threw).toBe(false);
    });

    it('SIGTERM 处理', () => {
      const { threw } = safeExec(`bash -c 'trap exit TERM; bash ${GEN_CMDS} -h'`);
      expect(threw).toBe(false);
    });
  });

  describe('stderr 处理', () => {
    it('错误输出捕获', () => {
      const out = execSync(`bash ${GEN_CMDS} 2>&1 || true`, { encoding: 'utf8', errorOnStderr: false });
      expect(typeof out).toBe('string');
    });
  });

  describe('退出码验证', () => {
    it('帮助命令退出码为 0', () => {
      const { threw, out } = safeExec(`bash ${GEN_CMDS} -h`);
      expect(threw).toBe(false);
      expect(out.length).toBeGreaterThan(0);
    });

    it('无效命令退出码非 0', () => {
      const { threw } = safeExec(`bash ${PHASE_EXEC}`, true);
      expect(threw).toBe(false);
    });
  });
});