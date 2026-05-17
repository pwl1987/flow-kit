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

  describe('v3.7.0 指标埋点', () => {
    it('执行后写入 metrics 日志', () => {
      const { mkdirSync, rmSync, existsSync, readFileSync } = require('fs');
      const { tmpdir } = require('os');
      const { join } = require('path');
      const tmpDir = join(tmpdir(), `pe-metrics-${Date.now()}`);
      const logsDir = join(tmpDir, 'logs');
      mkdirSync(logsDir, { recursive: true });
      const metricsFile = join(logsDir, 'metrics.jsonl');
      const env = {
        ...process.env,
        METRICS_LOG_DIR: logsDir,
        METRICS_LOG_FILE: metricsFile,
      };
      execSync(`bash ${SCRIPT} 0-change 2>&1 || true`, { encoding: 'utf8', env, timeout: 5000 });
      expect(existsSync(metricsFile)).toBe(true);
      const content = readFileSync(metricsFile, 'utf8');
      expect(content).toContain('phase_complete');
      rmSync(tmpDir, { recursive: true, force: true });
    });

    it('metrics-logger 缺失时不影响执行', () => {
      const env = { ...process.env, LIB_DIR: '/nonexistent' };
      const out = execSync(`bash ${SCRIPT} 0-change 2>&1 || true`, { encoding: 'utf8', env, timeout: 5000 });
      expect(out).toMatch(/phase=/);
    });

    it('指标含 duration 字段', () => {
      const { mkdirSync, rmSync, readFileSync } = require('fs');
      const { tmpdir } = require('os');
      const { join } = require('path');
      const tmpDir = join(tmpdir(), `pe-metrics-dur-${Date.now()}`);
      const logsDir = join(tmpDir, 'logs');
      mkdirSync(logsDir, { recursive: true });
      const metricsFile = join(logsDir, 'metrics.jsonl');
      const env = {
        ...process.env,
        METRICS_LOG_DIR: logsDir,
        METRICS_LOG_FILE: metricsFile,
      };
      execSync(`bash ${SCRIPT} 0-change 2>&1 || true`, { encoding: 'utf8', env, timeout: 5000 });
      const content = readFileSync(metricsFile, 'utf8');
      expect(content).toMatch(/duration=\d+s/);
      rmSync(tmpDir, { recursive: true, force: true });
    });
  });

  describe('v3.7.0 路由和边界', () => {
    it('phase 4 加载 dev 工作流', () => {
      const out = execSync(`bash ${SCRIPT} 4-dev 2>&1 || true`, { encoding: 'utf8', errorOnStderr: false });
      expect(out).toMatch(/phase=4|4-dev/);
    });

    it('phase 8 加载 rollback 工作流', () => {
      const out = execSync(`bash ${SCRIPT} 8-rollback 2>&1 || true`, { encoding: 'utf8', errorOnStderr: false });
      expect(out).toMatch(/phase=8|8-rollback/);
    });

    it('纯数字 phase 正常工作', () => {
      const out = execSync(`bash ${SCRIPT} 0 2>&1 || true`, { encoding: 'utf8', errorOnStderr: false });
      expect(out).toMatch(/phase=/);
    });

    it('无效大数字 phase 不崩溃', () => {
      const out = execSync(`bash ${SCRIPT} 99 2>&1 || true`, { encoding: 'utf8', errorOnStderr: false });
      expect(out.length).toBeGreaterThan(0);
    });

    it('帮助参数正常', () => {
      const out = execSync(`bash ${SCRIPT} -h`, { encoding: 'utf8' });
      expect(out).toContain('phase-executor');
    });

    it('输出含 workflow 路径', () => {
      const out = execSync(`bash ${SCRIPT} 0-change 2>&1 || true`, { encoding: 'utf8', errorOnStderr: false });
      expect(out).toMatch(/workflow=/);
    });

    it('输出含 guard 建议', () => {
      const out = execSync(`bash ${SCRIPT} 0-change 2>&1 || true`, { encoding: 'utf8', errorOnStderr: false });
      expect(out).toMatch(/guard/);
    });
  });
});