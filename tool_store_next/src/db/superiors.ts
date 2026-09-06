import type { ResultSetHeader, RowDataPacket } from 'mysql2'
import { ApiParam } from '@/api/params'
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

function mapSuperior(row: SuperiorPacket): SuperiorRow {
  return {
    superiorId: s(row.superior_id),
    namaSuperior: s(row.nama_superior),
    statusSuperior: s(row.status_superior),
    username: s(row.username),
    namaUser: s(row.nama_user),
    idTu: s(row.id_tu),
  }
}

export async function dbListSuperiors(
  filters: SuperiorListFilters = {},
): Promise<PaginatedList<SuperiorRow>> {
  const pool = getDbPool()
  const page = Math.max(1, filters.page ?? 1)
  const limit = Math.max(1, filters.limit ?? USER_PAGE_SIZE)
  const offset = (page - 1) * limit
  const where: string[] = []
  const params: unknown[] = []
  const kw = filters.keyword?.trim() ?? ''
  if (kw) {
    const field = (filters.searchField ?? 'all').trim()
    if (field === 'name' || field === 'nama') {
      where.push('s.nama_superior LIKE ?')
      params.push(`%${kw}%`)
    } else if (field === 'username') {
      where.push('s.username LIKE ?')
      params.push(`%${kw}%`)
    } else if (field === 'status') {
      where.push('s.status_superior LIKE ?')
      params.push(`%${kw}%`)
    } else if (field === 'id') {
      where.push('s.superior_id LIKE ?')
      params.push(`%${kw}%`)
    } else {
      where.push(
        '(s.nama_superior LIKE ? OR s.username LIKE ? OR s.nama_user LIKE ? OR s.superior_id LIKE ?)',
      )
      params.push(`%${kw}%`, `%${kw}%`, `%${kw}%`, `%${kw}%`)
    }
  }
  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : ''

  const [countRows] = await pool.query<RowDataPacket[]>(
    `SELECT COUNT(*) AS total FROM superiors s ${whereSql}`,
    params,
  )
  const [rows] = await pool.query<SuperiorPacket[]>(
    `SELECT
       s.superior_id,
       s.nama_superior,
       s.status_superior,
       s.username,
       COALESCE(NULLIF(TRIM(s.nama_user), ''), NULLIF(TRIM(u.nama_user), ''), '') AS nama_user,
       COALESCE(NULLIF(TRIM(u.id_tu), ''), '') AS id_tu
     FROM superiors s
     LEFT JOIN users u
       ON u.id_users = s.superior_id
       OR (NULLIF(TRIM(s.username), '') IS NOT NULL AND u.username = s.username)
     ${whereSql}
     ORDER BY
       COALESCE(NULLIF(TRIM(s.nama_user), ''), NULLIF(TRIM(u.nama_user), ''), s.nama_superior) ASC
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
       s.superior_id,
       s.nama_superior,
       s.status_superior,
       s.username,
       COALESCE(NULLIF(TRIM(s.nama_user), ''), NULLIF(TRIM(u.nama_user), ''), '') AS nama_user,
       COALESCE(NULLIF(TRIM(u.id_tu), ''), '') AS id_tu
     FROM superiors s
     LEFT JOIN users u
       ON u.id_users = s.superior_id
       OR (NULLIF(TRIM(s.username), '') IS NOT NULL AND u.username = s.username)
     WHERE s.superior_id = ?
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
  const nama = input.namaSuperior.trim()
  if (!nama) throw new Error('Nama superior wajib diisi')

  if (param === ApiParam.deleteSuperior) {
    const id = (input.superiorId ?? '').trim()
    if (!id) throw new Error('ID superior wajib')
    const [r] = await pool.query<ResultSetHeader>(
      `DELETE FROM superiors WHERE superior_id = ?`,
      [id],
    )
    if (r.affectedRows === 0) throw new Error('Superior tidak ditemukan')
    return 'Superior dihapus'
  }

  if (param === ApiParam.addSuperior) {
    const id = (input.superiorId ?? '').trim() || newId()
    await pool.query(
      `INSERT INTO superiors (
         superior_id, nama_superior, status_superior, username, nama_user
       ) VALUES (?, ?, ?, ?, ?)`,
      [
        id,
        nama,
        emptyToNull(input.statusSuperior) ?? 'ACTIVE',
        emptyToNull(input.username),
        emptyToNull(input.namaUser),
      ],
    )
    return id
  }

  if (param === ApiParam.editSuperior) {
    const id = (input.superiorId ?? '').trim()
    if (!id) throw new Error('ID superior wajib')
    const [r] = await pool.query<ResultSetHeader>(
      `UPDATE superiors SET
         nama_superior = ?,
         status_superior = ?,
         username = ?,
         nama_user = ?
       WHERE superior_id = ?`,
      [
        nama,
        emptyToNull(input.statusSuperior) ?? 'ACTIVE',
        emptyToNull(input.username),
        emptyToNull(input.namaUser),
        id,
      ],
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
      const rowNum = i + 2 // header is row 1
      const raw = rows[i]
      const nama = (raw.namaSuperior ?? '').trim()
      if (!nama) {
        result.skipped += 1
        result.errors.push({ row: rowNum, message: 'nama_superior kosong' })
        continue
      }
      try {
        const id = (raw.superiorId ?? '').trim()
        if (id) {
          const [existing] = await conn.query<RowDataPacket[]>(
            `SELECT superior_id FROM superiors WHERE superior_id = ? LIMIT 1`,
            [id],
          )
          if (existing[0]) {
            await conn.query(
              `UPDATE superiors SET
                 nama_superior = ?,
                 status_superior = ?,
                 username = ?,
                 nama_user = ?
               WHERE superior_id = ?`,
              [
                nama,
                emptyToNull(raw.statusSuperior) ?? 'ACTIVE',
                emptyToNull(raw.username),
                emptyToNull(raw.namaUser),
                id,
              ],
            )
            result.updated += 1
          } else {
            await conn.query(
              `INSERT INTO superiors (
                 superior_id, nama_superior, status_superior, username, nama_user
               ) VALUES (?, ?, ?, ?, ?)`,
              [
                id,
                nama,
                emptyToNull(raw.statusSuperior) ?? 'ACTIVE',
                emptyToNull(raw.username),
                emptyToNull(raw.namaUser),
              ],
            )
            result.inserted += 1
          }
        } else {
          await conn.query(
            `INSERT INTO superiors (
               superior_id, nama_superior, status_superior, username, nama_user
             ) VALUES (?, ?, ?, ?, ?)`,
            [
              newId(),
              nama,
              emptyToNull(raw.statusSuperior) ?? 'ACTIVE',
              emptyToNull(raw.username),
              emptyToNull(raw.namaUser),
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
