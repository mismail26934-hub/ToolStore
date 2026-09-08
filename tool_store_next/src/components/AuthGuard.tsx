'use client'

import { useEffect } from 'react'
import { usePathname, useRouter, useSearchParams } from 'next/navigation'
import { useAuth } from '@/auth/AuthContext'
import { isSuperAdmin } from '@/auth/session'
import { AppShell } from '@/components/AppShell'
import { PageBootLoading } from '@/components/AppBoot'
import { PageHeaderProvider } from '@/components/PageHeader'
import { safeInternalPath } from '@/lib/safeInternalPath'

export function AuthGuard({ children }: { children: React.ReactNode }) {
  const { user, ready } = useAuth()
  const router = useRouter()
  const pathname = usePathname()
  const searchParams = useSearchParams()
  const booting = !ready || !user

  useEffect(() => {
    if (!ready) return
    if (!user) {
      const q = searchParams.toString()
      const from = safeInternalPath(q ? `${pathname}?${q}` : pathname)
      router.replace(`/login?from=${encodeURIComponent(from)}`)
    }
  }, [user, ready, router, pathname, searchParams])

  return (
    <PageHeaderProvider>
      <AppShell bootstrapping={booting}>
        {booting ? <PageBootLoading /> : children}
      </AppShell>
    </PageHeaderProvider>
  )
}

export function SuperAdminGuard({ children }: { children: React.ReactNode }) {
  const { user, ready } = useAuth()
  const router = useRouter()

  useEffect(() => {
    if (!ready) return
    if (user && !isSuperAdmin(user)) {
      router.replace('/dashboard')
    }
  }, [user, ready, router])

  if (!ready || !user || !isSuperAdmin(user)) {
    return <PageBootLoading />
  }
  return <>{children}</>
}

export function GuestOnly({ children }: { children: React.ReactNode }) {
  const { user, ready } = useAuth()
  const router = useRouter()

  useEffect(() => {
    if (ready && user) router.replace('/dashboard')
  }, [user, ready, router])

  if (!ready || user) return <PageBootLoading />
  return <>{children}</>
}
