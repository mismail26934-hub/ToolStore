'use client'

import { useRef, useState } from 'react'
import {
  downloadSuperiorsTemplate,
  parseSuperiorsExcel,
} from '@/features/superiors/excel'
import { useSuperiorMutations } from '@/features/superiors/useSuperiors'
import { usePrefs } from '@/prefs/PreferencesContext'
import type { SuperiorImportResult } from '@/features/superiors/superiorsApi'

type Props = {
  open: boolean
  onClose: () => void
}

export function SuperiorExcelImportModal({ open, onClose }: Props) {
  const { t } = usePrefs()
  const inputRef = useRef<HTMLInputElement>(null)
  const { importRows } = useSuperiorMutations()
  const [error, setError] = useState<string | null>(null)
  const [result, setResult] = useState<SuperiorImportResult | null>(null)
  const [fileName, setFileName] = useState<string | null>(null)

  if (!open) return null

  const onFile = async (file: File | null) => {
    setError(null)
    setResult(null)
    if (!file) return
    setFileName(file.name)
    try {
      const buf = await file.arrayBuffer()
      const rows = parseSuperiorsExcel(buf)
      const res = await importRows.mutateAsync(rows)
      setResult(res)
    } catch (e) {
      setError((e as Error).message)
    }
  }

  return (
    <div className="modal-backdrop" role="presentation" onClick={onClose}>
      <div
        className="modal-panel"
        role="dialog"
        aria-modal="true"
        aria-label={t('importExcel')}
        onClick={(e) => e.stopPropagation()}
      >
        <div className="section-title-row">
          <h3>{t('importExcel')}</h3>
          <button type="button" className="btn btn-ghost btn-sm" onClick={onClose}>
            {t('close')}
          </button>
        </div>

        <p className="muted">
          Kolom: <code>superior_id</code> (opsional),{' '}
          <code>nama_superior</code> (wajib), <code>status_superior</code>,{' '}
          <code>username</code>, <code>nama_user</code>. Jika{' '}
          <code>superior_id</code> sudah ada → update.
        </p>

        <div className="row-gap">
          <button
            type="button"
            className="btn btn-secondary"
            onClick={() => downloadSuperiorsTemplate()}
          >
            {t('downloadTemplate')}
          </button>
          <button
            type="button"
            className="btn btn-primary"
            disabled={importRows.isPending}
            onClick={() => inputRef.current?.click()}
          >
            {importRows.isPending ? t('loading') : t('chooseFile')}
          </button>
          <input
            ref={inputRef}
            type="file"
            accept=".xlsx,.xls,.csv"
            hidden
            onChange={(e) => void onFile(e.target.files?.[0] ?? null)}
          />
        </div>

        {fileName && <p className="muted">File: {fileName}</p>}
        {error && <div className="alert alert-error">{error}</div>}
        {result && (
          <div className="panel stack">
            <div>
              Insert: <strong>{result.inserted}</strong> · Update:{' '}
              <strong>{result.updated}</strong> · Skip:{' '}
              <strong>{result.skipped}</strong>
            </div>
            {result.errors.length > 0 && (
              <ul className="picker-list">
                {result.errors.slice(0, 20).map((err) => (
                  <li key={`${err.row}-${err.message}`}>
                    <span className="muted">
                      Row {err.row}: {err.message}
                    </span>
                  </li>
                ))}
              </ul>
            )}
          </div>
        )}
      </div>
    </div>
  )
}
