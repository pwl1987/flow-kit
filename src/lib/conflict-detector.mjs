// conflict-detector.mjs — 冲突检测器
// v3.8.0 迁移自 lib/conflict-detector.sh

import { sessionInit, sessionGet, sessionSet } from './session-state.mjs';

const TYPE_KEYWORDS = {
  feature: ['add', 'new', 'implement', 'create', '功能', '新增'],
  bugfix: ['fix', 'bug', 'patch', 'repair', '修复', '错误'],
  refactor: ['refactor', 'restructure', 'optimize', '重构', '优化'],
  docs: ['doc', 'readme', 'comment', '文档', '说明'],
};

const _conflictCache = new Map();

export function classifyRequirement(req) {
  if (!req || typeof req !== 'string') return 'unknown';
  
  const lower = req.toLowerCase();
  for (const [type, keywords] of Object.entries(TYPE_KEYWORDS)) {
    for (const kw of keywords) {
      if (lower.includes(kw)) return type;
    }
  }
  return 'unknown';
}

export function detectConflict(newReq) {
  // Simple conflict detection based on type/scope
  const existingReqs = sessionGet('conflicts') || [];
  
  for (const req of existingReqs) {
    if (req.type === newReq.type && req.scope === newReq.scope) {
      return { existing: req, new: newReq, reason: 'same-type-and-scope' };
    }
  }
  
  return null;
}

export function detectFileConflict(targetModule) {
  if (!targetModule) return null;
  
  const activeFiles = sessionGet('activeFiles') || [];
  if (activeFiles.includes(targetModule)) {
    return { file: targetModule, reason: 'already-active' };
  }
  
  return null;
}

export function handleConflictDecision(choice) {
  sessionInit('conflict-resolution', 'green');
  
  const decision = {
    choice,
    timestamp: new Date().toISOString(),
    resolved: true
  };
  
  sessionSet('lastConflictDecision', JSON.stringify(decision));
  return decision;
}
