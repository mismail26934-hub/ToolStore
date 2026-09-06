'use client'

import { usePrefs } from '@/prefs/PreferencesContext'

type Props = {
  page: number
  totalPages: number
  totalItems: number
  pageSize: number
  onPageChange: (page: number) => void
  disabled?: boolean
}

function pageWindow(current: number, total: number): (number | '…')[] {
  if (total <= 7) {
    return Array.from({ length: total }, (_, i) => i + 1)
  }
  const pages = new Set<number>()
  pages.add(1)
  pages.add(total)
  for (let p = current - 1; p <= current + 1; p++) {
    if (p >= 1 && p <= total) pages.add(p)
  }
  if (current <= 3) {
    pages.add(2)
    pages.add(3)
    pages.add(4)
  }
  if (current >= total - 2) {
    pages.add(total - 1)
    pages.add(total - 2)
    pages.add(total - 3)
  }
  const sorted = [...pages].sort((a, b) => a - b)
  const out: (number | '…')[] = []
  let prev = 0
  for (const p of sorted) {
    if (prev && p - prev > 1) out.push('…')
    out.push(p)
    prev = p
  }
  return out
}

export function Pagination({
  page,
  totalPages,
  totalItems,
  pageSize,
  onPageChange,
  disabled,
}: Props) {
  const { t } = usePrefs()
  if (totalItems <= 0 || totalPages <= 1) return null

  const safePage = Math.min(Math.max(1, page), totalPages)
  const from = (safePage - 1) * pageSize + 1
  const to = Math.min(safePage * pageSize, totalItems)
  const items = pageWindow(safePage, totalPages)

  return (
    <nav className="pagination" aria-label="Pagination">
      <p className="pagination-meta muted">
        {t('showingRange')
          .replace('{from}', String(from))
          .replace('{to}', String(to))
          .replace('{total}', String(totalItems))}
      </p>
      <div className="pagination-controls">
        <button
          type="button"
          className="btn btn-ghost btn-sm pagination-btn"
          disabled={disabled || safePage <= 1}
          onClick={() => onPageChange(safePage - 1)}
          aria-label={t('prevPage')}
        >
          ‹ {t('prevPage')}
        </button>
        <div className="pagination-pages">
          {items.map((item, idx) =>
            item === '…' ? (
              <span key={`e-${idx}`} className="pagination-ellipsis" aria-hidden>
                …
              </span>
            ) : (
              <button
                key={item}
                type="button"
                className={`btn btn-sm pagination-page${item === safePage ? ' is-active' : ' btn-ghost'}`}
                disabled={disabled}
                aria-current={item === safePage ? 'page' : undefined}
                onClick={() => onPageChange(item)}
              >
                {item}
              </button>
            ),
          )}
        </div>
        <button
          type="button"
          className="btn btn-ghost btn-sm pagination-btn"
          disabled={disabled || safePage >= totalPages}
          onClick={() => onPageChange(safePage + 1)}
          aria-label={t('nextPage')}
        >
          {t('nextPage')} ›
        </button>
      </div>
    </nav>
  )
}
