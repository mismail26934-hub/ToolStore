export function LoadingSpinner({ label }: { label?: string }) {
  return (
    <div className="loading-state" role="status" aria-live="polite">
      <span className="loading-spinner" aria-hidden />
      {label ? <span className="loading-state-label">{label}</span> : null}
    </div>
  )
}

export function ListShimmer({ rows = 4 }: { rows?: number }) {
  return (
    <div className="shimmer-list" aria-hidden>
      {Array.from({ length: rows }, (_, i) => (
        <div key={i} className="shimmer-card">
          <div className="shimmer-line shimmer-line--title" />
          <div className="shimmer-line shimmer-line--meta" />
          <div className="shimmer-line shimmer-line--short" />
        </div>
      ))}
    </div>
  )
}

export function EmptyState({ message }: { message: string }) {
  return (
    <div className="empty-state panel" role="status">
      {message}
    </div>
  )
}
