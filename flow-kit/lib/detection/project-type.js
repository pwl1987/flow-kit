const fs = require('fs');
const path = require('path');

const WHITELIST = [
  'tsconfig.json', 'jsconfig.json', '.gitignore', '.eslintrc', '.prettierrc',
  'package.json', 'requirements.txt', 'Pipfile', 'pyproject.toml',
  'README.md', 'LICENSE', 'CHANGELOG.md', '.DS_Store', 'Thumbs.db'
];

const CONFIG_EXTENSIONS = ['.config.js', '.config.ts', '.config.json', '.yaml', '.yml'];

const CODE_EXTENSIONS = ['.ts', '.js', '.jsx', '.tsx', '.py', '.java', '.go', '.rs', '.php'];

const SKIP_DIRS = ['node_modules', '.git', 'dist', 'build', '__pycache__', '.svn', '.hg'];

const BROWNFIELD_LINE_THRESHOLD = 1000;

function countBusinessCode(cwd, whitelist) {
  let totalLines = 0;

  function walkDir(dir) {
    let entries;
    try {
      entries = fs.readdirSync(dir, { withFileTypes: true });
    } catch (e) {
      console.warn(`Failed to read directory: ${dir}`, e);
      return;
    }

    for (const entry of entries) {
      const fullPath = path.join(dir, entry.name);

      if (entry.isDirectory()) {
        if (SKIP_DIRS.includes(entry.name) || entry.name.startsWith('.')) {
          continue;
        }
        walkDir(fullPath);
      } else if (entry.isFile()) {
        if (whitelist.includes(entry.name)) {
          continue;
        }

        const ext = path.extname(entry.name);
        if (CONFIG_EXTENSIONS.includes(ext)) {
          continue;
        }

        if (!CODE_EXTENSIONS.includes(ext)) {
          continue;
        }

        try {
          const content = fs.readFileSync(fullPath, 'utf8');
          const lines = content.split('\n').length;
          totalLines += lines;
        } catch (e) {
          console.warn(`Failed to read file: ${fullPath}`, e);
        }
      }
    }
  }

  walkDir(cwd);
  return totalLines;
}

function detectProjectType(cwd) {
  const signals = [];
  const resolvedCwd = path.resolve(cwd);

  // Check .git/ exists
  if (fs.existsSync(path.join(resolvedCwd, '.git'))) {
    signals.push('.git exists');
  }

  // Check lock files
  const lockFiles = ['package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'Gemfile.lock'];
  for (const lockFile of lockFiles) {
    if (fs.existsSync(path.join(resolvedCwd, lockFile))) {
      signals.push(`lock: ${lockFile}`);
    }
  }

  // Check git remote
  const gitConfigPath = path.join(resolvedCwd, '.git', 'config');
  if (fs.existsSync(gitConfigPath)) {
    try {
      const gitConfig = fs.readFileSync(gitConfigPath, 'utf8');
      if (/\[remote\s+"origin"\]/i.test(gitConfig)) {
        signals.push('git remote configured');
      }
    } catch {
      // Ignore
    }
  }

  // Count business code lines
  const businessLines = countBusinessCode(resolvedCwd, WHITELIST);
  signals.push(`business_code_lines: ${businessLines}`);

  // Determine project type
  const isBrownfield = businessLines > BROWNFIELD_LINE_THRESHOLD || signals.some(s => s.startsWith('lock:'));
  if (isBrownfield) {
    signals.push('threshold: brownfield');
  } else {
    signals.push('threshold: greenfield');
  }

  return { isBrownfield, signals, businessLines };
}

function writeProjectTypeFile(cwd, result) {
  const content = [
    `project_type: ${result.isBrownfield ? 'brownfield' : 'greenfield'}`,
    `detected_at: ${new Date().toISOString()}`,
    `detection_signals: ${result.signals.join(', ')}`,
    `business_code_lines: ${result.businessLines}`
  ].join('\n');

  const dir = path.join(cwd, '.flow-kit');
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(path.join(dir, 'project-type'), content, 'utf8');
}

module.exports = {
  WHITELIST,
  CONFIG_EXTENSIONS,
  CODE_EXTENSIONS,
  detectProjectType,
  countBusinessCode,
  writeProjectTypeFile
};