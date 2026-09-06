'use client'

import { useEffect, useMemo, useRef, useState, type FormEvent } from 'react'
import Link from 'next/link'
import { useRouter, useSearchParams } from 'next/navigation'
import {
  EmptyState,
  ListShimmer,
  LoadingSpinner,
} from '@/components/ListStates'
import { PageHeader } from '@/components/PageHeader'
import { ClearIcon, SearchTextInput } from '@/components/SearchTextInput'
import { Pagination } from '@/components/Pagination'
import { SuperiorExcelImportModal } from '@/components/SuperiorExcelImportModal'
import { useSuperiorsList } from '@/features/superiors/useSuperiors'
import { usePrefs } from '@/prefs/PreferencesContext'
import type { SuperiorRow } from '@/types/models'
import { USER_PAGE_SIZE } from '@/types/models'

function SuperiorCard({ row }: { row: SuperiorRow }) {
  return (
    <article className="form-card user-card">
      <div className="form-card-head user-card-head">
        <div>
          <div className="form-card-title">{row.namaSuperior || '—'}</div>
          <div className="muted mono">{row.superiorId || '—'}</div>
        </div>
        <div className="chip-row">
          <span className="chip">{row.statusSuperior || '—'}</span>
        </div>
      </div>
      <div className="form-card-body">
        <div className="meta-grid">
          <div>
            <span className="muted">Username</span>
            <div className="meta-value">{row.username || '—'}</div>
          </div>
          <div>
            <span className="muted">Nama user</span>
            <div className="meta-value">{row.namaUser || '—'}</div>
          </div>
        </div>
        <div className="section-title-row">
          <span className="muted">Actions</span>
          <Link
            className="btn btn-secondary btn-sm"
            href={`/superiors/${encodeURIComponent(row.superiorId)}/edit`}
          >
            Edit
          </Link>
        </div>
      </div>
    </article>
  )
}

