// security-scanner.mjs — 安全扫描器
// v3.8.0 迁移自 lib/security-scanner.sh

import { readFileSync, readdirSync, existsSync } from 'fs';
import { join, relative } from 'path';

const SECRET_PATTERNS = [
  { type: 'api_key', pattern: /sk-[a-zA-Z0-9]{32,}/ },
  { type: 'aws_key', pattern: /AKIA[0-9A-Z]{16}/ },
  { type: 'aws_secret', pattern: /[A-Za-z0-9/+=]{40}/ },
  { type: 'github_token', pattern: /ghp_[a-zA-Z0-9]{36}/ },
  { type: 'password', pattern: /password\s*[=:]\s*["'][^"']{3,}/i },
  { type: 'secret', pattern: /secret\s*[=:]\s*["'][^"']{3,}/i },
  { type: 'token', pattern: /token\s*[=:]\s*["'][^"']{3,}/i },
  { type: 'private_key', pattern: /-----BEGIN (RSA|DSA|EC|OPENSSH) PRIVATE KEY-----/ },
  { type: 'jwt', pattern: /eyJ[a-zA-Z0-9-_]+\.eyJ[a-zA-Z0-9-_]+/ },
];

const SQL_INJECTION_PATTERNS = [
  /".*"\s*\+\s*.*\s*\+\s*.*SELECT/i,
  /".*"\s*\+\s*.*\s*\+\s*.*INSERT/i,
  /".*"\s*\+\s*.*\s*\+\s*.*UPDATE/i,
  /".*"\s*\+\s*.*\s*\+\s*.*DELETE/i,
  /execute\s*\(\s*".*"\s*\+\s*/i,
];

const XSS_PATTERNS = [
  /innerHTML\s*=/,
  /document\.write\s*\(/,
  /\.html\s*\(\s*.*\s*\)/,
  /eval\s*\(\s*.*\s*\)/,
];

const DANGEROUS_SHELL_PATTERNS = [
  /rm\s+-rf\s+/,
  /eval\s+\$/,
  /\|\s*sh\s*$/,
  /;\s*rm\s+/,
  /wget\s+[^\s]+\s*\|\s*sh/,
  /curl\s+[^\s]+\s*\|\s*sh/,
];

function scanDir(dir, extensions = ['.js', '.mjs', '.sh', '.py', '.json', '.yaml', '.yml', '.ts']) {
  const results = [];
  
  function walk(currentDir) {
    try {
      const entries = readdirSync(currentDir, { withFileTypes: true });
      for (const entry of entries) {
        const fullPath = join(currentDir, entry.name);
        const relPath = relative(dir, fullPath);
        
        if (entry.isDirectory()) {
          if (entry.name === '.git' || entry.name === 'node_modules') continue;
          walk(fullPath);
        } else if (extensions.some(ext => entry.name.endsWith(ext))) {
          try {
            const content = readFileSync(fullPath, 'utf8');
            results.push({ path: fullPath, relPath, content });
          } catch {}
        }
      }
    } catch {}
  }
  
  walk(dir);
  return results;
}

export function scanSecrets(dir) {
  const files = scanDir(dir);
  const findings = [];
  
  for (const { path, relPath, content } of files) {
    const lines = content.split('\n');
    lines.forEach((line, idx) => {
      for (const { type, pattern } of SECRET_PATTERNS) {
        if (pattern.test(line)) {
          findings.push({
            file: relPath,
            line: idx + 1,
            severity: 'high',
            type,
            match: line.trim().substring(0, 80)
          });
        }
      }
    });
  }
  
  return findings;
}

export function scanSqlInjection(dir) {
  const files = scanDir(dir);
  const findings = [];
  
  for (const { path, relPath, content } of files) {
    const lines = content.split('\n');
    lines.forEach((line, idx) => {
      for (const pattern of SQL_INJECTION_PATTERNS) {
        if (pattern.test(line)) {
          findings.push({
            file: relPath,
            line: idx + 1,
            severity: 'high',
            type: 'sql_injection',
            match: line.trim().substring(0, 80)
          });
        }
      }
    });
  }
  
  return findings;
}

export function scanXss(dir) {
  const files = scanDir(dir, ['.js', '.mjs', '.html']);
  const findings = [];
  
  for (const { path, relPath, content } of files) {
    const lines = content.split('\n');
    lines.forEach((line, idx) => {
      for (const pattern of XSS_PATTERNS) {
        if (pattern.test(line)) {
          findings.push({
            file: relPath,
            line: idx + 1,
            severity: 'medium',
            type: 'xss',
            match: line.trim().substring(0, 80)
          });
        }
      }
    });
  }
  
  return findings;
}

export function scanDangerousShell(dir) {
  const files = scanDir(dir, ['.sh', '.bash']);
  const findings = [];
  
  for (const { path, relPath, content } of files) {
    const lines = content.split('\n');
    lines.forEach((line, idx) => {
      for (const pattern of DANGEROUS_SHELL_PATTERNS) {
        if (pattern.test(line)) {
          findings.push({
            file: relPath,
            line: idx + 1,
            severity: 'high',
            type: 'dangerous_shell',
            match: line.trim().substring(0, 80)
          });
        }
      }
    });
  }
  
  return findings;
}
