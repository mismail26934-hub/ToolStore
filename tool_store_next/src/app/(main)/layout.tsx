import { Suspense } from 'react'
import { AuthGuard } from '@/components/AuthGuard'
import { AppChromeFallback } from '@/components/AppBoot'

export default function MainLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <Suspense fallback={<AppChromeFallback />}>
      <AuthGuard>{children}</AuthGuard>
    </Suspense>
  )
}
