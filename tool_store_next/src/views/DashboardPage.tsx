'use client'

import Link from 'next/link'
import { PageHeader } from '@/components/PageHeader'
import { useDashboardCounts } from '@/features/forms/useForms'
import type { DashboardCounts } from '@/types/models'

type TileIconName =
  | 'draft'
  | 'superior'
  | 'sadmin'
  | 'dept'
  | 'counter'
  | 'wh'
  | 'bell'

const APPROVAL_TILES: {
  key: keyof DashboardCounts
  label: string
  hint: string
  href: string
  icon: TileIconName
}[] = [
  {
    key: 'draft',
    label: 'Draft',
    hint: 'Belum diajukan',
    href: '/forms?inbox=blank',
    icon: 'draft',
  },
  {
    key: 'superiorApproval',
    label: 'Superior Approval',
    hint: 'Menunggu approve',
    href: '/forms?inbox=check-by',
    icon: 'superior',
  },
  {
    key: 'serviceAdmin',
    label: 'Service Admin',
    hint: 'Menunggu review',
    href: '/forms?inbox=superior-approved',
    icon: 'sadmin',
  },
  {
    key: 'deptHead',
    label: 'Dept Head',
    hint: 'Menunggu approve',
    href: '/forms?inbox=reviewed-sadmin',
    icon: 'dept',
  },
]

const PROCESS_TILES: {
  key: keyof DashboardCounts
  label: string
  hint: string
  href: string
  icon: TileIconName
}[] = [
  {
    key: 'counterGa',
    label: 'Counter / GA',
    hint: 'Proses order',
    href: '/forms?inbox=approved-dept',
    icon: 'counter',
  },
  {
    key: 'toolReceivedWhGa',
    label: 'Tool Received WH/GA',
    hint: 'Diterima gudang',
    href: '/forms?inbox=tool-received-wh',
    icon: 'wh',
  },
]

function TileIcon({ name }: { name: TileIconName }) {
  const common = {
    viewBox: '0 0 24 24',
    width: 18,
    height: 18,
    fill: 'none',
    'aria-hidden': true as const,
  }
  switch (name) {
    case 'draft':
      return (
        <svg {...common}>
          <path
            d="M7 3.5h7.2L19 8.2V20a1.5 1.5 0 0 1-1.5 1.5h-10A1.5 1.5 0 0 1 6 20V5A1.5 1.5 0 0 1 7.5 3.5H7Z"
            stroke="currentColor"
            strokeWidth="1.7"
          />
          <path d="M14 3.7V8h4.4" stroke="currentColor" strokeWidth="1.7" />
        </svg>
      )
    case 'superior':
      return (
        <svg {...common}>
          <circle cx="12" cy="8" r="3.2" stroke="currentColor" strokeWidth="1.7" />
          <path
            d="M5.5 19.2c.8-3 3.3-5 6.5-5s5.7 2 6.5 5"
            stroke="currentColor"
            strokeWidth="1.7"
            strokeLinecap="round"
          />
        </svg>
      )
    case 'sadmin':
      return (
        <svg {...common}>
          <rect
            x="5"
            y="4"
            width="14"
            height="16"
            rx="2"
            stroke="currentColor"
            strokeWidth="1.7"
          />
          <path
            d="M8 9h8M8 13h8M8 17h5"
            stroke="currentColor"
            strokeWidth="1.7"
            strokeLinecap="round"
          />
        </svg>
      )
    case 'dept':
      return (
        <svg {...common}>
          <path
            d="M4.5 20V8.5L12 4l7.5 4.5V20"
            stroke="currentColor"
            strokeWidth="1.7"
            strokeLinejoin="round"
          />
          <path d="M9.5 20v-6h5v6" stroke="currentColor" strokeWidth="1.7" />
        </svg>
      )
    case 'counter':
      return (
        <svg {...common}>
          <path
            d="M4.5 7.5h15l-1.2 9.2a2 2 0 0 1-2 1.8H7.7a2 2 0 0 1-2-1.8L4.5 7.5Z"
            stroke="currentColor"
            strokeWidth="1.7"
            strokeLinejoin="round"
          />
          <path
            d="M8 7.5V6a4 4 0 0 1 8 0v1.5"
            stroke="currentColor"
            strokeWidth="1.7"
          />
        </svg>
      )
    case 'wh':
      return (
        <svg {...common}>
          <path
            d="M3.5 10.5 12 4.5l8.5 6V20a1 1 0 0 1-1 1h-15a1 1 0 0 1-1-1v-9.5Z"
            stroke="currentColor"
            strokeWidth="1.7"
            strokeLinejoin="round"
          />
          <path d="M9.5 21v-7h5v7" stroke="currentColor" strokeWidth="1.7" />
        </svg>
      )
    case 'bell':
      return (
        <svg {...common}>
          <path
            d="M6 16.5V11a6 6 0 1 1 12 0v5.5l1.2 2H4.8L6 16.5Z"
            stroke="currentColor"
            strokeWidth="1.7"
            strokeLinejoin="round"
          />
          <path
            d="M10 20.2a2 2 0 0 0 4 0"
            stroke="currentColor"
            strokeWidth="1.7"
            strokeLinecap="round"
          />
        </svg>
      )
  }
}

function DashTile({
  label,
  hint,
  value,
  href,
  icon,
}: {
  label: string
  hint: string
  value: number
  href: string
  icon: TileIconName
}) {
  const hot = value > 0
  return (
    <Link
      className={`tile${hot ? ' tile-hot' : ' tile-empty'}`}
      href={href}
      aria-label={`${label}: ${value}`}
    >
      <span className="tile-icon">
        <TileIcon name={icon} />
      </span>
      <span className="tile-body">
        <span className="tile-label">{label}</span>
        <span className="tile-hint">{hint}</span>
      </span>
      <span className="tile-value">{value}</span>
    </Link>
  )
}

export function DashboardPage() {
  const { data, isLoading, isError, error, refetch, isFetching } =
    useDashboardCounts()

  return (
    <div className="page">
      <PageHeader title="Dashboard" subtitle="Ringkasan milestone form">
        <button
          type="button"
          className="btn btn-secondary"
          onClick={() => refetch()}
          disabled={isFetching}
        >
          {isFetching ? 'Refreshing…' : 'Refresh'}
        </button>
      </PageHeader>

      {isLoading && <div className="panel">Loading counts…</div>}
      {isError && (
        <div className="alert alert-error">
          {(error as Error)?.message || 'Gagal memuat dashboard'}
        </div>
      )}

      {data && (
        <div className="dash-sections">
          <section className="dash-section">
            <h2 className="dash-section-title">Menunggu approval</h2>
            <div className="tile-grid tile-grid--4">
              {APPROVAL_TILES.map((t) => (
                <DashTile
                  key={t.key}
                  label={t.label}
                  hint={t.hint}
                  href={t.href}
                  icon={t.icon}
                  value={data[t.key]}
                />
              ))}
            </div>
          </section>
          <section className="dash-section">
            <h2 className="dash-section-title">Proses</h2>
            <div className="tile-grid tile-grid--3">
              {PROCESS_TILES.map((t) => (
                <DashTile
                  key={t.key}
                  label={t.label}
                  hint={t.hint}
                  href={t.href}
                  icon={t.icon}
                  value={data[t.key]}
                />
              ))}
              <DashTile
                label="Notifications"
                hint="Antrian aktif"
                href="/forms"
                icon="bell"
                value={data.notificationTotal}
              />
            </div>
          </section>
        </div>
      )}
    </div>
  )
}
