import * as XLSX from 'xlsx'
import type { UserImportRow } from '@/features/users/usersApi'

const HEADER_MAP: Record<string, keyof UserImportRow> = {
  id_users: 'idUsers',
  idusers: 'idUsers',
  id: 'idUsers',
  username: 'username',
  password: 'password',
  nama_user: 'namaUser',
  namauser: 'namaUser',
  nama: 'namaUser',
  name: 'namaUser',
  id_tu: 'idTu',
  idtu: 'idTu',
  no_telp: 'noTelp',
  notelp: 'noTelp',
  phone: 'noTelp',
  telp: 'noTelp',
  level: 'level',
  status: 'status',
  superior_id: 'superiorId',
  superiorid: 'superiorId',
  superior: 'superiorId',
}

function normalizeHeader(h: unknown): string {
  return String(h ?? '')
    .trim()
    .toLowerCase()
    .replace(/\s+/g, '_')
}

export function parseUsersExcel(file: ArrayBuffer): UserImportRow[] {
  const wb = XLSX.read(file, { type: 'array' })
  const sheetName = wb.SheetNames[0]
  if (!sheetName) throw new Error('File Excel kosong')
  const sheet = wb.Sheets[sheetName]
  const raw = XLSX.utils.sheet_to_json<Record<string, unknown>>(sheet, {
    defval: '',
  })
  if (!raw.length) throw new Error('Tidak ada data di sheet')

  const first = raw[0]
  const keyMap = new Map<string, keyof UserImportRow>()
  for (const key of Object.keys(first)) {
    const mapped = HEADER_MAP[normalizeHeader(key)]
    if (mapped) keyMap.set(key, mapped)
  }
  const mapped = [...keyMap.values()]
  if (!mapped.includes('username') || !mapped.includes('namaUser')) {
    throw new Error(
      'Kolom wajib tidak ditemukan: username dan nama_user (atau nama / name)',
    )
  }

  return raw.map((row) => {
    const out: UserImportRow = { username: '', namaUser: '' }
    for (const [src, dest] of keyMap) {
      const val = String(row[src] ?? '').trim()
      out[dest] = val
    }
    return out
  })
}

export function buildUsersTemplateXlsx(): Blob {
  const aoa = [
    [
      'id_users',
      'username',
      'password',
      'nama_user',
      'no_telp',
      'id_tu',
      'level',
      'status',
      'superior_id',
    ],
    [
      '',
      'user.example',
      'password123',
      'Nama Contoh',
      '08123456789',
      'TU001',
      'USER',
      'ACTIVE',
      '',
    ],
  ]
  const ws = XLSX.utils.aoa_to_sheet(aoa)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'users')
  const buf = XLSX.write(wb, { type: 'array', bookType: 'xlsx' })
  return new Blob([buf], {
    type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  })
}

export function downloadUsersTemplate() {
  const blob = buildUsersTemplateXlsx()
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = 'users-template.xlsx'
  a.click()
  URL.revokeObjectURL(url)
}

export type UserPreviewRow = {
  rowNum: number
  data: UserImportRow
  errors: string[]
  warnings: string[]
  valid: boolean
}

export function buildUserPreview(rows: UserImportRow[]): UserPreviewRow[] {
  const seenUsername = new Map<string, number>()
  return rows.map((data, i) => {
    const rowNum = i + 2
    const errors: string[] = []
    const warnings: string[] = []
    const username = (data.username ?? '').trim()
    const namaUser = (data.namaUser ?? '').trim()
    const password = (data.password ?? '').trim()

    if (!username) errors.push('username kosong')
    if (!namaUser) errors.push('nama_user kosong')
    if (!password) {
      warnings.push('password kosong (wajib jika user baru)')
    }

    if (username) {
      const key = username.toLowerCase()
      const prev = seenUsername.get(key)
      if (prev != null) {
        errors.push(`username duplikat (baris ${prev})`)
      } else {
        seenUsername.set(key, rowNum)
      }
    }

    return {
      rowNum,
      data: {
        ...data,
        username,
        namaUser,
        password: password || undefined,
      },
      errors,
      warnings,
      valid: errors.length === 0,
    }
  })
}
