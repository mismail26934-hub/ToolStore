'use client'

import { useEffect, useState } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import Link from 'next/link'
import { usePathname, useRouter, useSearchParams } from 'next/navigation'
import { useAuth } from '@/auth/AuthContext'
import { isSuperAdmin } from '@/auth/session'
import { FcmRegistrar } from '@/components/FcmRegistrar'
import { usePrefs } from '@/prefs/PreferencesContext'

function MenuIcon({ open }: { open: boolean }) {
  return (
    <svg viewBox="0 0 24 24" width="22" height="22" aria-hidden fill="none">
      {open ? (
        <path
          stroke="currentColor"
          strokeWidth="2.2"
          strokeLinecap="round"
          d="M6 6l12 12M18 6L6 18"
        />
      ) : (
        <path
          stroke="currentColor"
          strokeWidth="2.2"
          strokeLinecap="round"
          d="M4 7h16M4 12h16M4 17h16"
        />
      )}
    </svg>
  )
}

export function AppShell({ children }: { children: React.ReactNode }) {
  const { user, logout } = useAuth()
  const { t, isDark, setDark, isEnglish, setEnglish } = usePrefs()
  const router = useRouter()
  const pathname = usePathname()
  const search = useSearchParams()
  const qc = useQueryClient()
  const [menuOpen, setMenuOpen] = useState(false)

  const formsLinks = [
    { href: '/forms', inbox: 'active', label: t('dataTool') },
    { href: '/forms?inbox=completed', inbox: 'completed', label: t('completed') },
    { href: '/forms?inbox=hold', inbox: 'hold', label: t('hold') },
    {
      href: '/forms?inbox=rejected-superior',
      inbox: 'rejected-superior',
      label: t('rejectedSuperior'),
    },
    {
      href: '/forms?inbox=rejected-dept',
      inbox: 'rejected-dept',
      label: t('rejectedDept'),
    },
  ] as const

  useEffect(() => {
    setMenuOpen(false)
  }, [pathname, search])

  useEffect(() => {
    if (!menuOpen) return
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') setMenuOpen(false)
    }
    document.addEventListener('keydown', onKey)
    document.body.style.overflow = 'hidden'
    return () => {
      document.removeEventListener('keydown', onKey)
      document.body.style.overflow = ''
    }
  }, [menuOpen])

  const handleLogout = () => {
    logout()
    qc.clear()
    router.replace('/login')
  }

  const navClass = (href: string) =>
    pathname === href || pathname.startsWith(`${href}/`)
      ? 'nav-item active'
      : 'nav-item'

  const formsInboxActive = (inbox: string) => {
    if (pathname !== '/forms') return false
    const current = search.get('inbox') || 'active'
    const hasMilestone =
      !!search.get('milestone') || !!search.get('milestones')
    if (hasMilestone) return false
    if (inbox === 'active') {
      return current === 'active' || (!search.get('inbox') && !hasMilestone)
    }
    return current === inbox
  }

  const sidebar = (
    <>
      <div className="brand">
        <div className="brand-icon" aria-hidden>
          🔧
        </div>
        <div className="brand-text">
          <div className="brand-title">{t('appName')}</div>
          <div className="brand-sub">{user?.name || user?.username}</div>
        </div>
      </div>

      <nav className="nav" aria-label="Main">
        <Link href="/dashboard" className={navClass('/dashboard')}>
          {t('dashboard')}
        </Link>
        <Link href="/profile" className={navClass('/profile')}>
          {t('myProfile')}
        </Link>
        <div className="nav-section-label">{t('forms')}</div>
        {formsLinks.map((item) => (
          <Link
            key={item.href}
            href={item.href}
            className={
              formsInboxActive(item.inbox) ? 'nav-item active' : 'nav-item'
            }
          >
            {item.label}
          </Link>
        ))}
        {isSuperAdmin(user) && (
          <Link href="/users" className={navClass('/users')}>
            {t('users')}
          </Link>
        )}
      </nav>

      <div className="sidebar-prefs">
        <div className="nav-section-label">{t('appearance')}</div>
        <label className="pref-toggle">
          <span>
            <strong>{t('darkMode')}</strong>
            <small>{isDark ? t('darkModeOn') : t('darkModeOff')}</small>
          </span>
          <input
            type="checkbox"
            checked={isDark}
            onChange={(e) => setDark(e.target.checked)}
          />
        </label>
        <label className="pref-toggle">
          <span>
            <strong>{t('language')}</strong>
            <small>{isEnglish ? t('languageEn') : t('languageId')}</small>
          </span>
          <input
            type="checkbox"
            checked={isEnglish}
            onChange={(e) => setEnglish(e.target.checked)}
          />
        </label>
        <FcmRegistrar />
      </div>

      <button
        type="button"
        className="btn btn-ghost logout-btn"
        onClick={handleLogout}
      >
        {t('logout')}
      </button>
    </>
  )

  return (
    <div className={`app-shell${menuOpen ? ' menu-open' : ''}`}>
      <header className="topbar">
        <button
          type="button"
          className="topbar-menu-btn"
          aria-label={menuOpen ? 'Close menu' : 'Open menu'}
          aria-expanded={menuOpen}
          aria-controls="app-sidebar"
          onClick={() => setMenuOpen((v) => !v)}
        >
          <MenuIcon open={menuOpen} />
        </button>
        <div className="topbar-brand">
          <span className="topbar-title">{t('appName')}</span>
          <span className="topbar-user muted">
            {user?.name || user?.username}
          </span>
        </div>
      </header>

      <div
        className="sidebar-backdrop"
        role="presentation"
        onClick={() => setMenuOpen(false)}
      />

      <aside id="app-sidebar" className="sidebar">
        {sidebar}
      </aside>

      <main className="main">{children}</main>
    </div>
  )
}
