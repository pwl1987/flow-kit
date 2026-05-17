// session-state.mjs — 会话状态管理
// v3.8.0 迁移自 lib/session-state.sh

import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'fs';
import { dirname, join } from 'path';

const SESSION_STATE_FILE = process.env.SESSION_STATE_FILE || 
  join(process.env.HOME || '/tmp', '.flow-kit/session-state.json');

let _initialized = false;

function _atomicWriteJSON(filePath, data) {
  const dir = dirname(filePath);
  mkdirSync(dir, { recursive: true });
  const tmpPath = filePath + '.tmp.' + Date.now();
  writeFileSync(tmpPath, JSON.stringify(data, null, 2));
  try {
    const { renameSync } = require('fs');
    renameSync(tmpPath, filePath);
  } catch {
    // Fallback: direct write
    writeFileSync(filePath, JSON.stringify(data, null, 2));
  }
}

function _atomicReadJSON(filePath) {
  if (!existsSync(filePath)) {
    return null;
  }
  try {
    return JSON.parse(readFileSync(filePath, 'utf8'));
  } catch {
    return null;
  }
}

function _now() {
  return new Date().toISOString();
}

function _skeleton(change, ptype) {
  return {
    v: 2,
    change: change,
    phase: 0,
    status: 'init',
    ptype: ptype,
    mode: 'auto',
    tasks: '',
    next: '',
    blockers: '',
    history: '',
    decisions: '',
    interactions: '',
    ts: _now()
  };
}

export function sessionInit(change = '', ptype = 'green') {
  const dir = dirname(SESSION_STATE_FILE);
  mkdirSync(dir, { recursive: true });
  const data = _skeleton(change, ptype);
  _atomicWriteJSON(SESSION_STATE_FILE, data);
  _initialized = true;
  return data;
}

export function sessionSet(key, val) {
  if (!_initialized) {
    sessionInit();
  }
  const data = _atomicReadJSON(SESSION_STATE_FILE) || _skeleton('', 'green');
  data[key] = val;
  data.ts = _now();
  _atomicWriteJSON(SESSION_STATE_FILE, data);
}

export function sessionGet(key) {
  if (!_initialized) return undefined;
  const data = _atomicReadJSON(SESSION_STATE_FILE);
  return data ? data[key] : undefined;
}

export function sessionTaskSet(tid, status) {
  if (!_initialized) {
    sessionInit();
  }
  const data = _atomicReadJSON(SESSION_STATE_FILE) || _skeleton('', 'green');
  if (!data.tasks) data.tasks = '';
  // Simple task tracking - append or update
  const taskEntry = `${tid}:${status}`;
  data.tasks = data.tasks ? data.tasks + ',' + taskEntry : taskEntry;
  data.ts = _now();
  _atomicWriteJSON(SESSION_STATE_FILE, data);
}

export function sessionNext(val) {
  sessionSet('next', val);
}

export function sessionBlock(val) {
  sessionSet('blockers', val);
}

export function sessionResumePrompt() {
  const data = _atomicReadJSON(SESSION_STATE_FILE);
  if (!data) return '';
  
  const parts = [];
  if (data.change) parts.push(`change: ${data.change}`);
  if (data.phase) parts.push(`phase: ${data.phase}`);
  if (data.status) parts.push(`status: ${data.status}`);
  if (data.next) parts.push(`next: ${data.next}`);
  if (data.blockers) parts.push(`blockers: ${data.blockers}`);
  if (data.tasks) parts.push(`tasks: ${data.tasks}`);
  
  return parts.join(' | ');
}

export function sessionHistoryAdd(action) {
  if (!_initialized) sessionInit();
  const data = _atomicReadJSON(SESSION_STATE_FILE) || _skeleton('', 'green');
  const entry = `${_now()}: ${action}`;
  data.history = data.history ? data.history + '\n' + entry : entry;
  data.ts = _now();
  _atomicWriteJSON(SESSION_STATE_FILE, data);
}

export function sessionDecisionAdd(type, payload) {
  if (!_initialized) sessionInit();
  const data = _atomicReadJSON(SESSION_STATE_FILE) || _skeleton('', 'green');
  if (!data.decisions) data.decisions = [];
  data.decisions.push({ type, payload, ts: _now() });
  data.ts = _now();
  _atomicWriteJSON(SESSION_STATE_FILE, data);
}
