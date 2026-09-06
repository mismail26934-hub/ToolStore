import type { ResultSetHeader, RowDataPacket } from 'mysql2'
import { ApiParam } from '@/api/params'
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
       COALESCE(s.nama_superior, su.nama_user, '') AS nama_superior
     FROM users u
     LEFT JOIN superiors s ON s.superior_id = u.superior_id
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
       COALESCE(s.nama_superior, su.nama_user, '') AS nama_superior
     FROM users u
     LEFT JOIN superiors s ON s.superior_id = u.superior_id
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
