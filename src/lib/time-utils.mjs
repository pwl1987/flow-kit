// time-utils.mjs — 时间工具函数
// v3.8.0 迁移自 lib/time-utils.sh

export function getEpochMs() {
  return Date.now();
}

export function dateToEpoch(dateStr) {
  if (!dateStr || dateStr === 'null' || dateStr === null) {
    return 0;
  }

  try {
    // Try ISO format first
    const date = new Date(dateStr);
    if (!isNaN(date.getTime())) {
      return date.getTime();
    }
    return 0;
  } catch {
    return 0;
  }
}

export function getTimestamp() {
  return new Date().toISOString();
}
