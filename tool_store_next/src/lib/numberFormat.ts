/** Format number with thousand separators (id-ID: 200.000.000). */
export function formatThousands(
  raw: string | number | null | undefined,
): string {
  const text = String(raw ?? '').trim()
  if (!text || text === '-' || text === '—') return '—'

  const cleaned = text.replace(/[^\d.,-]/g, '')
  if (!cleaned || cleaned === '-' || cleaned === '.' || cleaned === ',') {
    return text
  }

  let n: number
  const dotCount = (cleaned.match(/\./g) ?? []).length
  if (/,/.test(cleaned) && !/\./.test(cleaned)) {
    // 200000000,5 or 200,5
    n = Number(cleaned.replace(',', '.'))
  } else if (dotCount > 1) {
    // 200.000.000 (thousand separators)
    n = Number(cleaned.replace(/\./g, '').replace(/,/g, ''))
  } else {
    // plain 200000000 or 200000000.5
    n = Number(cleaned.replace(/,/g, ''))
  }

  if (!Number.isFinite(n)) return text

  return new Intl.NumberFormat('id-ID', {
    maximumFractionDigits: 2,
  }).format(n)
}
