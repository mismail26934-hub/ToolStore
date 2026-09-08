/** Parse qty / price strings (id-ID or plain) to a finite number. */
export function parseQtyNumber(
  raw: string | number | null | undefined,
): number | null {
  if (typeof raw === 'number') {
    return Number.isFinite(raw) ? raw : null
  }
  const text = String(raw ?? '').trim()
  if (!text || text === '-' || text === '—') return null

  const cleaned = text.replace(/[^\d.,-]/g, '')
  if (!cleaned || cleaned === '-' || cleaned === '.' || cleaned === ',') {
    return null
  }

  let n: number
  const dotCount = (cleaned.match(/\./g) ?? []).length
  if (/,/.test(cleaned) && !/\./.test(cleaned)) {
    n = Number(cleaned.replace(',', '.'))
  } else if (dotCount > 1) {
    n = Number(cleaned.replace(/\./g, '').replace(/,/g, ''))
  } else {
    n = Number(cleaned.replace(/,/g, ''))
  }

  return Number.isFinite(n) ? n : null
}

/** Format number with thousand separators (id-ID: 200.000.000). */
export function formatThousands(
  raw: string | number | null | undefined,
): string {
  const text = String(raw ?? '').trim()
  if (!text || text === '-' || text === '—') return '—'
  const n = parseQtyNumber(raw)
  if (n == null) return text
  return new Intl.NumberFormat('id-ID', {
    maximumFractionDigits: 2,
  }).format(n)
}
