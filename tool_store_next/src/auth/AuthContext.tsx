'use client'

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react'
import { clearSession, readSession } from './session'
import type { SessionUser } from '../types/models'

type AuthContextValue = {
  user: SessionUser | null
  setUser: (user: SessionUser | null) => void
  logout: () => void
  refresh: () => void
  ready: boolean
}

const AuthContext = createContext<AuthContextValue | null>(null)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<SessionUser | null>(null)
  const [ready, setReady] = useState(false)

  useEffect(() => {
    setUser(readSession())
    setReady(true)
  }, [])

  const refresh = useCallback(() => {
    setUser(readSession())
  }, [])

  const logout = useCallback(() => {
    clearSession()
    setUser(null)
  }, [])

  const value = useMemo(
    () => ({ user, setUser, logout, refresh, ready }),
    [user, logout, refresh, ready],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used within AuthProvider')
  return ctx
}
