// paths.mjs — 统一路径管理
// v3.8.0 迁移自 lib/paths.sh

import { dirname, join, resolve } from 'path';
import { existsSync, mkdirSync, readdirSync, rmSync } from 'fs';

const PROJECT_ROOT = process.env.CLAUDE_PROJECT_DIR || process.cwd();
const PLUGIN_ROOT = process.env.CLAUDE_PLUGIN_ROOT || resolve(dirname(''), '../..');
const PLUGIN_DATA = process.env.CLAUDE_PLUGIN_DATA || join(process.env.HOME || '/tmp', '.claude/flow-kit');

export function getPaths() {
  const FLOW_KIT_DIR = PLUGIN_ROOT;

  return {
    FLOW_KIT_DIR,
    PROJECT_DIR: PROJECT_ROOT,
    SCRIPTS_DIR: join(FLOW_KIT_DIR, 'scripts'),
    LIB_DIR: join(FLOW_KIT_DIR, 'lib'),
    HOOKS_DIR: join(FLOW_KIT_DIR, 'hooks'),
    CONFIG_DIR: join(FLOW_KIT_DIR, 'config'),
    GUARDRAILS_DIR: join(FLOW_KIT_DIR, 'guardrails'),
    COMMANDS_DIR: join(FLOW_KIT_DIR, 'commands'),
    SKILLS_DIR: join(FLOW_KIT_DIR, 'skills'),
    PHASES_DIR: join(FLOW_KIT_DIR, 'phases'),
    TEMPLATES_DIR: join(FLOW_KIT_DIR, 'templates'),
    REFERENCE_DIR: join(FLOW_KIT_DIR, 'reference'),
    SCHEMA_DIR: join(FLOW_KIT_DIR, 'lib/validation/schemas'),
    TMP_DIR: join(PROJECT_ROOT, '.flow-kit/tmp'),
    LOCK_DIR: join(PROJECT_ROOT, '.flow-kit/locks'),
    LOGS_DIR: join(PROJECT_ROOT, '.flow-kit/logs'),
    CONTEXT_DIR: join(PROJECT_ROOT, '.flow-kit/context'),
    PLANNING_DIR: join(PROJECT_ROOT, '.planning'),
    OUTPUT_DIR: join(PROJECT_ROOT, '.planning/outputs'),
    COVERAGE_DIR: join(PROJECT_ROOT, '.flow-kit/coverage'),
    HEALTH_HISTORY_FILE: join(PROJECT_ROOT, '.flow-kit/health-history.json'),
    HEALTH_ARCHIVE_DIR: join(PROJECT_ROOT, '.flow-kit/health-archive'),
    CHECKPOINT_FILE: join(PROJECT_ROOT, '.flow-kit/checkpoint-state.json'),
    PROJECT_TYPE_FILE: join(PROJECT_ROOT, '.flow-kit/project-type'),
    CURRENT_PHASE_FILE: join(PROJECT_ROOT, '.flow-kit/current-phase'),
    MODE_FILE: join(PROJECT_ROOT, '.flow-kit/mode'),
    SESSION_STATE_FILE: join(PROJECT_ROOT, '.flow-kit/session-state.json'),
  };
}

export function initRuntimeDirs() {
  const paths = getPaths();
  const dirs = [
    paths.TMP_DIR,
    paths.LOCK_DIR,
    paths.LOGS_DIR,
    paths.CONTEXT_DIR,
    paths.OUTPUT_DIR,
    paths.COVERAGE_DIR,
    paths.HEALTH_ARCHIVE_DIR,
  ];
  for (const dir of dirs) {
    if (!existsSync(dir)) {
      mkdirSync(dir, { recursive: true });
    }
  }
}

export function rotateLogs(logDir, options = {}) {
  const { maxFiles = 10 } = options;

  if (!existsSync(logDir)) {
    return;
  }

  const archiveDir = join(logDir, 'archive');
  if (!existsSync(archiveDir)) {
    mkdirSync(archiveDir, { recursive: true });
  }

  // 清理超过保留数量的日志文件
  const files = readdirSync(logDir)
    .filter(f => f.endsWith('.log'))
    .sort()
    .reverse();

  if (files.length > maxFiles) {
    const toDelete = files.slice(maxFiles);
    for (const file of toDelete) {
      rmSync(join(logDir, file), { force: true });
    }
  }
}