/**
 * Checkpoint Resume Mechanism
 * D-03: checkpoint-state.json format
 * D-04: Hybrid trigger (auto-detect + user confirm)
 * D-05: Cleanup on phase complete + new phase start + user reset
 */

const fs = require('fs');
const path = require('path');

const CHECKPOINT_FILE = '.flow-kit/checkpoint-state.json';

// Required fields per D-03
const REQUIRED_FIELDS = ['phase', 'last_completed_plan', 'last_completed_task', 'task_index', 'paused_at', 'next_action'];

/**
 * Read checkpoint state from .flow-kit/checkpoint-state.json
 * @param {string} cwd - Working directory
 * @returns {object|null} - Checkpoint state or null if not exists
 */
function readCheckpoint(cwd) {
  const filePath = path.join(cwd, CHECKPOINT_FILE);
  if (!fs.existsSync(filePath)) {
    return null;
  }
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

/**
 * Write checkpoint state to .flow-kit/checkpoint-state.json
 * @param {string} cwd - Working directory
 * @param {object} state - Checkpoint state must contain: phase, last_completed_plan, last_completed_task, task_index, paused_at, next_action
 */
function writeCheckpoint(cwd, state) {
  // Validate required fields per D-03
  for (const field of REQUIRED_FIELDS) {
    if (!(field in state)) {
      throw new Error(`Checkpoint state missing required field: ${field}`);
    }
  }

  const filePath = path.join(cwd, CHECKPOINT_FILE);
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, JSON.stringify(state, null, 2));
}

/**
 * Clear checkpoint state (used on phase complete, new phase start, user reset)
 * @param {string} cwd - Working directory
 */
function clearCheckpoint(cwd) {
  const filePath = path.join(cwd, CHECKPOINT_FILE);
  if (fs.existsSync(filePath)) {
    fs.unlinkSync(filePath);
  }
}

/**
 * Determine if execution should resume from checkpoint
 * @param {string} cwd - Working directory
 * @returns {object} - { should: boolean, checkpoint?: object, message?: string }
 */
function shouldResume(cwd) {
  const checkpoint = readCheckpoint(cwd);
  if (!checkpoint) {
    return { should: false };
  }
  return {
    should: true,
    checkpoint,
    message: `发现断点（Phase ${checkpoint.phase}, Plan ${checkpoint.last_completed_plan}, Task ${checkpoint.task_index}）。是否恢复？`
  };
}

module.exports = { readCheckpoint, writeCheckpoint, clearCheckpoint, shouldResume };
