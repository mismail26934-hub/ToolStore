'use client'

import { useEffect } from 'react'
import { usePathname, useRouter } from 'next/navigation'
import { useAuth } from '@/auth/AuthContext'
import { isSuperAdmin } from '@/auth/session'
import { AppShell } from '@/components/AppShell'

export function AuthGuard({ children }: { children: React.ReactNode }) {
  const { user, ready } = useAuth()
  const router = useRouter()
  const pathname = usePathname()

  useEffect(() => {
    if (!ready) return
    if (!user) {
      router.replace(`/login?from=${encodeURIComponent(pathname)}`)
    }
  }, [user, ready, router, pathname])

  if (!ready || !user) return <div className="panel">Loading…</div>
  return <AppShell>{children}</AppShell>
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
    return <div className="panel">Loading…</div>
  }
  return <>{children}</>
}

export function GuestOnly({ children }: { children: React.ReactNode }) {
  const { user, ready } = useAuth()
  const router = useRouter()

  useEffect(() => {
    if (ready && user) router.replace('/dashboard')
  }, [user, ready, router])

  if (!ready) return <div className="panel">Loading…</div>
  if (user) return <div className="panel">Redirecting…</div>
  return <>{children}</>
}
