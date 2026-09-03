import { fetchForms } from '@/features/forms/formsApi'
import { exportFormDetailRows } from '@/server/forms'

export async function resolveFormIdByFormNo(formNo: string): Promise<string | null> {
  const query = formNo.trim()
  if (!query) return null
  const parsed = await fetchForms({
    keyword: query,
    searchField: 'formNo',
    page: 1,
    limit: 20,
  })
  const exact = parsed.items.find((f) => f.formNo.trim() === query)
  if (exact?.idForm) return exact.idForm
  return parsed.items[0]?.idForm?.trim() || null
}

function toCsv(rows: Array<Record<string, string>>): string {
  if (rows.length === 0) return ''
  const headers = Object.keys(rows[0])
  const escape = (v: string) => {
    if (/[",\n]/.test(v)) return `"${v.replace(/"/g, '""')}"`
    return v
  }
  const lines = [
    headers.join(','),
    ...rows.map((row) => headers.map((h) => escape(row[h] ?? '')).join(',')),
  ]
  return lines.join('\n')
}

export async function downloadFormDetailExport(input: {
  idForm?: string
  fromDateUpdate?: string
  toDateUpdate?: string
}): Promise<void> {
  try {
    const rows = await exportFormDetailRows(input)
    if (rows.length === 0) throw new Error('Tidak ada data untuk diexport')
    const csv = toCsv(rows)
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `form-detail-export-${Date.now()}.csv`
    document.body.appendChild(a)
    a.click()
    a.remove()
    URL.revokeObjectURL(url)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Export gagal')
  }
}
