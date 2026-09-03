'use client'

import { useMemo, useState, type FormEvent } from 'react'
import { todayYmd } from '@/auth/roles'
import {
  downloadFormDetailExport,
  resolveFormIdByFormNo,
} from '@/features/forms/exportApi'

type Props = {
  open: boolean
  onClose: () => void
}

function daysAgoYmd(days: number) {
  const d = new Date()
  d.setDate(d.getDate() - days)
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`
}

export function ExcelExportModal({ open, onClose }: Props) {
  const defaults = useMemo(
    () => ({ from: daysAgoYmd(30), to: todayYmd() }),
    [],
  )
  const [mode, setMode] = useState<'date' | 'formNo'>('date')
  const [from, setFrom] = useState(defaults.from)
  const [to, setTo] = useState(defaults.to)
  const [formNo, setFormNo] = useState('')
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState<string | null>(null)

  if (!open) return null

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault()
    setError(null)
    setBusy(true)
    try {
      if (mode === 'formNo') {
        const id = await resolveFormIdByFormNo(formNo)
        if (!id) throw new Error('Form No tidak ditemukan')
        await downloadFormDetailExport({ idForm: id })
      } else {
        if (!from.trim()) throw new Error('From date wajib diisi')
        await downloadFormDetailExport({
          fromDateUpdate: from,
          toDateUpdate: to || from,
        })
      }
      onClose()
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="modal-backdrop" role="presentation" onClick={onClose}>
      <div
        className="modal-panel"
        role="dialog"
        aria-modal="true"
        aria-label="Export Excel"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="section-title-row">
          <h3>Export Excel</h3>
          <button type="button" className="btn btn-ghost btn-sm" onClick={onClose}>
            Close
          </button>
        </div>

        <form className="stack" onSubmit={onSubmit}>
          <label className="field">
            <span>Mode</span>
            <select
              value={mode}
              onChange={(e) => setMode(e.target.value as 'date' | 'formNo')}
            >
              <option value="date">By date update</option>
              <option value="formNo">By Form No</option>
            </select>
          </label>

          {mode === 'date' ? (
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
          ) : (
            <label className="field">
              <span>Form No</span>
              <input
                value={formNo}
                onChange={(e) => setFormNo(e.target.value)}
                placeholder="e.g. F-00123"
                required
              />
            </label>
          )}

          {error && <div className="alert alert-error">{error}</div>}

          <button type="submit" className="btn btn-primary" disabled={busy}>
            {busy ? 'Exporting…' : 'Download .xlsx'}
          </button>
        </form>
      </div>
    </div>
  )
}
