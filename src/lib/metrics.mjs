// metrics.mjs — JSONL 指标日志
// v3.8.0 迁移自 lib/metrics-logger.sh

import { appendFileSync, readFileSync, existsSync, mkdirSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';

const METRICS_LOG_FILE = process.env.METRICS_LOG_FILE || 
  join(process.env.HOME || '/tmp', '.flow-kit/logs/metrics.jsonl');

function _ensureDir() {
  mkdirSync(dirname(METRICS_LOG_FILE), { recursive: true });
}

export function logEvent(eventType, detail = '') {
  _ensureDir();
  const ts = new Date().toISOString();
  const line = JSON.stringify({ event_type: eventType, timestamp: ts, detail });
  appendFileSync(METRICS_LOG_FILE, line + '\n');
}

export function query(eventType) {
  if (!existsSync(METRICS_LOG_FILE)) {
    return [];
  }
  const content = readFileSync(METRICS_LOG_FILE, 'utf8');
  const lines = content.trim().split('\n').filter(Boolean);
  return lines
    .map(line => {
      try {
        return JSON.parse(line);
      } catch {
        return null;
      }
    })
    .filter(obj => obj && obj.event_type === eventType);
}

export function summary() {
  if (!existsSync(METRICS_LOG_FILE)) {
    return { total: 0, types: {} };
  }
  const content = readFileSync(METRICS_LOG_FILE, 'utf8');
  const lines = content.trim().split('\n').filter(Boolean);
  const counts = {};
  lines.forEach(line => {
    try {
      const obj = JSON.parse(line);
      if (obj && obj.event_type) {
        counts[obj.event_type] = (counts[obj.event_type] || 0) + 1;
      }
    } catch {}
  });
  const total = Object.values(counts).reduce((a, b) => a + b, 0);
  return { total, types: counts };
}

export function clear() {
  if (existsSync(METRICS_LOG_FILE)) {
    writeFileSync(METRICS_LOG_FILE, '');
  }
}
