/**
 * Checkpoint Module Tests
 */

const fs = require('fs');
const path = require('path');
const { readCheckpoint, writeCheckpoint, clearCheckpoint, shouldResume } = require('./checkpoint.js');

const TEST_DIR = '/tmp/checkpoint-test';

function setup() {
  fs.rmSync(TEST_DIR, { recursive: true, force: true });
  fs.mkdirSync(TEST_DIR, { recursive: true });
}

function testReadCheckpointNoFile() {
  setup();
  const result = readCheckpoint(TEST_DIR);
  console.assert(result === null, 'readCheckpoint returns null when no file exists');
  console.log('PASS: readCheckpoint returns null when no file exists');
}

function testWriteAndReadCheckpoint() {
  setup();
  const state = {
    phase: '05-P0-bugfix',
    last_completed_plan: '05-01',
    last_completed_task: 'Task 3: Update checkpoint integration',
    task_index: 2,
    paused_at: new Date().toISOString(),
    next_action: 'continue'
  };

  writeCheckpoint(TEST_DIR, state);
  const result = readCheckpoint(TEST_DIR);

  console.assert(result !== null, 'readCheckpoint returns object after write');
  console.assert(result.phase === state.phase, 'phase matches');
  console.assert(result.last_completed_plan === state.last_completed_plan, 'last_completed_plan matches');
  console.assert(result.last_completed_task === state.last_completed_task, 'last_completed_task matches');
  console.assert(result.task_index === state.task_index, 'task_index matches');
  console.assert(result.next_action === state.next_action, 'next_action matches');
  console.log('PASS: writeCheckpoint and readCheckpoint work correctly');
}

function testShouldResumeNoCheckpoint() {
  setup();
  const result = shouldResume(TEST_DIR);
  console.assert(result.should === false, 'shouldResume returns should: false when no checkpoint');
  console.log('PASS: shouldResume returns should: false when no checkpoint');
}

function testShouldResumeWithCheckpoint() {
  setup();
  const state = {
    phase: '05-P0-bugfix',
    last_completed_plan: '05-02',
    last_completed_task: 'Task 1: Create checkpoint.js',
    task_index: 0,
    paused_at: new Date().toISOString(),
    next_action: 'continue'
  };

  writeCheckpoint(TEST_DIR, state);
  const result = shouldResume(TEST_DIR);

  console.assert(result.should === true, 'shouldResume returns should: true when checkpoint exists');
  console.assert(result.checkpoint !== null, 'shouldResume includes checkpoint');
  console.assert(result.message.includes('05-P0-bugfix'), 'message contains phase info');
  console.log('PASS: shouldResume returns correct structure with checkpoint');
}

function testClearCheckpoint() {
  setup();
  const state = {
    phase: '05-P0-bugfix',
    last_completed_plan: '05-02',
    last_completed_task: 'Task 1',
    task_index: 0,
    paused_at: new Date().toISOString(),
    next_action: 'continue'
  };

  writeCheckpoint(TEST_DIR, state);
  console.assert(readCheckpoint(TEST_DIR) !== null, 'checkpoint exists after write');

  clearCheckpoint(TEST_DIR);
  console.assert(readCheckpoint(TEST_DIR) === null, 'checkpoint is null after clear');
  console.log('PASS: clearCheckpoint removes checkpoint file');
}

function testWriteCheckpointMissingField() {
  setup();
  const invalidState = {
    phase: '05-P0-bugfix',
    last_completed_plan: '05-02'
    // missing other required fields
  };

  try {
    writeCheckpoint(TEST_DIR, invalidState);
    console.assert(false, 'writeCheckpoint should throw on missing fields');
    console.log('FAIL: writeCheckpoint did not throw on missing fields');
  } catch (e) {
    console.assert(e.message.includes('missing required field'), 'error mentions missing field');
    console.log('PASS: writeCheckpoint validates required fields');
  }
}

function testAllExports() {
  const cp = require('./checkpoint.js');
  console.assert(typeof cp.readCheckpoint === 'function', 'readCheckpoint is exported');
  console.assert(typeof cp.writeCheckpoint === 'function', 'writeCheckpoint is exported');
  console.assert(typeof cp.clearCheckpoint === 'function', 'clearCheckpoint is exported');
  console.assert(typeof cp.shouldResume === 'function', 'shouldResume is exported');
  console.log('PASS: All 4 functions are exported');
}

// Run tests
console.log('Running checkpoint.js tests...\n');
testAllExports();
testReadCheckpointNoFile();
testWriteAndReadCheckpoint();
testShouldResumeNoCheckpoint();
testShouldResumeWithCheckpoint();
testClearCheckpoint();
testWriteCheckpointMissingField();
console.log('\nAll tests passed!');
