import mysql from 'mysql2/promise'

export type DbConfig = {
  host: string
  port: number
  user: string
  password: string
  database: string
}

function readConfig(): DbConfig {
  const url = process.env.DATABASE_URL?.trim()
  if (url) {
    const parsed = new URL(url)
    return {
      host: parsed.hostname || '127.0.0.1',
      port: Number(parsed.port || 3306),
      user: decodeURIComponent(parsed.username || 'root'),
      password: decodeURIComponent(parsed.password || ''),
      database: parsed.pathname.replace(/^\//, '') || 'toolstore',
    }
  }

  return {
    host: process.env.DATABASE_HOST?.trim() || '127.0.0.1',
    port: Number(process.env.DATABASE_PORT || 3306),
    user: process.env.DATABASE_USER?.trim() || 'root',
    password: process.env.DATABASE_PASSWORD ?? '',
    database: process.env.DATABASE_NAME?.trim() || 'toolstore',
  }
}

declare global {
  // eslint-disable-next-line no-var
  var __toolstoreMysqlPool: mysql.Pool | undefined
}

export function getDbPool(): mysql.Pool {
  if (global.__toolstoreMysqlPool) return global.__toolstoreMysqlPool

  const cfg = readConfig()
  const pool = mysql.createPool({
    host: cfg.host,
    port: cfg.port,
    user: cfg.user,
    password: cfg.password,
    database: cfg.database,
    waitForConnections: true,
    connectionLimit: 10,
    namedPlaceholders: true,
    timezone: 'Z',
  })

  global.__toolstoreMysqlPool = pool
  return pool
}

export function getDbConfig(): DbConfig {
  return readConfig()
}
