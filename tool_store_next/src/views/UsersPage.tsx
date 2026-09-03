'use client'

import { useMemo, useState, type FormEvent } from 'react'
import Link from 'next/link'
import { useRouter, useSearchParams } from 'next/navigation'
import { useUsersInfinite } from '@/features/users/useUsers'
import type { UserRow } from '@/types/models'

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
            <span className="muted">No. Telp</span>
            <div>{user.noTelp || '—'}</div>
          </div>
          <div>
            <span className="muted">Superior</span>
            <div>{user.namaSuperior || user.superiorId || '—'}</div>
          </div>
          <div>
            <span className="muted">ID TU</span>
            <div>{user.idTu || '—'}</div>
          </div>
          <div>
            <span className="muted">ID Users</span>
            <div>{user.idUsers || '—'}</div>
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
  const router = useRouter()
  const params = useSearchParams()
  const [keyword, setKeyword] = useState(params.get('q') ?? '')
  const [searchField, setSearchField] = useState(params.get('field') ?? 'all')

  const filters = useMemo(
    () => ({
      keyword: params.get('q') ?? '',
      searchField: params.get('field') ?? 'all',
    }),
    [params],
  )

  const query = useUsersInfinite(filters)
  const users = query.data?.pages.flatMap((p) => p.items) ?? []

  const onSearch = (e: FormEvent) => {
    e.preventDefault()
    const next = new URLSearchParams(params.toString())
    if (keyword.trim()) next.set('q', keyword.trim())
    else next.delete('q')
    next.set('field', searchField)
    router.replace(`/users?${next.toString()}`)
  }

  return (
    <div className="page">
      <header className="page-header">
        <div>
          <h1>Users</h1>
          <p className="muted">Manajemen user (SUPERADMIN)</p>
        </div>
        <div className="page-header-actions">
          <Link className="btn btn-secondary" href="/users/new">
            + Add user
          </Link>
        </div>
      </header>

      <form className="toolbar" onSubmit={onSearch}>
        <select
          value={searchField}
          onChange={(e) => setSearchField(e.target.value)}
        >
          <option value="all">Semua</option>
          <option value="username">Username</option>
          <option value="name">Nama</option>
          <option value="phone">No. Telp</option>
          <option value="level">Level</option>
          <option value="status">Status</option>
        </select>
        <input
          placeholder="Search user…"
          value={keyword}
          onChange={(e) => setKeyword(e.target.value)}
        />
        <button type="submit" className="btn btn-primary">
          Search
        </button>
      </form>

      {query.isLoading && <div className="panel">Loading users…</div>}
      {query.isError && (
        <div className="alert alert-error">
          {(query.error as Error)?.message}
        </div>
      )}

      <div className="stack">
        {users.map((user, i) => (
          <UserCard key={user.idUsers || `${user.username}-${i}`} user={user} index={i} />
        ))}
      </div>

      {!query.isLoading && users.length === 0 && (
        <div className="panel muted">Tidak ada user.</div>
      )}

      {query.hasNextPage && (
        <div className="center-row">
          <button
            type="button"
            className="btn btn-secondary"
            disabled={query.isFetchingNextPage}
            onClick={() => query.fetchNextPage()}
          >
            {query.isFetchingNextPage ? 'Loading…' : 'Load more'}
          </button>
        </div>
      )}
    </div>
  )
}
