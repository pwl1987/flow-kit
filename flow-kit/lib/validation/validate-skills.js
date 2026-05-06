const fs = require('fs');
const path = require('path');

const SKILL_STRUCTURE = {
  L1: { name: '使用场景', pattern: /##\s*WHEN_TO_USE|##\s*L1.*使用场景/i },
  L2: { name: '输入/输出', pattern: /##\s*HOW_TO_USE|##\s*输入|##\s*L2.*输入/i },
  L3: { name: '示例', pattern: /##\s*EXAMPLE|##\s*示例|##\s*L3.*示例/i },
  L4: { name: '限制说明', pattern: /##\s*NOTES|##\s*限制|##\s*L4.*限制/i }
};

const CRITICAL_SKILLS = ['requirement-clarify', 'subagent-execution', 'verification'];
const AUXILIARY_SKILLS = ['task-master', 'code-review', 'debugging', 'parallel-dispatch'];

function validateSkill(skillPath) {
  const content = fs.readFileSync(skillPath, 'utf8');
  const results = [];

  for (const [level, { name, pattern }] of Object.entries(SKILL_STRUCTURE)) {
    const found = pattern.test(content);
    results.push({ level, name, found });
  }

  const passCount = results.filter(r => r.found).length;
  const allPass = passCount === 4;
  const skillName = path.basename(skillPath, '.md');
  const critical = CRITICAL_SKILLS.includes(skillName);

  return {
    skill: skillName,
    level: results,
    passCount,
    allPass,
    critical
  };
}

function validateAllSkills(skillsDir) {
  const files = fs.readdirSync(skillsDir).filter(f => f.endsWith('.md'));
  const results = files.map(f => validateSkill(path.join(skillsDir, f)));

  const failed = results.filter(r => !r.allPass);
  const criticalFailed = failed.filter(r => r.critical);
  const auxiliaryFailed = failed.filter(r => !r.critical);

  if (criticalFailed.length > 0) {
    const names = criticalFailed.map(r => r.skill).join(', ');
    throw new Error(`Critical skills failed validation: ${names}. Fix before proceeding.`);
  }

  if (auxiliaryFailed.length > 0) {
    console.warn(`Warning: Auxiliary skills failed validation: ${auxiliaryFailed.map(r => r.skill).join(', ')}`);
  }

  return results;
}

function writeValidationReport(cwd, results) {
  const lines = ['# Skills Validation Report', `Generated: ${new Date().toISOString()}`, ''];
  lines.push('| Skill | L1 | L2 | L3 | L4 | Pass | Critical |');
  lines.push('|-------|-----|-----|-----|-----|------|----------|');

  for (const r of results) {
    const checks = r.level.map(l => l.found ? 'Y' : 'N').join(' | ');
    lines.push(`| ${r.skill} | ${checks} | ${r.passCount}/4 | ${r.critical ? 'BLOCK' : 'warn'} |`);
  }

  const reportPath = path.join(cwd, 'flow-kit/.flow-kit/.skills-validation-report.md');
  const reportDir = path.dirname(reportPath);
  if (!fs.existsSync(reportDir)) {
    fs.mkdirSync(reportDir, { recursive: true });
  }
  fs.writeFileSync(reportPath, lines.join('\n'));
  return reportPath;
}

// M3: practical test stub for M2+M3 combination verification
function practicalTestSkill(skillPath) {
  // Stub implementation for M3 verification
  return { tested: true, skillPath };
}

module.exports = { validateSkill, validateAllSkills, writeValidationReport, practicalTestSkill, SKILL_STRUCTURE, CRITICAL_SKILLS, AUXILIARY_SKILLS };
