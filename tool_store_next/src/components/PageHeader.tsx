'use client'

import {
  createContext,
  useCallback,
  useContext,
  useLayoutEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react'
import { createPortal } from 'react-dom'

export type PageHeaderMeta = {
  title: string
  subtitle?: string
} | null

type PageHeaderContextValue = {
  meta: PageHeaderMeta
  setMeta: (meta: PageHeaderMeta) => void
  actionsHost: HTMLElement | null
  setActionsHost: (el: HTMLElement | null) => void
}

const PageHeaderContext = createContext<PageHeaderContextValue | null>(null)

export function PageHeaderProvider({ children }: { children: ReactNode }) {
  const [meta, setMetaState] = useState<PageHeaderMeta>(null)
  const [actionsHost, setActionsHost] = useState<HTMLElement | null>(null)

  const setMeta = useCallback((next: PageHeaderMeta) => {
    setMetaState(next)
  }, [])

  const value = useMemo(
    () => ({ meta, setMeta, actionsHost, setActionsHost }),
    [meta, setMeta, actionsHost],
  )

  return (
    <PageHeaderContext.Provider value={value}>
      {children}
    </PageHeaderContext.Provider>
  )
}

function usePageHeaderContext() {
  const ctx = useContext(PageHeaderContext)
  if (!ctx) {
    throw new Error('PageHeaderProvider is required')
  }
  return ctx
}

export function usePageHeaderMeta() {
  return usePageHeaderContext().meta
}

export function usePageHeaderActionsHostSetter() {
  return usePageHeaderContext().setActionsHost
}

/** Sets navbar title/subtitle and portals action buttons into the topbar. */
export function PageHeader({
  title,
  subtitle,
  children,
}: {
  title: string
  subtitle?: string
  children?: ReactNode
}) {
  const { setMeta, actionsHost } = usePageHeaderContext()

  useLayoutEffect(() => {
    setMeta({ title, subtitle })
    return () => setMeta(null)
  }, [title, subtitle, setMeta])

  if (!children || !actionsHost) return null
  return createPortal(children, actionsHost)
}
