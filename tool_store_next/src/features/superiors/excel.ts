import * as XLSX from 'xlsx'
import type { SuperiorImportRow } from '@/features/superiors/superiorsApi'

const HEADER_MAP: Record<string, keyof SuperiorImportRow> = {
  superior_id: 'superiorId',
  superiorid: 'superiorId',
  id: 'superiorId',
  nama_superior: 'namaSuperior',
  namasuperior: 'namaSuperior',
  nama: 'namaSuperior',
  name: 'namaSuperior',
  status_superior: 'statusSuperior',
  statussuperior: 'statusSuperior',
  status: 'statusSuperior',
  username: 'username',
  nama_user: 'namaUser',
  namauser: 'namaUser',
}

function normalizeHeader(h: unknown): string {
  return String(h ?? '')
    .trim()
    .toLowerCase()
    .replace(/\s+/g, '_')
}

export function parseSuperiorsExcel(file: ArrayBuffer): SuperiorImportRow[] {
  const wb = XLSX.read(file, { type: 'array' })
  const sheetName = wb.SheetNames[0]
  if (!sheetName) throw new Error('File Excel kosong')
  const sheet = wb.Sheets[sheetName]
  const raw = XLSX.utils.sheet_to_json<Record<string, unknown>>(sheet, {
    defval: '',
  })
  if (!raw.length) throw new Error('Tidak ada data di sheet')

  const first = raw[0]
  const keyMap = new Map<string, keyof SuperiorImportRow>()
  for (const key of Object.keys(first)) {
    const mapped = HEADER_MAP[normalizeHeader(key)]
    if (mapped) keyMap.set(key, mapped)
  }
  if (![...keyMap.values()].includes('namaSuperior')) {
    throw new Error(
      'Kolom wajib tidak ditemukan: nama_superior (atau nama / name)',
    )
  }

  return raw.map((row) => {
    const out: SuperiorImportRow = { namaSuperior: '' }
    for (const [src, dest] of keyMap) {
      const val = String(row[src] ?? '').trim()
      out[dest] = val
    }
    return out
  })
}

export function buildSuperiorsTemplateXlsx(): Blob {
  const aoa = [
    ['superior_id', 'nama_superior', 'status_superior', 'username', 'nama_user'],
    ['', 'Contoh Superior', 'ACTIVE', 'user.example', 'Nama User'],
  ]
  const ws = XLSX.utils.aoa_to_sheet(aoa)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'superiors')
  const buf = XLSX.write(wb, { type: 'array', bookType: 'xlsx' })
  return new Blob([buf], {
    type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  })
}

export function downloadSuperiorsTemplate() {
  const blob = buildSuperiorsTemplateXlsx()
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = 'superiors-template.xlsx'
  a.click()
  URL.revokeObjectURL(url)
}
