// auto-pilot.mjs — 自动导航状态机
// v3.8.0 迁移自 scripts/auto-pilot.sh

import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'fs';
import { join, dirname } from 'path';
import { getTimestamp } from './time-utils.mjs';
import { sessionGet, sessionSet, sessionInit } from './session-state.mjs';

const AUTO_PLAN_FILE = process.env.PATHS_PROJECT_DIR
  ? join(process.env.PATHS_PROJECT_DIR, '.flow-kit/auto-plan.json')
  : join(process.env.PROJECT_DIR || '.', '.flow-kit/auto-plan.json');

const SESSION_STATE_FILE = process.env.SESSION_STATE_FILE ||
  join(process.env.PROJECT_DIR || '.', '.flow-kit/session-state.json');

function _currentPhaseNum() {
  try {
    if (!existsSync(SESSION_STATE_FILE)) return 0;
    const data = JSON.parse(readFileSync(SESSION_STATE_FILE, 'utf8'));
    const phaseStr = data.phase || '0';
    const match = phaseStr.match(/^(\d+)/);
    return match ? parseInt(match[1], 10) : 0;
  } catch {
    return 0;
  }
}

export function doStatus() {
  try {
    let currentPhase = 0;
    let taskDepth = 'campaign';
    let completed = 0;

    if (existsSync(AUTO_PLAN_FILE)) {
      const plan = JSON.parse(readFileSync(AUTO_PLAN_FILE, 'utf8'));
      currentPhase = plan.current_phase || 0;
      taskDepth = plan.task_depth || 'campaign';
      completed = (plan.phases || []).filter(p => p.status === 'completed').length;
    }

    let phaseStr = 'unknown';
    if (existsSync(SESSION_STATE_FILE)) {
      const session = JSON.parse(readFileSync(SESSION_STATE_FILE, 'utf8'));
      phaseStr = session.phase || 'unknown';
    }

    return {
      phase: currentPhase,
      phase_str: phaseStr,
      task_depth: taskDepth,
      completed,
      auto_plan_exists: existsSync(AUTO_PLAN_FILE)
    };
  } catch {
    return {
      phase: 0,
      phase_str: 'unknown',
      task_depth: 'campaign',
      completed: 0,
      auto_plan_exists: false
    };
  }
}

export function recommendNextStep() {
  const status = doStatus();
  const next = status.phase + 1;
  const cappedNext = Math.min(next, 8);
  return `[auto-pilot] Phase ${status.phase} 完成 | 推荐推进到 Phase ${cappedNext}`;
}

export function validateCurrentPhase() {
  const phase = _currentPhaseNum();
  return phase >= 0 && phase <= 8;
}

export function createPlan(depth = 'campaign') {
  const phaseNum = _currentPhaseNum();
  const plan = {
    description: '',
    task_depth: depth,
    current_phase: phaseNum,
    created_at: getTimestamp(),
    updated_at: getTimestamp(),
    phases: []
  };

  const dir = dirname(AUTO_PLAN_FILE);
  mkdirSync(dir, { recursive: true });
  writeFileSync(AUTO_PLAN_FILE, JSON.stringify(plan, null, 2));
  return plan;
}

export function doNext() {
  sessionInit();

  let currentPhase = 0;
  if (existsSync(AUTO_PLAN_FILE)) {
    const plan = JSON.parse(readFileSync(AUTO_PLAN_FILE, 'utf8'));
    currentPhase = plan.current_phase || 0;

    // Mark current as completed
    const phases = plan.phases.map(p =>
      p.id === currentPhase ? { ...p, status: 'completed' } : p
    );
    plan.phases = phases;
    plan.updated_at = getTimestamp();
  }

  const next = currentPhase + 1;
  if (next > 8) {
    return { next_phase: 8, message: '已到达最终 Phase' };
  }

  // Update plan
  if (existsSync(AUTO_PLAN_FILE)) {
    const plan = JSON.parse(readFileSync(AUTO_PLAN_FILE, 'utf8'));
    plan.current_phase = next;
    plan.updated_at = getTimestamp();
    writeFileSync(AUTO_PLAN_FILE, JSON.stringify(plan, null, 2));
  }

  // Update session
  sessionSet('phase', String(next));

  return {
    next_phase: next,
    previous_phase: currentPhase,
    message: `推进到 Phase ${next}`
  };
}