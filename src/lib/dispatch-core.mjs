// dispatch-core.mjs — 多代理调度核心
// v3.8.0 迁移自 scripts/dispatch.sh

import { writeFileSync, mkdirSync, existsSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';
import { getTimestamp } from './time-utils.mjs';

const TASK_DIR = process.env.DISPATCH_TASK_DIR || join(tmpdir(), 'dispatch-tasks');

function _ensureTaskDir() {
  if (!existsSync(TASK_DIR)) {
    mkdirSync(TASK_DIR, { recursive: true });
  }
}

export function splitTask(task, n) {
  if (!task || task.trim() === '') return [];

  _ensureTaskDir();

  const taskId = 'task-' + Date.now();
  const createdAt = getTimestamp();
  const subtasks = [];

  const roles = ['Code Executor', 'Code Reviewer', 'Test Runner'];

  for (let i = 1; i <= n; i++) {
    const agentId = 'agent-' + i;
    const role = roles[(i - 1) % roles.length];

    const promptFile = join(TASK_DIR, `subagent-${agentId}-prompt.txt`);
    const promptContent = `# 子任务\n\n**任务ID**: ${taskId}\n**子代理ID**: ${agentId}\n**角色**: ${role}\n**任务**: ${task}`;
    writeFileSync(promptFile, promptContent);

    subtasks.push({
      id: agentId,
      role,
      status: 'QUEUED',
      prompt_file: promptFile,
      task_id: taskId,
      created_at: createdAt
    });
  }

  return subtasks;
}

async function _runSingleAgent(task, maxRetries = 2) {
  // 模拟执行
  await new Promise(resolve => setTimeout(resolve, 50));
  return {
    id: task.id,
    role: task.role,
    status: 'SUCCESS',
    summary: task.role + ' 执行完成',
    files_modified: [],
    issues: [],
    attempts: 1
  };
}

export async function executeSubagents(subtasks, options = {}) {
  const { timeout = 300000, maxRetries = 2 } = options;
  const results = [];

  for (const task of subtasks) {
    try {
      const result = await _runSingleAgent(task, maxRetries);
      results.push(result);
    } catch (e) {
      results.push({
        id: task.id,
        role: task.role,
        status: 'FAILED',
        summary: e.message,
        files_modified: [],
        issues: [e.message]
      });
    }
  }

  return results;
}

export async function waitForSubagents(timeout = 300000) {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve({ timed_out: true });
    }, timeout);
  });
}

export function collectResults() {
  return {
    total: 0,
    successful: 0,
    failed: 0,
    partial: 0,
    agents: []
  };
}

export function cleanupChildren() {
  // 清理子进程
}

export function _setTaskDir(dir) {
  TASK_DIR = dir;
}