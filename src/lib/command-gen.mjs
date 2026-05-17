// command-gen.mjs — 斜杠命令生成器
// v3.8.0 迁移自 scripts/generate-commands.sh

import { writeFileSync, mkdirSync, existsSync, readFileSync } from 'fs';
import { join, dirname } from 'path';

const OUTPUT_PATH = process.env.OUTPUT_PATH || join(process.env.HOME || '/tmp', '.claude/commands');

const CORE_COMMANDS = {
  'init': 'commands/init-change.md',
  'health': 'commands/M-health.md',
  'scan': 'commands/I-intel-scan.md',
  'next': 'GO.md',
  'status': 'GO.md',
  'mode': 'GO.md',
  'guard': 'commands/careful.md',
  'hooks': 'commands/hooks-guide.md',
  'install': 'commands/install.md',
  'code-review': 'commands/code-review.md',
  'plan-generate': 'commands/plan-generate.md',
  'tmux-init': 'commands/tmux-init.md',
  'tmux-run': 'commands/tmux-run.md',
  'tmux-aggregate': 'commands/tmux-aggregate.md',
  'tmux-cleanup': 'commands/tmux-cleanup.md',
  'register-commands': 'commands/register-commands.md',
  'generate-commands': 'commands/generate-commands.md',
  'archive': 'commands/archive.md',
  'scale': 'commands/scale-level.md',
  'resume': 'commands/resume.md',
  'ralph': 'commands/ralph.md',
  'metrics': 'commands/metrics.md',
  'recall': 'commands/recall.md'
};

const PHASE_COMMANDS = {
  'phase-0': '变更立项',
  'phase-1': '需求澄清',
  'phase-2': '架构设计',
  'phase-3': '任务拆解',
  'phase-4': '开发执行',
  'phase-5': '测试验证',
  'phase-6': '代码审查',
  'phase-7': '集成归档',
  'phase-8': '变更回滚'
};

const PHASE_DIRS = {
  'phase-0': '0-change',
  'phase-1': '1-requirement',
  'phase-2': '2-design',
  'phase-3': '3-task',
  'phase-4': '4-dev',
  'phase-5': '5-test',
  'phase-6': '6-review',
  'phase-7': '7-integration',
  'phase-8': '8-rollback'
};

function extractDescription(filePath, defaultDesc) {
  if (!existsSync(filePath)) {
    return defaultDesc;
  }

  try {
    const content = readFileSync(filePath, 'utf8');
    const lines = content.split('\n');
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim();
      if (line.startsWith('## 目的') || line.startsWith('## 目标')) {
        const nextLine = lines[i + 1];
        if (nextLine && nextLine.trim() && !nextLine.startsWith('#')) {
          return nextLine.replace(/^[>-]\s*/, '').trim();
        }
      }
    }
    if (lines.length > 1) {
      const secondLine = lines[1].trim();
      if (secondLine && secondLine.length > 3) {
        return secondLine.replace(/^>[[:space:]]*/, '').replace(/【[^】]*】/g, '');
      }
    }
  } catch {}

  return defaultDesc;
}

export function generateEntry(cmdName, description, reference, outputFile) {
  mkdirSync(dirname(outputFile), { recursive: true });

  let execute = '';
  if (cmdName === 'next') {
    execute = 'execute: bash flow-kit/scripts/next-phase.sh\n';
  }

  const content = `---
description: ${description}
category: dev
reference: ${reference}
${execute}---
/flow-kit:${cmdName}: ${description}
`;
  writeFileSync(outputFile, content);
}

export function generatePhaseEntry(phase, name, phaseDir, outputFile) {
  mkdirSync(dirname(outputFile), { recursive: true });
  const phaseNum = phase.replace('phase-', '');

  const content = `---
description: ${name} - ${phase}
category: dev
reference: flow-kit/phases/${phaseDir}/
execute: bash flow-kit/scripts/phase-executor.sh ${phaseNum}
---
/flow-kit:${phase}: ${name}
`;
  writeFileSync(outputFile, content);
}

export function registerAllCommands() {
  const commands = [];
  const total = Object.keys(CORE_COMMANDS).length + Object.keys(PHASE_COMMANDS).length;

  for (const cmd of Object.keys(CORE_COMMANDS)) {
    const ref = CORE_COMMANDS[cmd];
    const outputFile = join(OUTPUT_PATH, `flow-kit:${cmd}.md`);
    const description = extractDescription(ref, `flow-kit ${cmd} 命令`);
    generateEntry(cmd, description, ref, outputFile);
    commands.push({ name: cmd, file: outputFile });
  }

  for (const phase of Object.keys(PHASE_COMMANDS)) {
    const name = PHASE_COMMANDS[phase];
    const phaseDir = PHASE_DIRS[phase];
    const outputFile = join(OUTPUT_PATH, `flow-kit:${phase}.md`);
    generatePhaseEntry(phase, name, phaseDir, outputFile);
    commands.push({ name: phase, file: outputFile });
  }

  return { total, commands };
}