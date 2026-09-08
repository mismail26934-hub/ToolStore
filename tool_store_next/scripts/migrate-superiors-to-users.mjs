/**
 * One-shot: copy superiors into users (level SUPERIOR), remap users.superior_id
 * (and forms.superior_id if present) to users.id_users, then drop superiors.
 *
 * Usage: node scripts/migrate-superiors-to-users.mjs [--drop]
 */
import crypto from 'node:crypto'
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import mysql from 'mysql2/promise'

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..')
const dropTable = process.argv.includes('--drop')

function loadEnvFile(filePath) {
  if (!fs.existsSync(filePath)) return
  for (const line of fs.readFileSync(filePath, 'utf8').split(/\r?\n/)) {
    const trimmed = line.trim()
    if (!trimmed || trimmed.startsWith('#')) continue
    const eq = trimmed.indexOf('=')
    if (eq < 1) continue
    const key = trimmed.slice(0, eq).trim()
    let value = trimmed.slice(eq + 1).trim()
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1)
    }
    if (process.env[key] == null || process.env[key] === '') {
      process.env[key] = value
    }
  }
}

loadEnvFile(path.join(root, '.env.local'))
loadEnvFile(path.join(root, '.env'))

function dbConfig() {
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

function validUsername(raw) {
  const v = String(raw ?? '').trim()
  return v && v !== '-' ? v : ''
}

function slugUsername(name, fallbackId) {
  const slug = String(name ?? '')
    .trim()
    .toLowerCase()
    .normalize('NFKD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '.')
    .replace(/^\.|\.$/g, '')
  return slug || fallbackId
}

async function uniqueUsername(conn, base) {
  let candidate = base
  let n = 1
  for (;;) {
    const [[hit]] = await conn.query(
      `SELECT id_users FROM users WHERE username = ? LIMIT 1`,
      [candidate],
    )
    if (!hit) return candidate
    n += 1
    candidate = `${base}.${n}`
  }
}

async function insertUserFromSuperior(conn, row, userCols) {
  let username = validUsername(row.username)
  const nama =
    validUsername(row.nama_user) ||
    validUsername(row.nama_superior) ||
    username
  if (!nama && !username) return false
  if (!username) {
    username = await uniqueUsername(
      conn,
      slugUsername(nama, row.superior_id),
    )
  }
  const status =
    String(row.status_superior ?? 'ACTIVE').trim().toUpperCase() === 'INACTIVE'
      ? 'INACTIVE'
      : 'ACTIVE'
  const [[taken]] = await conn.query(
    `SELECT id_users FROM users WHERE id_users = ? LIMIT 1`,
    [row.superior_id],
  )
  const idUsers = taken ? crypto.randomUUID() : row.superior_id
  const cols = [
    'id_users',
    'username',
    'password',
    'nama_user',
    'level',
    'status',
  ]
  const vals = [idUsers, username, username, nama || username, 'SUPERIOR', status]
  if (userCols.has('superior_id')) {
    cols.push('superior_id')
    vals.push(null)
  }
  const placeholders = cols.map(() => '?').join(', ')
  await conn.query(
    `INSERT INTO users (${cols.join(', ')}) VALUES (${placeholders})`,
    vals,
  )
  return true
}

async function tableExists(conn, name) {
  const [rows] = await conn.query(
    `SELECT 1 FROM information_schema.tables
     WHERE table_schema = DATABASE() AND table_name = ? LIMIT 1`,
    [name],
  )
  return rows.length > 0
}

async function columnExists(conn, table, column) {
  const [rows] = await conn.query(
    `SELECT 1 FROM information_schema.columns
     WHERE table_schema = DATABASE() AND table_name = ? AND column_name = ?
     LIMIT 1`,
    [table, column],
  )
  return rows.length > 0
}

async function main() {
  const cfg = dbConfig()
  const conn = await mysql.createConnection({
    host: cfg.host,
    port: cfg.port,
    user: cfg.user,
    password: cfg.password,
    database: cfg.database,
    multipleStatements: true,
  })

  try {
    if (!(await tableExists(conn, 'superiors'))) {
      console.log('Table superiors already gone. Nothing to migrate.')
      if (dropTable) console.log('--drop ignored')
      return
    }

    const [schemaUsers] = await conn.query('DESCRIBE users')
    const userCols = new Set(schemaUsers.map((r) => r.Field))
    console.log('users columns:', [...userCols].join(', '))

    const hasFormsSuperior =
      (await tableExists(conn, 'forms')) &&
      (await columnExists(conn, 'forms', 'superior_id'))

    const [[{ n: superiorCount }]] = await conn.query(
      'SELECT COUNT(*) AS n FROM superiors',
    )
    const [[{ n: matchCount }]] = await conn.query(
      `SELECT COUNT(*) AS n
       FROM superiors s
       INNER JOIN users u ON TRIM(u.username) = TRIM(s.username)
       WHERE TRIM(s.username) <> '' AND TRIM(s.username) <> '-'`,
    )
    const [[{ n: insertCount }]] = await conn.query(
      `SELECT COUNT(*) AS n
       FROM superiors s
       LEFT JOIN users u
         ON (TRIM(s.username) <> '' AND TRIM(s.username) <> '-' AND TRIM(u.username) = TRIM(s.username))
         OR u.id_users = s.superior_id
       WHERE u.id_users IS NULL
         AND TRIM(IFNULL(s.username, '')) <> '' AND TRIM(s.username) <> '-'`,
    )
    const [[{ n: skipCount }]] = await conn.query(
      `SELECT COUNT(*) AS n FROM superiors s
       WHERE TRIM(IFNULL(s.username, '')) = '' OR TRIM(s.username) = '-'`,
    )

    console.log({
      superiors: Number(superiorCount),
      willUpdateLevel: Number(matchCount),
      willInsert: Number(insertCount),
      skippedBlankUsername: Number(skipCount),
      willRemapForms: hasFormsSuperior,
    })

    await conn.beginTransaction()

    const [upd] = await conn.query(
      `UPDATE users u
       INNER JOIN superiors s ON TRIM(s.username) = TRIM(u.username)
       SET u.level = 'SUPERIOR'
       WHERE TRIM(s.username) <> '' AND TRIM(s.username) <> '-'`,
    )
    console.log('updated level SUPERIOR:', upd.affectedRows)

    const [toInsert] = await conn.query(
      `SELECT s.superior_id, s.username, s.nama_user, s.nama_superior, s.status_superior
       FROM superiors s
       LEFT JOIN users u
         ON (TRIM(s.username) <> '' AND TRIM(s.username) <> '-' AND TRIM(u.username) = TRIM(s.username))
         OR u.id_users = s.superior_id
       WHERE u.id_users IS NULL`,
    )

    let inserted = 0
    for (const row of toInsert) {
      if (await insertUserFromSuperior(conn, row, userCols)) inserted += 1
    }
    console.log('inserted new SUPERIOR users:', inserted)

    const remapMapSql = `
      SELECT s.superior_id AS old_id, su.id_users AS new_id
      FROM superiors s
      INNER JOIN users su ON TRIM(su.username) = TRIM(s.username)
      WHERE TRIM(s.username) <> '' AND TRIM(s.username) <> '-'
      UNION
      SELECT s.superior_id, su.id_users
      FROM superiors s
      INNER JOIN users su ON su.id_users = s.superior_id
    `

    const [remapUsers] = await conn.query(
      `UPDATE users u
       INNER JOIN (${remapMapSql}) m ON m.old_id = u.superior_id
       SET u.superior_id = m.new_id
       WHERE m.new_id IS NOT NULL AND u.superior_id <> m.new_id`,
    )
    console.log('remapped users.superior_id:', remapUsers.affectedRows)

    if (hasFormsSuperior) {
      const [remapForms] = await conn.query(
        `UPDATE forms f
         INNER JOIN (${remapMapSql}) m ON m.old_id = f.superior_id
         SET f.superior_id = m.new_id
         WHERE m.new_id IS NOT NULL AND f.superior_id <> m.new_id`,
      )
      console.log('remapped forms.superior_id:', remapForms.affectedRows)
    }

    const [dangling] = await conn.query(
      `SELECT u.id_users, u.username, u.nama_user, u.superior_id
       FROM users u
       LEFT JOIN users su ON su.id_users = u.superior_id
       WHERE u.superior_id IS NOT NULL
         AND TRIM(u.superior_id) <> ''
         AND TRIM(u.superior_id) <> '-'
         AND su.id_users IS NULL`,
    )
    if (dangling.length) {
      console.log('clearing dangling superior_id:', dangling)
      await conn.query(
        `UPDATE users u
         LEFT JOIN users su ON su.id_users = u.superior_id
         SET u.superior_id = NULL
         WHERE u.superior_id IS NOT NULL
           AND TRIM(u.superior_id) <> ''
           AND TRIM(u.superior_id) <> '-'
           AND su.id_users IS NULL`,
      )
    }
    const [[{ n: superiorUsers }]] = await conn.query(
      `SELECT COUNT(*) AS n FROM users WHERE UPPER(TRIM(level)) = 'SUPERIOR'`,
    )
    console.log({ superiorUsers: Number(superiorUsers) })

    if (dropTable) {
      await conn.query('SET FOREIGN_KEY_CHECKS = 0')
      await conn.query('DROP TABLE IF EXISTS superiors')
      await conn.query('SET FOREIGN_KEY_CHECKS = 1')
      console.log('dropped table superiors')
    }

    await conn.commit()
    console.log(dropTable ? 'migration + drop committed' : 'migration committed')
  } catch (e) {
    await conn.rollback()
    throw e
  } finally {
    await conn.end()
  }
}

main().catch((e) => {
  console.error(e)
  process.exit(1)
})
