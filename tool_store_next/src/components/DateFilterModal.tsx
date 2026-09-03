'use client'

import { useEffect, useState, type FormEvent } from 'react'
import { todayYmd } from '@/auth/roles'

type Props = {
  open: boolean
  onClose: () => void
  initialFrom?: string
  initialTo?: string
  onApply: (from: string, to: string) => void
  onClear: () => void
  showClear: boolean
}

function daysAgoYmd(days: number) {
  const d = new Date()
  d.setDate(d.getDate() - days)
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`
}

function normalizeRange(from: string, to: string): { from: string; to: string } {
  if (from && to && from > to) return { from: to, to: from }
  return { from, to }
}

export function DateFilterModal({
  open,
  onClose,
  initialFrom,
  initialTo,
  onApply,
  onClear,
  showClear,
}: Props) {
  const [from, setFrom] = useState(initialFrom || daysAgoYmd(30))
  const [to, setTo] = useState(initialTo || todayYmd())
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!open) return
    setFrom(initialFrom || daysAgoYmd(30))
    setTo(initialTo || todayYmd())
    setError(null)
  }, [open, initialFrom, initialTo])

  if (!open) return null

  const onSubmit = (e: FormEvent) => {
    e.preventDefault()
    setError(null)
    if (!from.trim()) {
      setError('From date wajib diisi')
      return
    }
    const range = normalizeRange(from.trim(), (to || from).trim())
    onApply(range.from, range.to)
    onClose()
  }

  return (
    <div className="modal-backdrop" role="presentation" onClick={onClose}>
      <div
        className="modal-panel"
        role="dialog"
        aria-modal="true"
        aria-label="Filter by date update"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="section-title-row">
          <h3>Filter by date update</h3>
          <button type="button" className="btn btn-ghost btn-sm" onClick={onClose}>
            Close
          </button>
        </div>

        <form className="stack" onSubmit={onSubmit}>
          <div className="grid-2">
            <label className="field">
              <span>From</span>
              <input
                type="date"
                value={from}
                onChange={(e) => setFrom(e.target.value)}
                required
              />
            </label>
            <label className="field">
              <span>To</span>
              <input
                type="date"
                value={to}
                onChange={(e) => setTo(e.target.value)}
              />
            </label>
          </div>

          {error && <div className="alert alert-error">{error}</div>}

          <div className="row-gap">
            <button type="submit" className="btn btn-primary">
              Apply
            </button>
            {showClear && (
              <button
                type="button"
                className="btn btn-ghost"
                onClick={() => {
                  onClear()
                  onClose()
                }}
              >
                Clear date filter
              </button>
            )}
          </div>
        </form>
      </div>
    </div>
  )
}
