'use client'

import { useMemo, useState } from 'react'
import type { SuperiorRow } from '../types/models'
import { useSuperiors } from '../features/users/useUsers'

type Props = {
  open: boolean
  onClose: () => void
  onSelect: (row: SuperiorRow) => void
}

function displayName(row: SuperiorRow) {
  return row.namaSuperior || row.namaUser || row.username || row.superiorId || '—'
}

export function SuperiorPickerModal({ open, onClose, onSelect }: Props) {
  const [keyword, setKeyword] = useState('')
  const [searchField, setSearchField] = useState('all')
  const [applied, setApplied] = useState({ keyword: '', searchField: 'all' })

  const query = useSuperiors(applied, open)
  const items = useMemo(() => query.data?.items ?? [], [query.data])

  if (!open) return null

  return (
    <div className="modal-backdrop" role="presentation" onClick={onClose}>
      <div
        className="modal-panel"
        role="dialog"
        aria-modal="true"
        aria-label="Pilih superior"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="section-title-row">
          <h3>Pilih Superior</h3>
          <button type="button" className="btn btn-ghost btn-sm" onClick={onClose}>
            Close
          </button>
        </div>

        <form
          className="toolbar"
          onSubmit={(e) => {
            e.preventDefault()
            setApplied({
              keyword: keyword.trim(),
              searchField,
            })
          }}
        >
          <select
            value={searchField}
            onChange={(e) => setSearchField(e.target.value)}
          >
            <option value="all">All</option>
            <option value="name">Name</option>
            <option value="username">Username</option>
          </select>
          <input
            placeholder="Search superior…"
            value={keyword}
            onChange={(e) => setKeyword(e.target.value)}
          />
          <button type="submit" className="btn btn-primary">
            Search
          </button>
        </form>

        {query.isLoading && <p className="muted">Loading…</p>}
        {query.isError && (
          <div className="alert alert-error">
            {(query.error as Error)?.message}
          </div>
        )}

        <ul className="picker-list">
          {items.map((row) => (
            <li key={row.superiorId || displayName(row)}>
              <button
                type="button"
                className="picker-item"
                onClick={() => {
                  onSelect(row)
                  onClose()
                }}
              >
                <strong>{displayName(row)}</strong>
                <span className="muted">
                  {row.superiorId}
                  {row.statusSuperior ? ` · ${row.statusSuperior}` : ''}
                </span>
              </button>
            </li>
          ))}
        </ul>

        {!query.isLoading && items.length === 0 && (
          <p className="muted">Tidak ada data superior.</p>
        )}
      </div>
    </div>
  )
}
