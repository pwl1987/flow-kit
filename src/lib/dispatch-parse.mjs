// dispatch-parse.mjs — dispatch 参数解析
// v3.8.0 迁移自 scripts/dispatch-parse.sh

export function parseArgs(...args) {
  let execute_mode = false;
  let wait_mode = false;
  let aggregate_mode = false;
  let wait_timeout = 300;
  let parallel_n = 3;
  let task_desc = '';

  if (args.length === 0) {
    throw new Error('缺少任务描述参数');
  }

  const remaining = [];
  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg === '--execute') {
      execute_mode = true;
    } else if (arg === '--wait') {
      wait_mode = true;
    } else if (arg === '--aggregate') {
      aggregate_mode = true;
    } else if (arg === '--timeout') {
      wait_timeout = parseInt(args[++i], 10) || 300;
    } else {
      remaining.push(arg);
    }
  }

  if (aggregate_mode || wait_mode) {
    return { execute_mode, wait_mode, aggregate_mode, timeout: wait_timeout, parallel_n: 0, task_desc: '' };
  }

  if (remaining.length === 0) {
    throw new Error('缺少任务描述参数');
  }

  if (/^\d+$/.test(remaining[0])) {
    parallel_n = parseInt(remaining.shift(), 10);
  }

  task_desc = remaining.join(' ');

  if (!task_desc.trim()) {
    throw new Error('任务描述不能为空');
  }

  return { execute_mode, wait_mode, aggregate_mode, timeout: wait_timeout, parallel_n, task_desc };
}

export function parseManifest(data) {
  if (typeof data === 'string') {
    try {
      data = JSON.parse(data);
    } catch {
      throw new Error('无效的 JSON 格式');
    }
  }

  if (!data.task_id && !data.task_desc) {
    throw new Error('manifest 必须包含 task_id 或 task_desc');
  }

  return {
    task_id: data.task_id || 'unknown',
    task_desc: data.task_desc || '',
    parallel_n: data.parallel_n || 1,
    agents: Array.isArray(data.agents) ? data.agents : []
  };
}

export function parseSubtask(data) {
  if (typeof data !== 'object' || data === null) {
    throw new Error('子任务必须是对象');
  }

  return {
    id: data.id || `agent-${Date.now()}-${Math.random().toString(36).substr(2, 5)}`,
    command: data.command || '',
    args: Array.isArray(data.args) ? data.args : [],
    status: data.status || 'QUEUED'
  };
}