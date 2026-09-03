import { Suspense } from 'react'
import { GuestOnly } from '@/components/AuthGuard'
import { LoginPage } from '@/views/LoginPage'

export default function Page() {
  return (
    <GuestOnly>
      <Suspense fallback={<div className="panel">Loading…</div>}>
        <LoginPage />
      </Suspense>
    </GuestOnly>
  )
}
