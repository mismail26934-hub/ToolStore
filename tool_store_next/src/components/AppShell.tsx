'use client'

import { useEffect, useRef, useState } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import Link from 'next/link'
import { usePathname, useRouter, useSearchParams } from 'next/navigation'
import { useAuth } from '@/auth/AuthContext'
import { isSuperAdmin } from '@/auth/session'
import { FcmRegistrar } from '@/components/FcmRegistrar'
import { LogoutConfirmModal } from '@/components/LogoutConfirmModal'
import {
  usePageHeaderActionsHostSetter,
  usePageHeaderMeta,
} from '@/components/PageHeader'
import { ProfileModal } from '@/components/ProfileModal'
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

function SunIcon() {
  return (
    <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden fill="none">
      <circle cx="12" cy="12" r="3.6" stroke="currentColor" strokeWidth="1.8" />
      <path
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
        d="M12 3.2v2.1M12 18.7v2.1M3.2 12h2.1M18.7 12h2.1M5.6 5.6l1.5 1.5M16.9 16.9l1.5 1.5M16.9 5.6l-1.5 1.5M5.6 18.4l1.5-1.5"
      />
    </svg>
  )
}

function MoonIcon() {
  return (
    <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden>
      <path
        fill="currentColor"
        d="M12.2 2a9.9 9.9 0 0 0-1.4.1 8.5 8.5 0 1 0 11.1 11.1A9.9 9.9 0 0 1 12.2 2Z"
      />
    </svg>
  )
}

function UserIcon() {
  return (
    <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden fill="none">
      <circle cx="12" cy="8" r="3.2" stroke="currentColor" strokeWidth="1.8" />
      <path
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
        d="M5.5 19c1.4-3 3.6-4.5 6.5-4.5S17.1 16 18.5 19"
      />
    </svg>
  )
}

