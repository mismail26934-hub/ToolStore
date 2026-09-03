import { Suspense } from 'react'
import { AuthGuard } from '@/components/AuthGuard'

export default function MainLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <Suspense fallback={<div className="panel">Loading…</div>}>
      <AuthGuard>{children}</AuthGuard>
    </Suspense>
  )
}
