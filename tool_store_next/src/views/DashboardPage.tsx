'use client'

import Link from 'next/link'
import { useDashboardCounts } from '@/features/forms/useForms'
import type { DashboardCounts } from '@/types/models'

const TILES: {
  key: keyof Omit<DashboardCounts, 'notificationTotal'>
  label: string
  href: string
}[] = [
  { key: 'draft', label: 'Draft', href: '/forms?inbox=blank' },
  {
    key: 'superiorApproval',
    label: 'Superior Approval',
    href: '/forms?inbox=check-by',
  },
  {
    key: 'serviceAdmin',
    label: 'Service Admin',
    href: '/forms?inbox=superior-approved',
  },
  {
    key: 'deptHead',
    label: 'Dept Head',
    href: '/forms?inbox=reviewed-sadmin',
  },
  {
    key: 'counterGa',
    label: 'Counter GA',
    href: '/forms?inbox=approved-dept',
  },
  {
    key: 'toolReceivedWhGa',
    label: 'Tool Received WH/GA',
    href: '/forms?inbox=tool-received-wh',
  },
]

export function DashboardPage() {
  const { data, isLoading, isError, error, refetch, isFetching } =
    useDashboardCounts()

  return (
    <div className="page">
      <header className="page-header">
        <div>
          <h1>Dashboard</h1>
          <p className="muted">Ringkasan milestone form</p>
        </div>
        <div className="page-header-actions">
          <button
            type="button"
            className="btn btn-secondary"
            onClick={() => refetch()}
            disabled={isFetching}
          >
            {isFetching ? 'Refreshing…' : 'Refresh'}
          </button>
        </div>
      </header>

      {isLoading && <div className="panel">Loading counts…</div>}
      {isError && (
        <div className="alert alert-error">
          {(error as Error)?.message || 'Gagal memuat dashboard'}
        </div>
      )}

      {data && (
        <div className="tile-grid">
          {TILES.map((t) => (
            <Link key={t.key} className="tile" href={t.href}>
              <div className="tile-label">{t.label}</div>
              <div className="tile-value">{data[t.key]}</div>
            </Link>
          ))}
          <div className="tile tile-static">
            <div className="tile-label">Notifications</div>
            <div className="tile-value">{data.notificationTotal}</div>
          </div>
        </div>
      )}
    </div>
  )
}
