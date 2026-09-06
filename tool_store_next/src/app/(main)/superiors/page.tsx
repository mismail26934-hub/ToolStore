import { Suspense } from 'react'
import { AppChromeFallback } from '@/components/AppBoot'
import { SuperiorsPage } from '@/views/SuperiorsPage'

export default function Page() {
  return (
    <Suspense fallback={<AppChromeFallback />}>
      <SuperiorsPage />
    </Suspense>
  )
}
