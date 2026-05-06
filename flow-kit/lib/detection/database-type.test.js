const fs = require('fs');
const path = require('path');
const { detectDatabaseType, DATABASE_TYPES, DETECTION_METHODS } = require('./database-type.js');

const TEST_DIR = '/tmp/test-db-detection';

function setup() {
  fs.rmSync(TEST_DIR, { recursive: true, force: true });
  fs.mkdirSync(TEST_DIR, { recursive: true });
  fs.mkdirSync(path.join(TEST_DIR, '.flow-kit'), { recursive: true });
}

function testExports() {
  console.log('Test: exports present');
  const ok = typeof detectDatabaseType === 'function';
  console.log(ok ? 'PASS' : 'FAIL');
  return ok;
}

function testDatabaseTypesConstant() {
  console.log('Test: DATABASE_TYPES constant');
  const ok = Object.values(DATABASE_TYPES).includes('mysql') &&
             Object.values(DATABASE_TYPES).includes('postgresql') &&
             Object.values(DATABASE_TYPES).includes('mongodb') &&
             Object.values(DATABASE_TYPES).includes('sqlite');
  console.log(ok ? 'PASS' : 'FAIL');
  return ok;
}

function testPrismaDetection() {
  console.log('Test: Prisma detection');
  const prismaDir = path.join(TEST_DIR, 'prisma');
  fs.mkdirSync(prismaDir, { recursive: true });
  fs.writeFileSync(path.join(prismaDir, 'schema.prisma'), 'datasource db { provider = "postgresql" }', 'utf8');

  const result = detectDatabaseType(TEST_DIR);
  const ok = result.databaseType === DATABASE_TYPES.POSTGRESQL && result.method === DETECTION_METHODS.ORM_CONFIG;
  console.log(ok ? 'PASS' : 'FAIL', JSON.stringify(result));
  return ok;
}

function testSequelizeDetection() {
  console.log('Test: Sequelize detection');
  // Clear any existing Prisma files
  const prismaPath = path.join(TEST_DIR, 'prisma');
  fs.rmSync(prismaPath, { recursive: true, force: true });
  // Clear marker file
  const markerPath = path.join(TEST_DIR, '.flow-kit', 'database-type');
  fs.rmSync(markerPath, { force: true });

  const configDir = path.join(TEST_DIR, 'config');
  fs.mkdirSync(configDir, { recursive: true });
  fs.writeFileSync(path.join(configDir, 'database.js'), 'module.exports = { dialect: "mysql" }', 'utf8');

  const result = detectDatabaseType(TEST_DIR);
  const ok = result.databaseType === DATABASE_TYPES.MYSQL && result.method === DETECTION_METHODS.ORM_CONFIG;
  console.log(ok ? 'PASS' : 'FAIL', JSON.stringify(result));
  return ok;
}

function testMarkerFileWritten() {
  console.log('Test: marker file written');
  const markerPath = path.join(TEST_DIR, '.flow-kit', 'database-type');
  const ok = fs.existsSync(markerPath);
  if (ok) {
    const content = fs.readFileSync(markerPath, 'utf8');
    const parts = content.split('/');
    console.log('PASS - content:', content);
    console.log('  parts:', parts.length, '(expected 4)');
  } else {
    console.log('FAIL');
  }
  return ok;
}

function run() {
  setup();
  let passed = 0;
  let failed = 0;

  testExports() ? passed++ : failed++;
  testDatabaseTypesConstant() ? passed++ : failed++;
  testPrismaDetection() ? passed++ : failed++;
  testSequelizeDetection() ? passed++ : failed++;
  testMarkerFileWritten() ? passed++ : failed++;

  console.log('\nResults:', passed, 'passed,', failed, 'failed');
  process.exit(failed > 0 ? 1 : 0);
}

run();