export function SuperiorsPage() {
  const { t } = usePrefs()
  const router = useRouter()
  const params = useSearchParams()
  const [keyword, setKeyword] = useState(params.get('q') ?? '')
  const [searchField, setSearchField] = useState(params.get('field') ?? 'all')
  const [searchOpen, setSearchOpen] = useState(() => !!params.get('q')?.trim())
  const [importOpen, setImportOpen] = useState(false)
  const searchInputRef = useRef<HTMLInputElement>(null)
  const hasActiveSearch = !!params.get('q')?.trim()

  useEffect(() => {
    if (!searchOpen) return
    const id = window.setTimeout(() => searchInputRef.current?.focus(), 50)
    return () => window.clearTimeout(id)
  }, [searchOpen])

  const page = Math.max(1, Number(params.get('page') || '1') || 1)

  const filters = useMemo(
    () => ({
      keyword: params.get('q') ?? '',
      searchField: params.get('field') ?? 'all',
      page,
      limit: USER_PAGE_SIZE,
    }),
    [params, page],
  )

  const query = useSuperiorsList(filters)
  const items = query.data?.items ?? []
  const totalItems = query.data?.total ?? items.length
  const totalPages = Math.max(1, Math.ceil(totalItems / USER_PAGE_SIZE))
  const searchResultCount =
    query.data?.total ?? (query.isLoading ? null : items.length)

  const setPage = (nextPage: number) => {
    const next = new URLSearchParams(params.toString())
    if (nextPage <= 1) next.delete('page')
    else next.set('page', String(nextPage))
    const qs = next.toString()
    router.replace(qs ? `/superiors?${qs}` : '/superiors')
  }

  const onSearch = (e: FormEvent) => {
    e.preventDefault()
    if (!keyword.trim()) return
    const next = new URLSearchParams(params.toString())
    next.set('q', keyword.trim())
    next.set('field', searchField)
    next.delete('page')
    router.replace(`/superiors?${next.toString()}`)
  }

  const clearSearch = () => {
    setKeyword('')
    setSearchField('all')
    router.replace('/superiors')
  }

  return (
    <div className="page">
      <PageHeader title={t('superiors')} subtitle={t('superiorsSubtitle')}>
        <button
          type="button"
          className={`btn btn-ghost btn-with-icon${searchOpen || hasActiveSearch ? ' btn-filter-active' : ''}`}
          title={t('search')}
          aria-label={t('search')}
          aria-expanded={searchOpen}
          onClick={() => setSearchOpen((v) => !v)}
        >
          <svg
            className="btn-icon-svg"
            viewBox="0 0 24 24"
            width="18"
            height="18"
            aria-hidden
            fill="none"
          >
            <circle
              cx="11"
              cy="11"
              r="6.5"
              stroke="currentColor"
              strokeWidth="1.8"
            />
            <path
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              d="m16.2 16.2 3.3 3.3"
            />
          </svg>
          <span className="btn-label">{t('search')}</span>
        </button>
        <button
          type="button"
          className="btn btn-ghost btn-with-icon"
          title={t('importExcel')}
          aria-label={t('importExcel')}
          onClick={() => setImportOpen(true)}
        >
          <svg
            className="btn-icon-svg"
            viewBox="0 0 24 24"
            width="18"
            height="18"
            aria-hidden
            fill="none"
          >
            <path
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
              d="M12 3v12M8 11l4 4 4-4M5 19h14"
            />
          </svg>
          <span className="btn-label">{t('importExcel')}</span>
        </button>
        <Link
          className="btn btn-secondary btn-with-icon"
          href="/superiors/new"
          title={t('addSuperior')}
          aria-label={t('addSuperior')}
        >
          <svg
            className="btn-icon-svg"
            viewBox="0 0 24 24"
            width="18"
            height="18"
            aria-hidden
            fill="none"
          >
            <path
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              d="M12 5v14M5 12h14"
            />
          </svg>
          <span className="btn-label">{t('addSuperior')}</span>
        </Link>
      </PageHeader>

      {hasActiveSearch && (
        <div className="filter-chip-row">
          <span className="chip chip-filter">
            {t('search')}: {params.get('q')}
            {searchResultCount != null
              ? ` · ${t('dataCount').replace('{n}', String(searchResultCount))}`
              : query.isFetching
                ? ' · …'
                : ''}
            <ClearIcon
              label={t('clearSearch')}
              onClick={clearSearch}
              className="chip-clear-icon"
            />
          </span>
        </div>
      )}

      {searchOpen && (
        <form className="toolbar" onSubmit={onSearch}>
          <select
            value={searchField}
            onChange={(e) => setSearchField(e.target.value)}
            aria-label="Search field"
          >
            <option value="all">Semua</option>
            <option value="name">Nama</option>
            <option value="username">Username</option>
            <option value="status">Status</option>
            <option value="id">ID</option>
          </select>
          <SearchTextInput
            ref={searchInputRef}
            placeholder="Search superior…"
            value={keyword}
            onChange={(e) => setKeyword(e.target.value)}
            aria-label={t('search')}
            required
            clearLabel={t('clearSearch')}
            onClear={clearSearch}
            showClear={!!keyword || hasActiveSearch}
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

      {query.isLoading && (
        <div className="stack">
          <LoadingSpinner label={t('loading')} />
          <ListShimmer rows={4} />
        </div>
      )}
      {query.isError && (
        <div className="alert alert-error">
          {(query.error as Error)?.message}
        </div>
      )}

      {!query.isLoading && !query.isError && items.length === 0 && (
        <EmptyState message={t('noData')} />
      )}

      {!query.isLoading && !query.isError && items.length > 0 && (
        <div className="card-grid">
          {items.map((row) => (
            <SuperiorCard key={row.superiorId} row={row} />
          ))}
        </div>
      )}

      <Pagination
        page={page}
        totalPages={totalPages}
        totalItems={totalItems}
        pageSize={USER_PAGE_SIZE}
        onPageChange={setPage}
        disabled={query.isFetching}
      />

      <SuperiorExcelImportModal
        open={importOpen}
        onClose={() => setImportOpen(false)}
      />
    </div>
  )
}
