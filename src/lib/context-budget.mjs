// context-budget.mjs — 上下文预算管理
// v3.8.0 迁移自 lib/context-budget.sh

const DEFAULT_BUDGET = 100000;

// 中文字符检测（Unicode 范围）
function isChinese(char) {
  const code = char.charCodeAt(0);
  return (code >= 0x4E00 && code <= 0x9FFF) ||
         (code >= 0x3400 && code <= 0x4DBF) ||
         (code >= 0x20000 && code <= 0x2A6DF);
}

// 英文字符检测
function isEnglish(char) {
  const code = char.charCodeAt(0);
  return (code >= 0x41 && code <= 0x5A) ||
         (code >= 0x61 && code <= 0x7A);
}

// 估算文本 token 数量
// 英文约 4 字符/token，中文约 1.5 字符/token
export function estimateTokens(text) {
  if (!text || typeof text !== 'string') return 0;
  if (text.length === 0) return 0;

  let englishChars = 0;
  let chineseChars = 0;

  for (const char of text) {
    if (isChinese(char)) {
      chineseChars++;
    } else if (isEnglish(char)) {
      englishChars++;
    } else {
      // 其他字符按中文估算
      chineseChars++;
    }
  }

  const englishTokens = Math.ceil(englishChars / 4);
  const chineseTokens = Math.ceil(chineseChars / 1.5);

  return englishTokens + chineseTokens;
}

// 检查预算使用情况
export function checkBudget(used, total = DEFAULT_BUDGET) {
  const percent = total > 0 ? Math.round((used / total) * 100) : 0;
  
  let status = 'ok';
  if (percent >= 95) {
    status = 'critical';
  } else if (percent >= 80) {
    status = 'warning';
  }

  return {
    used,
    total,
    percent,
    status
  };
}

// 获取目录的预算状态
export function getBudgetStatus(dir) {
  // Placeholder - would scan files in directory
  return {
    dir,
    totalTokens: 0,
    fileCount: 0
  };
}

// 触发上下文压缩
export function triggerCompress(reason) {
  return {
    action: 'compress',
    reason,
    timestamp: new Date().toISOString(),
    suggestions: [
      '移除冗余注释',
      '合并短小函数',
      '简化条件表达式'
    ]
  };
}
