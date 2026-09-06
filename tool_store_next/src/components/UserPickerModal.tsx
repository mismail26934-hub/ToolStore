'use client'

import { useEffect, useMemo, useRef, useState } from 'react'
import type { UserRow } from '@/types/models'
import { useUsersPicker } from '@/features/users/useUsers'
import { usePrefs } from '@/prefs/PreferencesContext'
import { ClearIcon, SearchTextInput } from '@/components/SearchTextInput'

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

export function UserPickerModal({
  open,
  title,
  levelFilter = '',
  onClose,
  onSelect,
}: Props) {
  const { t } = usePrefs()
  const [keyword, setKeyword] = useState('')
  const [searchOpen, setSearchOpen] = useState(false)
  const [applied, setApplied] = useState({ keyword: '', level: levelFilter })
  const searchInputRef = useRef<HTMLInputElement>(null)
  const query = useUsersPicker(
    {
      keyword: applied.keyword,
      searchField: 'all',
      level: applied.level || levelFilter,
    },
    open,
  )
  const items = useMemo(() => query.data?.items ?? [], [query.data])
  const searchResultCount =
    query.data?.total ?? (query.isLoading ? null : items.length)

  useEffect(() => {
    if (!open) {
      setKeyword('')
      setSearchOpen(false)
      setApplied({ keyword: '', level: levelFilter })
      return
    }
    setApplied((prev) => ({ ...prev, level: levelFilter }))
  }, [open, levelFilter])

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
        aria-label={title}
        onClick={(e) => e.stopPropagation()}
      >
        <div className="section-title-row">
          <h3>{title}</h3>
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
              setApplied({ keyword: keyword.trim(), level: levelFilter })
            }}
          >
            <SearchTextInput
              ref={searchInputRef}
              placeholder="Search user…"
              value={keyword}
              onChange={(e) => setKeyword(e.target.value)}
              aria-label={t('search')}
              required
              clearLabel={t('clearSearch')}
              onClear={() => {
                setKeyword('')
                setApplied({ keyword: '', level: levelFilter })
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
                  setApplied({ keyword: '', level: levelFilter })
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
          <p className="muted">{t('noData')}</p>
        )}
      </div>
    </div>
  )
}
