import type { ResultSetHeader, RowDataPacket } from 'mysql2'
import { ApiParam } from '@/api/params'
import { backupRowBeforeChange } from '@/db/backup'
import { emptyToNull, newId, s } from '@/db/helpers'
import { getDbPool } from '@/db/pool'
import type { PaginatedList, UserRow } from '@/types/models'
import { USER_PAGE_SIZE } from '@/types/models'

export type { SuperiorListFilters } from '@/db/superiors'
export { dbListSuperiors } from '@/db/superiors'

export type UserListFilters = {
  page?: number
  limit?: number
  keyword?: string
  searchField?: string
  level?: string
}

export type SaveUserInput = {
  idUsers?: string
  username: string
  password: string
  namaUser: string
  idTu: string
  noTelp: string
  level: string
  status?: string
  superiorId: string
  foto?: string
  token?: string
}

export type UserImportRow = {
  idUsers?: string
  username: string
  password?: string
  namaUser: string
  idTu?: string
  noTelp?: string
  level?: string
  status?: string
  superiorId?: string
}

export type UserImportResult = {
  inserted: number
  updated: number
  skipped: number
  errors: { row: number; message: string }[]
}

type UserPacket = RowDataPacket & Record<string, unknown>

function mapUser(row: UserPacket): UserRow {
  return {
    idUsers: s(row.id_users),
    username: s(row.username),
    password: s(row.password),
    namaUser: s(row.nama_user),
    foto: s(row.foto),
    idTu: s(row.id_tu),
    noTelp: s(row.no_telp),
    token: s(row.token),
    level: s(row.level),
    status: s(row.status),
    superiorId: s(row.superior_id),
    namaSuperior: s(row.nama_superior),
    valueResponse: '',
    messageResponse: '',
  }
}

export async function dbListUsers(
  filters: UserListFilters = {},
): Promise<PaginatedList<UserRow>> {
  const pool = getDbPool()
  const page = Math.max(1, filters.page ?? 1)
  const limit = Math.max(1, filters.limit ?? USER_PAGE_SIZE)
  const offset = (page - 1) * limit
  const where: string[] = []
  const params: unknown[] = []

  if (filters.level?.trim()) {
    where.push('UPPER(u.level) = ?')
    params.push(filters.level.trim().toUpperCase())
  }
  const kw = filters.keyword?.trim() ?? ''
  if (kw) {
    const field = (filters.searchField ?? 'all').trim()
    if (field === 'username') {
      where.push('u.username LIKE ?')
      params.push(`%${kw}%`)
    } else if (field === 'name' || field === 'nama') {
      where.push('u.nama_user LIKE ?')
      params.push(`%${kw}%`)
    } else {
      where.push('(u.username LIKE ? OR u.nama_user LIKE ? OR u.id_tu LIKE ?)')
      params.push(`%${kw}%`, `%${kw}%`, `%${kw}%`)
    }
  }

  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : ''
  const [countRows] = await pool.query<RowDataPacket[]>(
    `SELECT COUNT(*) AS total FROM users u ${whereSql}`,
    params,
  )
  const [rows2] = await pool.query<UserPacket[]>(
    `SELECT
       u.*,
       COALESCE(
         NULLIF(NULLIF(TRIM(su.nama_user), ''), '-'),
         NULLIF(NULLIF(TRIM(su.username), ''), '-'),
         ''
       ) AS nama_superior
     FROM users u
     LEFT JOIN users su ON su.id_users = u.superior_id
     ${whereSql}
     ORDER BY u.nama_user ASC
     LIMIT ? OFFSET ?`,
    [...params, limit, offset],
  )

  return {
    items: rows2.map(mapUser),
    total: Number(countRows[0]?.total ?? 0),
  }
}

export async function dbGetUserById(idUsers: string): Promise<UserRow | null> {
  const pool = getDbPool()
  const [rows] = await pool.query<UserPacket[]>(
    `SELECT
       u.*,
       COALESCE(
         NULLIF(NULLIF(TRIM(su.nama_user), ''), '-'),
         NULLIF(NULLIF(TRIM(su.username), ''), '-'),
         ''
       ) AS nama_superior
     FROM users u
     LEFT JOIN users su ON su.id_users = u.superior_id
     WHERE u.id_users = ?
     LIMIT 1`,
    [idUsers.trim()],
  )
  return rows[0] ? mapUser(rows[0]) : null
}

