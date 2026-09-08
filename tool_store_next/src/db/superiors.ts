import type { ResultSetHeader, RowDataPacket } from 'mysql2'
import { ApiParam } from '@/api/params'
import { backupRowBeforeChange } from '@/db/backup'
import { emptyToNull, newId, s } from '@/db/helpers'
import { getDbPool } from '@/db/pool'
import type { PaginatedList, SuperiorRow } from '@/types/models'
import { USER_PAGE_SIZE } from '@/types/models'

export type SuperiorListFilters = {
  page?: number
  limit?: number
  keyword?: string
  searchField?: string
}

export type SaveSuperiorInput = {
  superiorId?: string
  namaSuperior: string
  statusSuperior?: string
  username?: string
  namaUser?: string
}

export type SuperiorImportRow = {
  superiorId?: string
  namaSuperior: string
  statusSuperior?: string
  username?: string
  namaUser?: string
}

export type SuperiorImportResult = {
  inserted: number
  updated: number
  skipped: number
  errors: { row: number; message: string }[]
}

type SuperiorPacket = RowDataPacket & Record<string, unknown>

const SUPERIOR_LEVEL = 'SUPERIOR'
const LEVEL_SQL = `UPPER(TRIM(u.level)) = 'SUPERIOR'`

function displayNama(input: {
  namaSuperior?: string
  namaUser?: string
}): string {
  return (input.namaUser ?? '').trim() || (input.namaSuperior ?? '').trim()
}

function mapSuperior(row: SuperiorPacket): SuperiorRow {
  const nama = s(row.nama_user)
  return {
    superiorId: s(row.id_users),
    namaSuperior: nama,
    statusSuperior: s(row.status) || 'ACTIVE',
    username: s(row.username),
    namaUser: nama,
    idTu: s(row.id_tu),
  }
}

function statusValue(raw?: string): string {
  const v = (raw ?? '').trim().toUpperCase()
  return v === 'INACTIVE' ? 'INACTIVE' : 'ACTIVE'
}

export async function dbListSuperiors(
  filters: SuperiorListFilters = {},
): Promise<PaginatedList<SuperiorRow>> {
  const pool = getDbPool()
  const page = Math.max(1, filters.page ?? 1)
  const limit = Math.max(1, filters.limit ?? USER_PAGE_SIZE)
  const offset = (page - 1) * limit
  const where: string[] = [LEVEL_SQL]
  const params: unknown[] = []
  const kw = filters.keyword?.trim() ?? ''
  if (kw) {
    const field = (filters.searchField ?? 'all').trim()
    if (field === 'name' || field === 'nama') {
      where.push('u.nama_user LIKE ?')
      params.push(`%${kw}%`)
    } else if (field === 'username') {
      where.push('u.username LIKE ?')
      params.push(`%${kw}%`)
    } else if (field === 'status') {
      where.push('u.status LIKE ?')
      params.push(`%${kw}%`)
    } else if (field === 'id') {
      where.push('u.id_users LIKE ?')
      params.push(`%${kw}%`)
    } else {
      where.push(
        '(u.nama_user LIKE ? OR u.username LIKE ? OR u.id_users LIKE ?)',
      )
      params.push(`%${kw}%`, `%${kw}%`, `%${kw}%`)
    }
  }
  const whereSql = `WHERE ${where.join(' AND ')}`

  const [countRows] = await pool.query<RowDataPacket[]>(
    `SELECT COUNT(*) AS total FROM users u ${whereSql}`,
    params,
  )
  const [rows] = await pool.query<SuperiorPacket[]>(
    `SELECT
       u.id_users,
       u.username,
       u.nama_user,
       u.status,
       u.id_tu
     FROM users u
     ${whereSql}
     ORDER BY COALESCE(NULLIF(TRIM(u.nama_user), ''), u.username) ASC
     LIMIT ? OFFSET ?`,
    [...params, limit, offset],
  )

  return {
    items: rows.map(mapSuperior),
    total: Number(countRows[0]?.total ?? 0),
  }
}

export async function dbGetSuperiorById(
  superiorId: string,
): Promise<SuperiorRow | null> {
  const pool = getDbPool()
  const [rows] = await pool.query<SuperiorPacket[]>(
    `SELECT
       u.id_users,
       u.username,
       u.nama_user,
       u.status,
       u.id_tu
     FROM users u
     WHERE ${LEVEL_SQL} AND u.id_users = ?
     LIMIT 1`,
    [superiorId.trim()],
  )
  const row = rows[0]
  return row ? mapSuperior(row) : null
}

