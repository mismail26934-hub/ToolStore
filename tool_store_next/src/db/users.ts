import { getDbPool } from '@/db/pool'

export type DbUser = {
  id_users: string
  username: string
  password: string
  nama_user: string
  foto: string | null
  id_tu: string | null
  no_telp: string | null
  token: string | null
  level: string
  status: string | null
  superior_id: string | null
  nama_superior: string | null
}

export async function findUserByUsername(
  username: string,
): Promise<DbUser | null> {
  const pool = getDbPool()
  const [rows] = await pool.query(
    `SELECT
       u.id_users,
       u.username,
       u.password,
       u.nama_user,
       u.foto,
       u.id_tu,
       u.no_telp,
       u.token,
       u.level,
       u.status,
       u.superior_id,
       s.nama_superior
     FROM users u
     LEFT JOIN superiors s ON s.superior_id = u.superior_id
     WHERE u.username = ?
     LIMIT 1`,
    [username.trim()],
  )

  const list = rows as DbUser[]
  return list[0] ?? null
}

/** Local-only plain password check (seed uses plain text). */
export function passwordsMatch(stored: string, input: string): boolean {
  return stored === input
}

export function isUserActive(status: string | null | undefined): boolean {
  const s = (status ?? 'ACTIVE').trim().toUpperCase()
  return s === '' || s === 'ACTIVE' || s === '1' || s === 'Y'
}
