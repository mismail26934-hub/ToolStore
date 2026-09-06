/** Display / parse dates as dd/mm/yyyy while storing yyyy-MM-dd. */

const YMD_RE = /^(\d{4})-(\d{2})-(\d{2})$/
const DMY_RE = /^(\d{1,2})\/(\d{1,2})\/(\d{4})$/

export function ymdToDmy(ymd: string): string {
  const m = YMD_RE.exec(ymd.trim())
  if (!m) return ''
  return `${m[3]}/${m[2]}/${m[1]}`
}

export function dmyToYmd(dmy: string): string | null {
  const m = DMY_RE.exec(dmy.trim())
  if (!m) return null
  const dd = Number(m[1])
  const mm = Number(m[2])
  const yyyy = Number(m[3])
  if (mm < 1 || mm > 12 || dd < 1 || dd > 31) return null
  const dt = new Date(yyyy, mm - 1, dd)
  if (
    dt.getFullYear() !== yyyy ||
    dt.getMonth() !== mm - 1 ||
    dt.getDate() !== dd
  ) {
    return null
  }
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${yyyy}-${pad(mm)}-${pad(dd)}`
}

/** Light mask while typing: digits + slashes, max dd/mm/yyyy. */
export function maskDmyInput(raw: string): string {
  const digits = raw.replace(/\D/g, '').slice(0, 8)
  if (digits.length <= 2) return digits
  if (digits.length <= 4) return `${digits.slice(0, 2)}/${digits.slice(2)}`
  return `${digits.slice(0, 2)}/${digits.slice(2, 4)}/${digits.slice(4)}`
}

export function formatDateDisplay(value: string | null | undefined): string {
  if (!value?.trim()) return '—'
  const slice = value.trim().slice(0, 10)
  return ymdToDmy(slice) || slice
}
