import { Suspense } from 'react'
import { UsersPage } from '@/views/UsersPage'

export default function Page() {
  return (
    <Suspense fallback={<div className="panel">Loading…</div>}>
      <UsersPage />
    </Suspense>
  )
}
