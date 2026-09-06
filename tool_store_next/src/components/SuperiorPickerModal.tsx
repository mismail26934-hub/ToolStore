'use client'

import { useEffect, useMemo, useRef, useState } from 'react'
import type { SuperiorRow } from '../types/models'
import { useSuperiors } from '../features/users/useUsers'
import { usePrefs } from '@/prefs/PreferencesContext'
import { ClearIcon, SearchTextInput } from '@/components/SearchTextInput'
import {
  meaningfulLabel,
  superiorDisplayName,
} from '@/lib/displayLabel'

type Props = {
  open: boolean
  onClose: () => void
  onSelect: (row: SuperiorRow) => void
}

function displayName(row: SuperiorRow) {
  return superiorDisplayName(row) || '—'
}

function SearchIcon() {
  return (
    <svg
      className="btn-icon-svg"
      viewBox="0 0 24 24"
      width="18"
      height="18"
      aria-hidden
      fill="none"
    >
      <circle cx="11" cy="11" r="6.5" stroke="currentColor" strokeWidth="1.8" />
      <path
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
        d="m16.2 16.2 3.3 3.3"
      />
    </svg>
  )
}

export function SuperiorPickerModal({ open, onClose, onSelect }: Props) {
  const { t } = usePrefs()
  const [keyword, setKeyword] = useState('')
  const [searchField, setSearchField] = useState('all')
  const [searchOpen, setSearchOpen] = useState(false)
  const [applied, setApplied] = useState({ keyword: '', searchField: 'all' })
  const searchInputRef = useRef<HTMLInputElement>(null)

  const query = useSuperiors(applied, open)
  const items = useMemo(() => query.data?.items ?? [], [query.data])
  const searchResultCount = query.isLoading
    ? null
    : (query.data?.total ?? items.length)

  useEffect(() => {
    if (!open) {
      setKeyword('')
      setSearchField('all')
      setSearchOpen(false)
      setApplied({ keyword: '', searchField: 'all' })
    }
  }, [open])

  useEffect(() => {
    if (!open || !searchOpen) return
    const id = window.setTimeout(() => searchInputRef.current?.focus(), 50)
    return () => window.clearTimeout(id)
  }, [open, searchOpen])

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
          <div className="row-gap">
            <button
              type="button"
              className={`btn btn-ghost btn-sm btn-with-icon${searchOpen || applied.keyword ? ' btn-filter-active' : ''}`}
              title={t('search')}
              aria-label={t('search')}
              aria-expanded={searchOpen}
              onClick={() => setSearchOpen((v) => !v)}
            >
              <SearchIcon />
              <span className="btn-label">{t('search')}</span>
            </button>
            <button
              type="button"
              className="btn btn-ghost btn-sm"
              onClick={onClose}
            >
              Close
            </button>
          </div>
        </div>

        {searchOpen && (
          <form
            className="toolbar"
            onSubmit={(e) => {
              e.preventDefault()
              if (!keyword.trim()) return
              setApplied({
                keyword: keyword.trim(),
                searchField,
              })
            }}
          >
            <select
              value={searchField}
              onChange={(e) => setSearchField(e.target.value)}
              aria-label="Search field"
            >
              <option value="all">All</option>
              <option value="name">Name</option>
              <option value="username">Username</option>
            </select>
            <SearchTextInput
              ref={searchInputRef}
              placeholder="Search superior…"
              value={keyword}
              onChange={(e) => setKeyword(e.target.value)}
              aria-label={t('search')}
              required
              clearLabel={t('clearSearch')}
              onClear={() => {
                setKeyword('')
                setSearchField('all')
                setApplied({ keyword: '', searchField: 'all' })
              }}
              showClear={!!keyword || !!applied.keyword}
            />
            <button
              type="submit"
              className="btn btn-primary"
              disabled={!keyword.trim()}
            >
              {t('search')}
            </button>
          </form>
        )}

        {applied.keyword ? (
          <div className="filter-chip-row">
            <span className="chip chip-filter">
              {t('search')}: {applied.keyword}
              {searchResultCount != null
                ? ` · ${t('dataCount').replace('{n}', String(searchResultCount))}`
                : query.isFetching
                  ? ' · …'
                  : ''}
              <ClearIcon
                label={t('clearSearch')}
                onClick={() => {
                  setKeyword('')
                  setSearchField('all')
                  setApplied({ keyword: '', searchField: 'all' })
                }}
                className="chip-clear-icon"
              />
            </span>
          </div>
        ) : null}

        {query.isLoading && <p className="muted">{t('loading')}</p>}
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
                  ID TU: {meaningfulLabel(row.idTu) || '—'}
                  {meaningfulLabel(row.statusSuperior)
                    ? ` · ${row.statusSuperior}`
                    : ''}
                </span>
              </button>
            </li>
          ))}
        </ul>

        {!query.isLoading && items.length === 0 && (
          <p className="muted">{t('noData')}</p>
        )}
      </div>
    </div>
  )
}
