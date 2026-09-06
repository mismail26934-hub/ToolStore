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
import { UserExcelImportModal } from '@/components/UserExcelImportModal'
import { usePrefs } from '@/prefs/PreferencesContext'
import { useUsersList } from '@/features/users/useUsers'
import type { UserRow } from '@/types/models'
import { USER_PAGE_SIZE } from '@/types/models'

function statusTone(status: string): 'ok' | 'bad' | 'warn' {
  const s = status.toLowerCase()
  if (s.includes('active') || s.includes('aktif')) return 'ok'
  if (s.includes('inactive') || s.includes('nonaktif') || s.includes('disable'))
    return 'bad'
  return 'warn'
}

function UserCard({ user, index }: { user: UserRow; index: number }) {
  const tone = statusTone(user.status)
  return (
    <article className="form-card user-card">
      <div className="form-card-head user-card-head">
        <div>
          <div className="form-card-title">
            #{index + 1} · {user.username || '—'}
          </div>
          <div className="muted">{user.namaUser || '—'}</div>
        </div>
        <div className="chip-row">
          <span className="chip">{user.level || '—'}</span>
          <span className={`chip chip-${tone}`}>{user.status || '—'}</span>
        </div>
      </div>
      <div className="form-card-body">
        <div className="meta-grid">
          <div>
            <span className="muted">Superior</span>
            <div className="meta-value">
              {user.namaSuperior || user.superiorId || '—'}
            </div>
          </div>
          <div>
            <span className="muted">No. Telp</span>
            <div className="meta-value">{user.noTelp || '—'}</div>
          </div>
          <div>
            <span className="muted">ID TU</span>
            <div className="meta-value">{user.idTu || '—'}</div>
          </div>
          <div>
            <span className="muted">ID Users</span>
            <div className="meta-value mono" title={user.idUsers || undefined}>
              {user.idUsers || '—'}
            </div>
          </div>
        </div>
        <div className="section-title-row">
          <span className="muted">Actions</span>
          <Link
            className="btn btn-secondary btn-sm"
            href={`/users/${encodeURIComponent(user.idUsers)}/edit`}
          >
            Edit
          </Link>
        </div>
      </div>
    </article>
  )
}

export function UsersPage() {
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

  const query = useUsersList(filters)
  const users = query.data?.items ?? []
  const totalItems = query.data?.total ?? users.length
  const totalPages = Math.max(1, Math.ceil(totalItems / USER_PAGE_SIZE))
  const searchResultCount =
    query.data?.total ?? (query.isLoading ? null : users.length)

  const setPage = (nextPage: number) => {
    const next = new URLSearchParams(params.toString())
    if (nextPage <= 1) next.delete('page')
    else next.set('page', String(nextPage))
    const qs = next.toString()
    router.replace(qs ? `/users?${qs}` : '/users')
  }

  const onSearch = (e: FormEvent) => {
    e.preventDefault()
    if (!keyword.trim()) return
    const next = new URLSearchParams(params.toString())
    next.set('q', keyword.trim())
    next.set('field', searchField)
    next.delete('page')
    router.replace(`/users?${next.toString()}`)
  }

  const clearSearch = () => {
    setKeyword('')
    setSearchField('all')
    const next = new URLSearchParams(params.toString())
    next.delete('q')
    next.delete('field')
    next.delete('page')
    const qs = next.toString()
    router.replace(qs ? `/users?${qs}` : '/users')
  }

  return (
    <div className="page">
      <PageHeader title="Users" subtitle="Manajemen user (SUPERADMIN)">
        <button
          type="button"
          className={`btn btn-ghost btn-with-icon${searchOpen || hasActiveSearch ? ' btn-filter-active' : ''}`}
          title={t('search')}
          aria-label={t('search')}
          aria-expanded={searchOpen}
          aria-pressed={searchOpen}
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
          href="/users/new"
          title="Add user"
          aria-label="Add user"
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
          <span className="btn-label">Add user</span>
        </Link>
      </PageHeader>

      {hasActiveSearch && (
        <div className="filter-chip-row">
          <span className="chip chip-filter">
            {t('search')}: {params.get('q')}
            {params.get('field') && params.get('field') !== 'all'
              ? ` · ${params.get('field')}`
              : ''}
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
            <option value="username">Username</option>
            <option value="name">Nama</option>
            <option value="phone">No. Telp</option>
            <option value="level">Level</option>
            <option value="status">Status</option>
          </select>
          <SearchTextInput
            ref={searchInputRef}
            placeholder="Search user…"
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

      {!query.isLoading && !query.isError && users.length === 0 && (
        <EmptyState message={t('noData')} />
      )}

      {!query.isLoading && !query.isError && users.length > 0 && (
        <>
          <div className="card-grid show-mobile">
            {users.map((user, i) => (
              <UserCard
                key={user.idUsers || `${user.username}-${i}`}
                user={user}
                index={(page - 1) * USER_PAGE_SIZE + i}
              />
            ))}
          </div>

          <div className="data-table-wrap show-desktop">
            <table className="data-table">
              <thead>
                <tr>
                  <th>#</th>
                  <th>Username</th>
                  <th>Nama</th>
                  <th>Superior</th>
                  <th>Level</th>
                  <th>Status</th>
                  <th>No. Telp</th>
                  <th className="actions">Actions</th>
                </tr>
              </thead>
              <tbody>
                {users.map((user, i) => {
                  const tone = statusTone(user.status)
                  const index = (page - 1) * USER_PAGE_SIZE + i
                  return (
                    <tr
                      key={user.idUsers || `${user.username}-${i}`}
                      className="data-table-row"
                    >
                      <td>{index + 1}</td>
                      <td>
                        <strong>{user.username || '—'}</strong>
                      </td>
                      <td>{user.namaUser || '—'}</td>
                      <td>{user.namaSuperior || user.superiorId || '—'}</td>
                      <td>
                        <span className="chip">{user.level || '—'}</span>
                      </td>
                      <td>
                        <span className={`chip chip-${tone}`}>
                          {user.status || '—'}
                        </span>
                      </td>
                      <td>{user.noTelp || '—'}</td>
                      <td className="actions">
                        <Link
                          className="btn btn-secondary btn-sm"
                          href={`/users/${encodeURIComponent(user.idUsers)}/edit`}
                        >
                          Edit
                        </Link>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        </>
      )}

      <Pagination
        page={page}
        totalPages={totalPages}
        totalItems={totalItems}
        pageSize={USER_PAGE_SIZE}
        onPageChange={setPage}
        disabled={query.isFetching}
      />

      <UserExcelImportModal
        open={importOpen}
        onClose={() => setImportOpen(false)}
      />
    </div>
  )
}
