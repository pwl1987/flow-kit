// validate-phase.mjs — 阶段产物验证
// v3.8.0 迁移自 scripts/validate-phase.sh

import { existsSync, readFileSync, writeFileSync } from 'fs';
import { join } from 'path';
import { parseFrontMatter } from './front-matter.mjs';
import { sessionDecisionAdd } from './session-state.mjs';

const PHASES_DIR = process.env.PHASES_DIR || join(process.env.FLOW_KIT_DIR || '.', 'phases');
const PROJECT_DIR = process.env.PROJECT_DIR || '.';

const PHASE_SCHEMAS = {
  0: { required: ['changeId'] },
  1: { required: ['requirements'] },
  2: { required: ['architecture', 'design'] },
  3: { required: ['tasks'] },
  4: { required: ['implementation'] },
  5: { required: ['test_results'] },
  6: { required: ['code_review'] },
  7: { required: ['integration'] },
  8: { required: ['rollback'] }
};

export async function validateArtifacts(phase) {
  const phaseFile = join(PHASES_DIR, `phase-${phase}.md`);

  if (!existsSync(phaseFile)) {
    return { valid: true, missing: [], note: 'no phase file' };
  }

  const fm = parseFrontMatter(phaseFile);
  const expected = fm.expected_artifacts || [];

  if (expected.length === 0) {
    return { valid: true, missing: [] };
  }

  const missing = [];
  for (const artifact of expected) {
    if (!existsSync(join(PROJECT_DIR, artifact))) {
      missing.push(artifact);
    }
  }

  return {
    valid: missing.length === 0,
    missing,
    checked: expected.length,
    timestamp: new Date().toISOString()
  };
}

export async function recordEvidence(phase, data) {
  const evidence = {
    phase,
    ...data,
    recorded_at: new Date().toISOString()
  };

  sessionDecisionAdd('phase_evidence', evidence);

  return { recorded: true, evidence };
}

export async function validateSchema(phase, output) {
  const schema = PHASE_SCHEMAS[phase];
  if (!schema) {
    return { valid: true, errors: [] };
  }

  const errors = [];
  for (const field of schema.required) {
    if (!output || output[field] === undefined) {
      errors.push(`Missing required field: ${field}`);
    }
  }

  return {
    valid: errors.length === 0,
    errors,
    phase
  };
}