export async function dbMutateSuperior(
  param: string,
  input: SaveSuperiorInput,
): Promise<string> {
  const pool = getDbPool()
  const nama = displayNama(input)
  if (!nama) throw new Error('Nama superior wajib diisi')

  if (param === ApiParam.deleteSuperior) {
    const id = (input.superiorId ?? '').trim()
    if (!id) throw new Error('ID superior wajib')
    const [[used]] = await pool.query<RowDataPacket[]>(
      `SELECT COUNT(*) AS n FROM users
       WHERE superior_id = ? AND id_users <> ?`,
      [id, id],
    )
    if (Number(used?.n ?? 0) > 0) {
      throw new Error('Superior masih dipakai user lain')
    }
    await backupRowBeforeChange({
      tableName: 'users',
      recordId: id,
      action: 'DELETE',
    })
    const [r] = await pool.query<ResultSetHeader>(
      `DELETE FROM users
       WHERE id_users = ? AND UPPER(TRIM(level)) = 'SUPERIOR'`,
      [id],
    )
    if (r.affectedRows === 0) throw new Error('Superior tidak ditemukan')
    return 'Superior dihapus'
  }

  if (param === ApiParam.addSuperior) {
    const username = (input.username ?? '').trim()
    if (!username) throw new Error('Username wajib diisi')
    const [[dup]] = await pool.query<RowDataPacket[]>(
      `SELECT id_users FROM users WHERE username = ? LIMIT 1`,
      [username],
    )
    if (dup) throw new Error('Username sudah dipakai')
    const id = (input.superiorId ?? '').trim() || newId()
    await pool.query(
      `INSERT INTO users (
         id_users, username, password, nama_user, level, status
       ) VALUES (?, ?, ?, ?, ?, ?)`,
      [
        id,
        username,
        username,
        nama,
        SUPERIOR_LEVEL,
        statusValue(input.statusSuperior),
      ],
    )
    return id
  }

  if (param === ApiParam.editSuperior) {
    const id = (input.superiorId ?? '').trim()
    if (!id) throw new Error('ID superior wajib')
    const username = (input.username ?? '').trim()
    if (!username) throw new Error('Username wajib diisi')
    const [[dup]] = await pool.query<RowDataPacket[]>(
      `SELECT id_users FROM users WHERE username = ? AND id_users <> ? LIMIT 1`,
      [username, id],
    )
    if (dup) throw new Error('Username sudah dipakai')
    await backupRowBeforeChange({
      tableName: 'users',
      recordId: id,
      action: 'UPDATE',
    })
    const [r] = await pool.query<ResultSetHeader>(
      `UPDATE users SET
         username = ?,
         nama_user = ?,
         status = ?,
         level = ?
       WHERE id_users = ? AND UPPER(TRIM(level)) = 'SUPERIOR'`,
      [username, nama, statusValue(input.statusSuperior), SUPERIOR_LEVEL, id],
    )
    if (r.affectedRows === 0) throw new Error('Superior tidak ditemukan')
    return 'Superior diperbarui'
  }

  throw new Error(`Param superior tidak dikenal: ${param}`)
}

export async function dbImportSuperiors(
  rows: SuperiorImportRow[],
): Promise<SuperiorImportResult> {
  const pool = getDbPool()
  const result: SuperiorImportResult = {
    inserted: 0,
    updated: 0,
    skipped: 0,
    errors: [],
  }
  const conn = await pool.getConnection()
  try {
    await conn.beginTransaction()
    for (let i = 0; i < rows.length; i++) {
      const rowNum = i + 2
      const raw = rows[i]
      const nama = displayNama(raw)
      const username = (raw.username ?? '').trim()
      if (!nama) {
        result.skipped += 1
        result.errors.push({ row: rowNum, message: 'nama_superior kosong' })
        continue
      }
      if (!username) {
        result.skipped += 1
        result.errors.push({ row: rowNum, message: 'username kosong' })
        continue
      }
      try {
        const id = (raw.superiorId ?? '').trim()
        const [existing] = await conn.query<RowDataPacket[]>(
          id
            ? `SELECT id_users, username FROM users
               WHERE id_users = ? OR username = ? LIMIT 1`
            : `SELECT id_users, username FROM users WHERE username = ? LIMIT 1`,
          id ? [id, username] : [username],
        )
        const found = existing[0]
        if (found) {
          const recordId = String(found.id_users)
          await backupRowBeforeChange({
            tableName: 'users',
            recordId,
            action: 'UPDATE',
            conn,
          })
          await conn.query(
            `UPDATE users SET
               username = ?,
               nama_user = ?,
               status = ?,
               level = ?
             WHERE id_users = ?`,
            [
              username,
              nama,
              statusValue(raw.statusSuperior),
              SUPERIOR_LEVEL,
              recordId,
            ],
          )
          result.updated += 1
        } else {
          await conn.query(
            `INSERT INTO users (
               id_users, username, password, nama_user, level, status
             ) VALUES (?, ?, ?, ?, ?, ?)`,
            [
              id || newId(),
              username,
              username,
              nama,
              SUPERIOR_LEVEL,
              statusValue(raw.statusSuperior),
            ],
          )
          result.inserted += 1
        }
      } catch (e) {
        result.skipped += 1
        result.errors.push({
          row: rowNum,
          message: e instanceof Error ? e.message : String(e),
        })
      }
    }
    await conn.commit()
  } catch (e) {
    await conn.rollback()
    throw e
  } finally {
    conn.release()
  }
  return result
}
