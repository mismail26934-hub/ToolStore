'use client'

import {
  EmptyState,
  ListShimmer,
  LoadingSpinner,
} from '@/components/ListStates'
import { usePrefs } from '@/prefs/PreferencesContext'

/** Main-area boot UI while auth / route data settles. */
export function PageBootLoading() {
  const { t } = usePrefs()
  return (
    <div className="page page-boot">
      <LoadingSpinner label={t('loading')} />
      <ListShimmer rows={4} />
    </div>
  )
}

/**
 * Static chrome for Suspense fallback (no useSearchParams / auth).
 * Full topbar shimmer on hard refresh.
 */
export function AppChromeFallback() {
  return (
    <div className="app-shell app-shell--boot">
      <div className="topbar-glass" aria-hidden />
      <header className="topbar">
        <div className="brand-row" aria-hidden>
          <div className="boot-brand-skel">
            <span className="boot-line-skel boot-line-skel--title" />
            <span className="boot-line-skel boot-line-skel--tagline" />
          </div>
        </div>
        <div className="top-actions" aria-hidden>
          <div className="boot-actions-skel boot-actions-skel--bar">
            <span className="boot-pill boot-pill--sm" />
            <span className="boot-pill" />
            <span className="boot-pill boot-pill--icon" />
            <span className="boot-pill boot-pill--icon" />
            <span className="boot-pill boot-pill--icon" />
            <span className="boot-pill boot-pill--account" />
          </div>
          <div className="boot-actions-skel boot-actions-skel--mobile">
            <span className="boot-pill boot-pill--icon" />
          </div>
        </div>
      </header>
      <main className="main">
        <div className="page page-boot">
          <div className="loading-state" role="status" aria-live="polite">
            <span className="loading-spinner" aria-hidden />
            <span className="loading-state-label">Loading…</span>
          </div>
          <ListShimmer rows={4} />
        </div>
      </main>
    </div>
  )
}

export { EmptyState, ListShimmer, LoadingSpinner }
