// phase-executor.mjs — 阶段执行器
// v3.8.0 迁移自 scripts/phase-executor.sh

import { existsSync, readFileSync } from 'fs';
import { join, dirname } from 'path';
import { parseFrontMatter } from './front-matter.mjs';
import { sessionInit, sessionSet, sessionGet, sessionHistoryAdd } from './session-state.mjs';

const PHASES_DIR = process.env.PHASES_DIR || join(process.env.CLAUDE_PLUGIN_ROOT || '', 'phases');

export function loadWorkflow(phaseFile) {
  if (!existsSync(phaseFile)) {
    throw new Error(`工作流文件不存在: ${phaseFile}`);
  }
  
  const content = readFileSync(phaseFile, 'utf8');
  const fm = parseFrontMatter(phaseFile);
  
  return {
    file: phaseFile,
    content,
    ...fm
  };
}

export function runPhase(phaseNum) {
  sessionInit('', 'green');
  
  const phaseStr = String(phaseNum);
  if (!/^\d+$/.test(phaseStr) || parseInt(phaseStr) < 0 || parseInt(phaseStr) > 8) {
    throw new Error(`无效 phase 编号: ${phaseNum}，有效范围 0-8`);
  }
  
  sessionSet('phase', phaseStr);
  sessionSet('status', 'wip');
  sessionHistoryAdd(`phase-${phaseStr}`);
  
  const projectType = sessionGet('ptype') || 'green';
  const phaseFile = join(PHASES_DIR, `phase-${phaseStr}.md`);
  
  let workflow = null;
  if (existsSync(phaseFile)) {
    workflow = loadWorkflow(phaseFile);
  }
  
  return {
    phase: parseInt(phaseStr),
    projectType,
    workflow,
    guard: projectType === 'brownfield' ? 'full' : 'minimal'
  };
}