export async function dbMutateUser(
  param: string,
  input: SaveUserInput,
): Promise<string> {
  const pool = getDbPool()

  if (param === ApiParam.deleteUser) {
    const id = input.idUsers?.trim() ?? ''
    if (!id) throw new Error('id_users wajib diisi')
    await backupRowBeforeChange({
      tableName: 'users',
      recordId: id,
      action: 'DELETE',
      userId: id,
    })
    await pool.query(`DELETE FROM users WHERE id_users = ?`, [id])
    return 'User dihapus'
  }

  if (param === ApiParam.addUser) {
    const id = input.idUsers?.trim() || newId()
    await pool.query(
      `INSERT INTO users (
        id_users, username, password, nama_user, foto, id_tu, no_telp,
        token, level, status, superior_id
      ) VALUES (?,?,?,?,?,?,?,?,?,?,?)`,
      [
        id,
        input.username.trim(),
        input.password,
        input.namaUser.trim(),
        emptyToNull(input.foto),
        emptyToNull(input.idTu),
        emptyToNull(input.noTelp),
        emptyToNull(input.token),
        input.level.trim(),
        emptyToNull(input.status) ?? 'ACTIVE',
        emptyToNull(input.superiorId),
      ],
    )
    return 'User ditambahkan'
  }

  if (param === ApiParam.editUser) {
    const id = input.idUsers?.trim() ?? ''
    if (!id) throw new Error('id_users wajib diisi')
    await backupRowBeforeChange({
      tableName: 'users',
      recordId: id,
      action: 'UPDATE',
      userId: id,
    })
    const [r] = await pool.query<ResultSetHeader>(
      `UPDATE users SET
        username = ?, password = ?, nama_user = ?, foto = ?, id_tu = ?,
        no_telp = ?, token = ?, level = ?, status = ?, superior_id = ?
       WHERE id_users = ?`,
      [
        input.username.trim(),
        input.password,
        input.namaUser.trim(),
        emptyToNull(input.foto),
        emptyToNull(input.idTu),
        emptyToNull(input.noTelp),
        emptyToNull(input.token),
        input.level.trim(),
        emptyToNull(input.status) ?? 'ACTIVE',
        emptyToNull(input.superiorId),
        id,
      ],
    )
    if (r.affectedRows === 0) throw new Error('User tidak ditemukan')
    return 'User diperbarui'
  }

  throw new Error(`Param user tidak dikenal: ${param}`)
}

export async function dbImportUsers(
  rows: UserImportRow[],
): Promise<UserImportResult> {
  const pool = getDbPool()
  const result: UserImportResult = {
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
      const username = (raw.username ?? '').trim()
      const namaUser = (raw.namaUser ?? '').trim()
      if (!username) {
        result.skipped += 1
        result.errors.push({ row: rowNum, message: 'username kosong' })
        continue
      }
      if (!namaUser) {
        result.skipped += 1
        result.errors.push({ row: rowNum, message: 'nama_user kosong' })
        continue
      }
      try {
        const idUsers = (raw.idUsers ?? '').trim()
        const password = (raw.password ?? '').trim()
        const level = (raw.level ?? '').trim() || 'USER'
        const status = emptyToNull(raw.status) ?? 'ACTIVE'
        const idTu = emptyToNull(raw.idTu)
        const noTelp = emptyToNull(raw.noTelp)
        const superiorId = emptyToNull(raw.superiorId)

        let existingId: string | null = null
        if (idUsers) {
          const [byId] = await conn.query<RowDataPacket[]>(
            `SELECT id_users, password FROM users WHERE id_users = ? LIMIT 1`,
            [idUsers],
          )
          if (byId[0]) existingId = String(byId[0].id_users)
        }
        if (!existingId) {
          const [byUser] = await conn.query<RowDataPacket[]>(
            `SELECT id_users, password FROM users WHERE username = ? LIMIT 1`,
            [username],
          )
          if (byUser[0]) existingId = String(byUser[0].id_users)
        }

        if (existingId) {
          const [curr] = await conn.query<RowDataPacket[]>(
            `SELECT password FROM users WHERE id_users = ? LIMIT 1`,
            [existingId],
          )
          const nextPassword = password || String(curr[0]?.password ?? '')
          if (!nextPassword) {
            result.skipped += 1
            result.errors.push({
              row: rowNum,
              message: 'password wajib untuk update tanpa password lama',
            })
            continue
          }
          await backupRowBeforeChange({
            tableName: 'users',
            recordId: existingId,
            action: 'UPDATE',
            userId: existingId,
            conn,
          })
          await conn.query(
            `UPDATE users SET
              username = ?, password = ?, nama_user = ?, id_tu = ?,
              no_telp = ?, level = ?, status = ?, superior_id = ?
             WHERE id_users = ?`,
            [
              username,
              nextPassword,
              namaUser,
              idTu,
              noTelp,
              level,
              status,
              superiorId,
              existingId,
            ],
          )
          result.updated += 1
        } else {
          if (!password) {
            result.skipped += 1
            result.errors.push({
              row: rowNum,
              message: 'password wajib untuk user baru',
            })
            continue
          }
          await conn.query(
            `INSERT INTO users (
              id_users, username, password, nama_user, foto, id_tu, no_telp,
              token, level, status, superior_id
            ) VALUES (?,?,?,?,?,?,?,?,?,?,?)`,
            [
              idUsers || newId(),
              username,
              password,
              namaUser,
              null,
              idTu,
              noTelp,
              null,
              level,
              status,
              superiorId,
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

export async function dbSaveFcmToken(input: {
  userId: string
  fcmToken: string
}): Promise<void> {
  const pool = getDbPool()
  const [r] = await pool.query<ResultSetHeader>(
    `UPDATE users SET fcm_token = ? WHERE id_users = ?`,
    [input.fcmToken.trim(), input.userId.trim()],
  )
  if (r.affectedRows === 0) throw new Error('User tidak ditemukan untuk FCM')
}
