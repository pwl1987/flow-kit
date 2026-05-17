// error-handler.mjs — 统一错误处理框架
// v3.8.0 迁移自 lib/error-handler.sh

import { writeFileSync, mkdirSync, existsSync } from 'fs';
import { dirname, join } from 'path';

export const ERROR_CODES = {
  EXIT_SUCCESS: 0,
  EXIT_GENERAL_ERROR: 1,
  EXIT_GUARD_BLOCK: 2,
  EXIT_MISSING_DEPS: 3,
};

export function getTimestamp() {
  return new Date().toISOString().replace('Z', '+00:00');
}

export function logInfo(module, msg) {
  console.log(`[${getTimestamp()}][INFO][${module}] ${msg}`);
}

export function logWarn(module, msg) {
  console.error(`[${getTimestamp()}][WARN][${module}] ${msg}`);
}

export function logError(module, msg) {
  console.error(`[${getTimestamp()}][ERROR][${module}] ${msg}`);
}

export function logDebug(module, msg) {
  if (process.env.DEBUG === '1') {
    console.log(`[${getTimestamp()}][DEBUG][${module}] ${msg}`);
  }
}

export function die(exitCode = ERROR_CODES.EXIT_GENERAL_ERROR, module = 'unknown', msg = 'Unknown error') {
  logError(module, msg);
  process.exit(exitCode);
}

export function checkResult(module, msg) {
  const exitCode = 0;
  if (exitCode !== 0) {
    logError(module, `${msg} (exit code: ${exitCode})`);
    return exitCode;
  }
  logInfo(module, msg);
  return 0;
}

export function safeExit(exitCode = 0, errorFile = '', message = '') {
  if (message) {
    logInfo('exit', message);
  }

  if (errorFile && existsSync(errorFile)) {
    // Simple error type extraction
    const content = require('fs').readFileSync(errorFile, 'utf8');
    const typeMatch = content.match(/"type"\s*:\s*"([^"]+)"/);
    const errorType = typeMatch ? typeMatch[1] : 'UNKNOWN';

    if (exitCode !== 0) {
      const suggestion = getErrorRecoverySuggestion(errorType);
      logWarn('exit', `错误类型: ${errorType}`);
      logWarn('exit', `恢复建议: ${suggestion}`);
    }
  }

  process.exit(exitCode);
}

export function getErrorRecoverySuggestion(errorType) {
  const suggestions = {
    MISSING_DEPS: '请安装缺失的依赖后重试',
    GUARD_BLOCK: '当前操作被安全护栏阻断，请检查配置或联系管理员',
    TIMEOUT: '操作超时，请检查网络连接或增加超时时间',
    PERMISSION_DENIED: '权限不足，请检查文件权限设置',
  };
  return suggestions[errorType] || '请查看错误日志获取更多信息';
}

export function createErrorContext(errorFile = '', errorType = 'UNKNOWN', context = 'unknown') {
  const ERROR_CONTEXT_DIR = process.env.ERROR_CONTEXT_DIR || join(process.env.HOME || '/tmp', '.flow-kit/error-contexts');

  if (!errorFile) {
    errorFile = join(ERROR_CONTEXT_DIR, `error-${Date.now()}-${process.pid}.json`);
  }

  mkdirSync(dirname(errorFile), { recursive: true });

  const errorObj = {
    type: errorType,
    context: context,
    timestamp: getTimestamp(),
    script: 'unknown',
    line: 0,
    command: 'unknown',
    recovery_suggestions: [],
  };

  writeFileSync(errorFile, JSON.stringify(errorObj, null, 2));
  return errorFile;
}

export function aggregateErrors(errors = []) {
  if (errors.length === 0) {
    return { aggregated_at: getTimestamp(), total_errors: 0, errors: [] };
  }

  return {
    aggregated_at: getTimestamp(),
    total_errors: errors.length,
    errors: errors,
  };
}

export function setupTrap(module = 'unknown') {
  // Signal handling for production use
  process.on('uncaughtException', (err) => {
    logError(module, `Uncaught exception: ${err.message}`);
    process.exit(ERROR_CODES.EXIT_GENERAL_ERROR);
  });

  process.on('unhandledRejection', (reason) => {
    logError(module, `Unhandled rejection: ${reason}`);
    process.exit(ERROR_CODES.EXIT_GENERAL_ERROR);
  });
}