export function AppShell({
  children,
  bootstrapping = false,
}: {
  children: React.ReactNode
  bootstrapping?: boolean
}) {
  const { user, logout } = useAuth()
  const { t, isDark, toggleTheme, isEnglish, toggleLocale } = usePrefs()
  const router = useRouter()
  const pathname = usePathname()
  const search = useSearchParams()
  const qc = useQueryClient()
  const [menuOpen, setMenuOpen] = useState(false)
  const [manageOpen, setManageOpen] = useState(false)
  const [sessionOpen, setSessionOpen] = useState(false)
  const [profileOpen, setProfileOpen] = useState(false)
  const [logoutOpen, setLogoutOpen] = useState(false)
  const manageRef = useRef<HTMLDivElement>(null)
  const sessionRef = useRef<HTMLDivElement>(null)
  const pageMeta = usePageHeaderMeta()
  const setActionsHost = usePageHeaderActionsHostSetter()

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
    setManageOpen(false)
    setSessionOpen(false)
  }, [pathname, search])

  useEffect(() => {
    document.documentElement.classList.toggle('menu-open', menuOpen)
    if (!menuOpen) return
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') setMenuOpen(false)
    }
    document.addEventListener('keydown', onKey)
    document.body.style.overflow = 'hidden'
    return () => {
      document.removeEventListener('keydown', onKey)
      document.body.style.overflow = ''
      document.documentElement.classList.remove('menu-open')
    }
  }, [menuOpen])

  useEffect(() => {
    if (!manageOpen && !sessionOpen) return
    const onDoc = (e: MouseEvent) => {
      const target = e.target as Node
      if (manageOpen && !manageRef.current?.contains(target)) {
        setManageOpen(false)
      }
      if (sessionOpen && !sessionRef.current?.contains(target)) {
        setSessionOpen(false)
      }
    }
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        setManageOpen(false)
        setSessionOpen(false)
      }
    }
    document.addEventListener('mousedown', onDoc)
    document.addEventListener('keydown', onKey)
    return () => {
      document.removeEventListener('mousedown', onDoc)
      document.removeEventListener('keydown', onKey)
    }
  }, [manageOpen, sessionOpen])

  const handleLogout = () => {
    logout()
    qc.clear()
    setLogoutOpen(false)
    router.replace('/login')
  }

  const openProfile = () => {
    setSessionOpen(false)
    setManageOpen(false)
    setMenuOpen(false)
    setProfileOpen(true)
  }

  const openLogout = () => {
    setSessionOpen(false)
    setManageOpen(false)
    setMenuOpen(false)
    setLogoutOpen(true)
  }

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

  const linkClass = (active: boolean) =>
    active ? 'nav-manage-item is-active' : 'nav-manage-item'

  const prefIcons = (autoFcm: boolean) => (
    <>
      <button
        type="button"
        className="btn btn-icon"
        onClick={toggleTheme}
        title={isDark ? t('darkModeOn') : t('darkModeOff')}
        aria-label={t('darkMode')}
        aria-pressed={isDark}
      >
        {isDark ? <MoonIcon /> : <SunIcon />}
      </button>
      <button
        type="button"
        className="btn btn-icon lang-toggle-icon"
        onClick={toggleLocale}
        title={isEnglish ? t('languageEn') : t('languageId')}
        aria-label={t('language')}
        aria-pressed={isEnglish}
      >
        <span className="lang-toggle-code" aria-hidden>
          {isEnglish ? 'ID' : 'EN'}
        </span>
      </button>
      <FcmRegistrar variant="icon" auto={autoFcm} />
    </>
  )

  const navLinks = (
    <>
      <div className="nav-menu-label">{t('appearance')}</div>
      <div className="nav-menu-prefs">{prefIcons(false)}</div>
      <div className="nav-menu-label">{t('manage')}</div>
      <Link
        href="/dashboard"
        className={linkClass(pathname === '/dashboard')}
        onClick={() => setMenuOpen(false)}
      >
        {t('dashboard')}
      </Link>
      <div className="nav-menu-label">{t('forms')}</div>
      {formsLinks.map((item) => (
        <Link
          key={item.href}
          href={item.href}
          className={linkClass(formsInboxActive(item.inbox))}
          onClick={() => setMenuOpen(false)}
        >
          {item.label}
        </Link>
      ))}
      {isSuperAdmin(user) && (
        <Link
          href="/users"
          className={linkClass(pathname.startsWith('/users'))}
          onClick={() => setMenuOpen(false)}
        >
          {t('users')}
        </Link>
      )}
      {isSuperAdmin(user) && (
        <Link
          href="/superiors"
          className={linkClass(pathname.startsWith('/superiors'))}
          onClick={() => setMenuOpen(false)}
        >
          {t('superiors')}
        </Link>
      )}
    </>
  )

  return (
    <div
      className={`app-shell${menuOpen ? ' menu-open' : ''}${bootstrapping ? ' app-shell--boot' : ''}`}
    >
      <div className="topbar-glass" aria-hidden />

      <header className="topbar">
        {bootstrapping ? (
          <>
            <div className="brand-row" aria-hidden>
              <div className="boot-brand-skel">
                <span className="boot-line-skel boot-line-skel--title" />
                <span className="boot-line-skel boot-line-skel--tagline" />
              </div>
            </div>
            <div className="top-actions" aria-hidden>
              <div className="boot-actions-skel boot-actions-skel--bar">
                <span className="boot-pill boot-pill--sm" />
                <span className="boot-pill" />
                <span className="boot-pill boot-pill--icon" />
                <span className="boot-pill boot-pill--icon" />
                <span className="boot-pill boot-pill--icon" />
                <span className="boot-pill boot-pill--account" />
              </div>
              <div className="boot-actions-skel boot-actions-skel--mobile">
                <span className="boot-pill boot-pill--icon" />
              </div>
            </div>
          </>
        ) : (
          <>
            <div className="brand-row">
              {pageMeta?.title ? (
                <div className="page-nav-title">
                  <h1>{pageMeta.title}</h1>
                  {pageMeta.subtitle ? <p>{pageMeta.subtitle}</p> : null}
                </div>
              ) : (
                <div className="brand">
                  {t('appName')}
                  <span>{t('appTagline')}</span>
                </div>
              )}
            </div>

            <div className="top-actions">
              <div
                className="page-nav-actions"
                ref={setActionsHost}
                aria-label="Page actions"
              />

              <div className="top-actions-panel top-actions-panel--bar">
                <div
                  className={`nav-manage${manageOpen ? ' is-open' : ''}`}
                  ref={manageRef}
                >
                  <button
                    type="button"
                    className="btn"
                    aria-expanded={manageOpen}
                    onClick={() => setManageOpen((v) => !v)}
                  >
                    {t('manage')}
                    <span className="nav-manage-caret" aria-hidden>
                      ▾
                    </span>
                  </button>
                  {manageOpen && (
                    <div className="nav-manage-menu" role="menu">
                      <Link
                        href="/dashboard"
                        className={linkClass(pathname === '/dashboard')}
                        role="menuitem"
                        onClick={() => setManageOpen(false)}
                      >
                        {t('dashboard')}
                      </Link>
                      <div className="nav-menu-label">{t('forms')}</div>
                      {formsLinks.map((item) => (
                        <Link
                          key={item.href}
                          href={item.href}
                          className={linkClass(formsInboxActive(item.inbox))}
                          role="menuitem"
                          onClick={() => setManageOpen(false)}
                        >
                          {item.label}
                        </Link>
                      ))}
                      {isSuperAdmin(user) && (
                        <Link
                          href="/users"
                          className={linkClass(pathname.startsWith('/users'))}
                          role="menuitem"
                          onClick={() => setManageOpen(false)}
                        >
                          {t('users')}
                        </Link>
                      )}
                      {isSuperAdmin(user) && (
                        <Link
                          href="/superiors"
                          className={linkClass(
                            pathname.startsWith('/superiors'),
                          )}
                          role="menuitem"
                          onClick={() => setManageOpen(false)}
                        >
                          {t('superiors')}
                        </Link>
                      )}
                    </div>
                  )}
                </div>

                {prefIcons(true)}

                <div className="nav-session">
                  <div
                    className={`nav-session-menu${sessionOpen ? ' is-open' : ''}`}
                    ref={sessionRef}
                  >
                    <button
                      type="button"
                      className="btn nav-account"
                      aria-haspopup="menu"
                      aria-expanded={sessionOpen}
                      title={`${user?.name || user?.username} · ${user?.level || ''}`}
                      onClick={() => {
                        setManageOpen(false)
                        setSessionOpen((v) => !v)
                      }}
                    >
                      <UserIcon />
                      <span className="nav-user">
                        <span className="nav-user-name">
                          {user?.name || user?.username}
                        </span>
                        <span className="nav-user-level">
                          {user?.level || '—'}
                        </span>
                      </span>
                    </button>
                    {sessionOpen && (
                      <div className="nav-manage-menu" role="menu">
                        <button
                          type="button"
                          role="menuitem"
                          className="nav-manage-item"
                          onClick={openProfile}
                        >
                          {t('myProfile')}
                        </button>
                        <button
                          type="button"
                          role="menuitem"
                          className="nav-manage-item"
                          onClick={openLogout}
                        >
                          {t('logout')}
                        </button>
                      </div>
                    )}
                  </div>
                </div>
              </div>

              <div className="top-actions-mobile">
                <button
                  type="button"
                  className="btn btn-icon top-menu-toggle"
                  aria-label={menuOpen ? 'Close menu' : 'Open menu'}
                  aria-expanded={menuOpen}
                  onClick={() => setMenuOpen((v) => !v)}
                >
                  <MenuIcon open={menuOpen} />
                </button>
              </div>
            </div>
          </>
        )}
      </header>

      {!bootstrapping && menuOpen && (
        <div
          className="top-menu-backdrop"
          role="presentation"
          onClick={() => setMenuOpen(false)}
        />
      )}

      {!bootstrapping && (
        <div
          className={`top-actions-panel top-actions-panel--float${menuOpen ? ' is-open' : ''}`}
        >
          <div className="nav-user nav-user--menu">
            <div className="nav-user-text">
              <span className="nav-user-name">
                {user?.name || user?.username}
              </span>
              <span className="nav-user-level">{user?.level || '—'}</span>
            </div>
          </div>
          {navLinks}
        </div>
      )}

      <main className="main">{children}</main>

      <ProfileModal open={profileOpen} onClose={() => setProfileOpen(false)} />
      <LogoutConfirmModal
        open={logoutOpen}
        onClose={() => setLogoutOpen(false)}
        onConfirm={handleLogout}
      />
    </div>
  )
}
