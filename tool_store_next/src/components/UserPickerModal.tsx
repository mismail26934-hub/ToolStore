'use client'

import { useMemo, useState } from 'react'
import type { UserRow } from '@/types/models'
import { useUsersPicker } from '@/features/users/useUsers'

type Props = {
  open: boolean
  title: string
  levelFilter?: string
  onClose: () => void
  onSelect: (row: UserRow) => void
}

function displayName(row: UserRow) {
  return row.namaUser || row.username || row.idUsers || '—'
}

export function UserPickerModal({
  open,
  title,
  levelFilter = '',
  onClose,
  onSelect,
}: Props) {
  const [keyword, setKeyword] = useState('')
  const [applied, setApplied] = useState({ keyword: '', level: levelFilter })
  const query = useUsersPicker(
    {
      keyword: applied.keyword,
      searchField: 'all',
      level: applied.level || levelFilter,
    },
    open,
  )
  const items = useMemo(() => query.data?.items ?? [], [query.data])

  if (!open) return null

  return (
    <div className="modal-backdrop" role="presentation" onClick={onClose}>
      <div
        className="modal-panel"
        role="dialog"
        aria-modal="true"
        aria-label={title}
        onClick={(e) => e.stopPropagation()}
      >
        <div className="section-title-row">
          <h3>{title}</h3>
          <button type="button" className="btn btn-ghost btn-sm" onClick={onClose}>
            Close
          </button>
        </div>
        <form
          className="toolbar"
          onSubmit={(e) => {
            e.preventDefault()
            setApplied({ keyword: keyword.trim(), level: levelFilter })
          }}
        >
          <input
            placeholder="Search user…"
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
            <li key={row.idUsers || row.username}>
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
                  {row.username}
                  {row.level ? ` · ${row.level}` : ''}
                </span>
              </button>
            </li>
          ))}
        </ul>
        {!query.isLoading && items.length === 0 && (
          <p className="muted">Tidak ada user.</p>
        )}
      </div>
    </div>
  )
}
