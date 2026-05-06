const fs = require('fs');
const path = require('path');

const DATABASE_TYPES = {
  MYSQL: 'mysql',
  POSTGRESQL: 'postgresql',
  MONGODB: 'mongodb',
  SQLITE: 'sqlite',
  MSSQL: 'mssql',
  ELASTICSEARCH: 'elasticsearch'
};

const DETECTION_METHODS = {
  ORM_CONFIG: 'orm_config',
  CONNECTION_STRING: 'connection_string',
  FILE_EXTENSION: 'file_extension',
  UNKNOWN: 'unknown'
};

function detectPrisma(schemaPath) {
  try {
    if (!fs.existsSync(schemaPath)) return null;
    const content = fs.readFileSync(schemaPath, 'utf8');
    const provider = content.match(/provider\s*=\s*"(\w+)"/)?.[1];
    const PROVIDER_MAP = {
      'mysql': DATABASE_TYPES.MYSQL,
      'postgresql': DATABASE_TYPES.POSTGRESQL,
      'mongodb': DATABASE_TYPES.MONGODB,
      'sqlite': DATABASE_TYPES.SQLITE,
      'sqlserver': DATABASE_TYPES.MSSQL
    };
    return PROVIDER_MAP[provider] || null;
  } catch {
    return null;
  }
}

