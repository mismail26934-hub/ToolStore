import { NextResponse } from 'next/server'
import {
  findUserByUsername,
  isUserActive,
  passwordsMatch,
} from '@/db/users'

export async function POST(request: Request) {
  try {
    const body = (await request.json()) as {
      username?: string
      password?: string
    }
    const username = body.username?.trim() ?? ''
    const password = body.password ?? ''

    if (!username || !password) {
      return NextResponse.json(
        { value: '0', message: 'Username dan password wajib diisi' },
        { status: 400 },
      )
    }

    const user = await findUserByUsername(username)
    if (!user || !passwordsMatch(user.password, password)) {
      return NextResponse.json(
        { value: '0', message: 'Username atau password salah' },
        { status: 401 },
      )
    }

    if (!isUserActive(user.status)) {
      return NextResponse.json(
        { value: '0', message: 'Akun tidak aktif' },
        { status: 403 },
      )
    }

    return NextResponse.json({
      value: '1',
      message: 'Login berhasil',
      user: {
        id_users: user.id_users,
        username: user.username,
        password: user.password,
        nama_user: user.nama_user,
        foto: user.foto ?? '',
        id_tu: user.id_tu ?? '',
        no_telp: user.no_telp ?? '',
        token: user.token ?? '',
        level: user.level,
        status: user.status ?? 'ACTIVE',
        superior_id: user.superior_id ?? '',
        nama_superior: user.nama_superior ?? '',
      },
    })
  } catch (e) {
    const message =
      e instanceof Error ? e.message : 'Gagal koneksi ke database lokal'
    const hint =
      /ECONNREFUSED|ENOTFOUND|ER_BAD_DB_ERROR|Access denied/i.test(message)
        ? ' Pastikan MySQL berjalan dan jalankan sql/schema.sql.'
        : ''
    return NextResponse.json(
      { value: '0', message: `${message}${hint}` },
      { status: 500 },
    )
  }
}
