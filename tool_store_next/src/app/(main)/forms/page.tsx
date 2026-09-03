import { Suspense } from 'react'
import { FormsPage } from '@/views/FormsPage'

export default function Page() {
  return (
    <Suspense fallback={<div className="panel">Loading…</div>}>
      <FormsPage />
    </Suspense>
  )
}