function detectSequelize(configPath) {
  try {
    if (!fs.existsSync(configPath)) return null;
    const content = fs.readFileSync(configPath, 'utf8');
    const dialect = content.match(/dialect:\s*['"](\w+)['"]/)?.[1];
    if (!dialect) return null;
    const DIALECT_MAP = {
      'mysql': DATABASE_TYPES.MYSQL,
      'postgres': DATABASE_TYPES.POSTGRESQL,
      'postgresql': DATABASE_TYPES.POSTGRESQL,
      'sqlite': DATABASE_TYPES.SQLITE,
      'mssql': DATABASE_TYPES.MSSQL,
      'mongodb': DATABASE_TYPES.MONGODB
    };
    return DIALECT_MAP[dialect.toLowerCase()] || null;
  } catch {
    return null;
  }
}

function detectTypeORM(configPath) {
  try {
    if (!fs.existsSync(configPath)) return null;
    const content = fs.readFileSync(configPath, 'utf8');
    const type = content.match(/type:\s*['"](\w+)['"]/)?.[1];
    if (!type) return null;
    const TYPE_MAP = {
      'mysql': DATABASE_TYPES.MYSQL,
      'postgres': DATABASE_TYPES.POSTGRESQL,
      'postgresql': DATABASE_TYPES.POSTGRESQL,
      'sqlite': DATABASE_TYPES.SQLITE,
      'mssql': DATABASE_TYPES.MSSQL,
      'mongodb': DATABASE_TYPES.MONGODB
    };
    return TYPE_MAP[type.toLowerCase()] || null;
  } catch {
    return null;
  }
}

function detectKnex(configPath) {
  try {
    if (!fs.existsSync(configPath)) return null;
    const content = fs.readFileSync(configPath, 'utf8');
    const client = content.match(/client:\s*['"](\w+)['"]/)?.[1];
    if (!client) return null;
    const CLIENT_MAP = {
      'pg': DATABASE_TYPES.POSTGRESQL,
      'mysql': DATABASE_TYPES.MYSQL,
      'mysql2': DATABASE_TYPES.MYSQL,
      'sqlite3': DATABASE_TYPES.SQLITE,
      'mssql': DATABASE_TYPES.MSSQL,
      'mongodb': DATABASE_TYPES.MONGODB
    };
    return CLIENT_MAP[client.toLowerCase()] || null;
  } catch {
    return null;
  }
}

function detectFromConnectionString(connString) {
  if (!connString) return null;
  const CONN_MAP = {
    'mysql': DATABASE_TYPES.MYSQL,
    'postgres': DATABASE_TYPES.POSTGRESQL,
    'postgresql': DATABASE_TYPES.POSTGRESQL,
    'mongodb': DATABASE_TYPES.MONGODB,
    'sqlite': DATABASE_TYPES.SQLITE,
    'mssql': DATABASE_TYPES.MSSQL,
    'sqlserver': DATABASE_TYPES.MSSQL
  };
  for (const [key, dbType] of Object.entries(CONN_MAP)) {
    if (connString.includes(key)) return dbType;
  }
  return null;
}

function detectFromFileExtension(filePath) {
  const ext = path.extname(filePath).toLowerCase();
  const EXT_MAP = {
    '.sqlite': DATABASE_TYPES.SQLITE,
    '.sqlite3': DATABASE_TYPES.SQLITE,
    '.db': DATABASE_TYPES.SQLITE
  };
  return EXT_MAP[ext] || null;
}

function writeDatabaseTypeFile(projectRoot, dbType, method, confidence) {
  const markerPath = path.join(projectRoot, '.flow-kit', 'database-type');
  const detectedAt = new Date().toISOString();
  const line = `${dbType}/${detectedAt}/${method}/${confidence}`;
  fs.writeFileSync(markerPath, line, 'utf8');
  return markerPath;
}

function detectDatabaseType(projectRoot) {
  projectRoot = projectRoot || process.cwd();

  // E1: ORM config files (highest priority)
  const ormConfigs = [
    { path: path.join(projectRoot, 'prisma', 'schema.prisma'), fn: detectPrisma },
    { path: path.join(projectRoot, 'prisma.schema.prisma'), fn: detectPrisma },
    { path: path.join(projectRoot, 'config', 'database.js'), fn: detectSequelize },
    { path: path.join(projectRoot, 'config', 'database.ts'), fn: detectSequelize },
    { path: path.join(projectRoot, 'database.json'), fn: detectTypeORM },
    { path: path.join(projectRoot, 'ormconfig.json'), fn: detectTypeORM },
    { path: path.join(projectRoot, 'knexfile.js'), fn: detectKnex },
    { path: path.join(projectRoot, 'knexfile.ts'), fn: detectKnex }
  ];

  for (const cfg of ormConfigs) {
    const result = cfg.fn(cfg.path);
    if (result) {
      writeDatabaseTypeFile(projectRoot, result, DETECTION_METHODS.ORM_CONFIG, 'high');
      return { databaseType: result, method: DETECTION_METHODS.ORM_CONFIG, confidence: 'high' };
    }
  }

  // E2: Connection string in environment or config files
  const envPaths = [
    path.join(projectRoot, '.env'),
    path.join(projectRoot, '.env.local'),
    path.join(projectRoot, '.env.development'),
    path.join(projectRoot, 'config', 'env.js')
  ];

  for (const envPath of envPaths) {
    if (fs.existsSync(envPath)) {
      const content = fs.readFileSync(envPath, 'utf8');
      const connMatch = content.match(/(?:DATABASE_URL|DB_HOST|DB_CONNECTION|POSTGRES_URL|MONGO_URL|MYSQL_URL)=(.*)/)?.[1];
      if (connMatch) {
        const dbType = detectFromConnectionString(connMatch);
        if (dbType) {
          writeDatabaseTypeFile(projectRoot, dbType, DETECTION_METHODS.CONNECTION_STRING, 'medium');
          return { databaseType: dbType, method: DETECTION_METHODS.CONNECTION_STRING, confidence: 'medium' };
        }
      }
    }
  }

  // E3: File extension (lowest priority)
  const dbFilePatterns = [
    path.join(projectRoot, '**', '*.sqlite'),
    path.join(projectRoot, '**', '*.sqlite3'),
    path.join(projectRoot, '**', '*.db')
  ];

  for (const pattern of dbFilePatterns) {
    const matches = fs.readdirSync(projectRoot, { recursive: true }).filter(f => f.endsWith('.sqlite') || f.endsWith('.sqlite3') || f.endsWith('.db'));
    if (matches.length > 0) {
      writeDatabaseTypeFile(projectRoot, DATABASE_TYPES.SQLITE, DETECTION_METHODS.FILE_EXTENSION, 'low');
      return { databaseType: DATABASE_TYPES.SQLITE, method: DETECTION_METHODS.FILE_EXTENSION, confidence: 'low' };
    }
  }

  // Fallback: unknown
  writeDatabaseTypeFile(projectRoot, 'unknown', DETECTION_METHODS.UNKNOWN, 'none');
  return { databaseType: 'unknown', method: DETECTION_METHODS.UNKNOWN, confidence: 'none' };
}

module.exports = {
  detectDatabaseType,
  DATABASE_TYPES,
  DETECTION_METHODS
};
