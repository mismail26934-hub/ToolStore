'use client'

import { useMemo, useRef, useState } from 'react'
import {
  buildSuperiorPreview,
  downloadSuperiorsTemplate,
  parseSuperiorsExcel,
  type SuperiorPreviewRow,
} from '@/features/superiors/excel'
import { useSuperiorMutations } from '@/features/superiors/useSuperiors'
import type { SuperiorImportResult } from '@/features/superiors/superiorsApi'
import { usePrefs } from '@/prefs/PreferencesContext'

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
  const [preview, setPreview] = useState<SuperiorPreviewRow[] | null>(null)
  const [selected, setSelected] = useState<Set<number>>(new Set())

  const validCount = useMemo(
    () => preview?.filter((r) => r.valid).length ?? 0,
    [preview],
  )
  const selectedCount = selected.size
  const errorCount = useMemo(
    () => preview?.filter((r) => !r.valid).length ?? 0,
    [preview],
  )

  if (!open) return null

  const resetPreview = () => {
    setPreview(null)
    setSelected(new Set())
    setResult(null)
    setError(null)
    setFileName(null)
    if (inputRef.current) inputRef.current.value = ''
  }

  const onFile = async (file: File | null) => {
    setError(null)
    setResult(null)
    setPreview(null)
    setSelected(new Set())
    if (!file) return
    setFileName(file.name)
    try {
      const buf = await file.arrayBuffer()
      const rows = parseSuperiorsExcel(buf)
      const built = buildSuperiorPreview(rows)
      setPreview(built)
      setSelected(new Set(built.filter((r) => r.valid).map((r) => r.rowNum)))
    } catch (e) {
      setError((e as Error).message)
    }
  }

  const toggleRow = (rowNum: number, valid: boolean) => {
    if (!valid) return
    setSelected((prev) => {
      const next = new Set(prev)
      if (next.has(rowNum)) next.delete(rowNum)
      else next.add(rowNum)
      return next
    })
  }

  const selectAllValid = () => {
    if (!preview) return
    setSelected(new Set(preview.filter((r) => r.valid).map((r) => r.rowNum)))
  }

  const clearSelection = () => setSelected(new Set())

  const onImport = async () => {
    if (!preview || selected.size === 0) return
    setError(null)
    setResult(null)
    try {
      const rows = preview
        .filter((r) => selected.has(r.rowNum) && r.valid)
        .map((r) => r.data)
      const res = await importRows.mutateAsync(rows)
      setResult(res)
    } catch (e) {
      setError((e as Error).message)
    }
  }

  return (
    <div className="modal-backdrop" role="presentation" onClick={onClose}>
      <div
        className="modal-panel modal-panel-wide import-modal"
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
          <code>nama_superior</code> (wajib), <code>username</code> (wajib),{' '}
          <code>status_superior</code>, <code>nama_user</code>. Password user
          baru = username.
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
            onClick={() => inputRef.current?.click()}
          >
            {t('chooseFile')}
          </button>
          {preview && (
            <button
              type="button"
              className="btn btn-ghost"
              onClick={resetPreview}
            >
              Reset
            </button>
          )}
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

        {preview && (
          <>
            <div className="import-preview-meta">
              <span>
                {t('previewReady').replace('{n}', String(preview.length))}
              </span>
              <span className="muted">
                OK {validCount} · Error {errorCount} · Selected {selectedCount}
              </span>
            </div>

            <div className="row-gap">
              <button
                type="button"
                className="btn btn-ghost btn-sm"
                onClick={selectAllValid}
                disabled={validCount === 0}
              >
                {t('selectAllValid')}
              </button>
              <button
                type="button"
                className="btn btn-ghost btn-sm"
                onClick={clearSelection}
                disabled={selectedCount === 0}
              >
                {t('clearSelection')}
              </button>
            </div>

            <div className="import-preview-wrap">
              <table className="data-table import-preview-table">
                <thead>
                  <tr>
                    <th className="import-check-col">
                      <input
                        type="checkbox"
                        checked={
                          validCount > 0 && selectedCount === validCount
                        }
                        disabled={validCount === 0}
                        onChange={(e) => {
                          if (e.target.checked) selectAllValid()
                          else clearSelection()
                        }}
                        aria-label={t('selectAllValid')}
                      />
                    </th>
                    <th>#</th>
                    <th>Nama superior</th>
                    <th>Status</th>
                    <th>Username</th>
                    <th>Nama user</th>
                    <th>Validasi</th>
                  </tr>
                </thead>
                <tbody>
                  {preview.map((row) => {
                    const statusLabel = !row.valid
                      ? t('rowError')
                      : row.warnings.length
                        ? t('rowWarn')
                        : t('rowOk')
                    const statusClass = !row.valid
                      ? 'chip-bad'
                      : row.warnings.length
                        ? 'chip-warn'
                        : 'chip-ok'
                    const detail = [...row.errors, ...row.warnings].join('; ')
                    return (
                      <tr
                        key={row.rowNum}
                        className={`data-table-row${!row.valid ? ' import-row-error' : ''}`}
                      >
                        <td className="import-check-col">
                          <input
                            type="checkbox"
                            checked={selected.has(row.rowNum)}
                            disabled={!row.valid}
                            onChange={() => toggleRow(row.rowNum, row.valid)}
                            aria-label={`Row ${row.rowNum}`}
                          />
                        </td>
                        <td>{row.rowNum}</td>
                        <td>
                          <strong>{row.data.namaSuperior || '—'}</strong>
                        </td>
                        <td>{row.data.statusSuperior || '—'}</td>
                        <td>{row.data.username || '—'}</td>
                        <td>{row.data.namaUser || '—'}</td>
                        <td>
                          <span
                            className={`chip ${statusClass}`}
                            title={detail || undefined}
                          >
                            {statusLabel}
                          </span>
                          {detail ? (
                            <div className="import-row-msg muted">{detail}</div>
                          ) : null}
                        </td>
                      </tr>
                    )
                  })}
                </tbody>
              </table>
            </div>

            <div className="row-gap">
              <button
                type="button"
                className="btn btn-primary"
                disabled={selectedCount === 0 || importRows.isPending}
                onClick={() => void onImport()}
              >
                {importRows.isPending
                  ? t('loading')
                  : `${t('importSelected')} (${selectedCount})`}
              </button>
            </div>
          </>
        )}

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
