'use client'

import { useState, type FormEvent } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { useLogin } from '@/features/auth/useLogin'
import { registerWebFcm, isFcmConfigured } from '@/features/fcm/registerWebFcm'
import { usePrefs } from '@/prefs/PreferencesContext'

function WrenchMark() {
  return (
    <svg
      className="login-mark-svg"
      viewBox="0 0 48 48"
      fill="none"
      aria-hidden
    >
      <path
        d="M31.5 8.2a9.2 9.2 0 0 0-12.7 12.7L8.2 31.5a3.2 3.2 0 0 0 4.5 4.5l10.6-10.6A9.2 9.2 0 0 0 39.8 16.5l-5.8 5.8-4.2-4.2 5.8-5.8a9.15 9.15 0 0 0-4.1-4.1Z"
        fill="currentColor"
      />
    </svg>
  )
}

function EyeIcon({ open }: { open: boolean }) {
  if (open) {
    return (
      <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden>
        <path
          fill="currentColor"
          d="M12 5c-5 0-9.3 3.1-11 7 1.7 3.9 6 7 11 7s9.3-3.1 11-7c-1.7-3.9-6-7-11-7Zm0 12a5 5 0 1 1 0-10 5 5 0 0 1 0 10Zm0-2.5A2.5 2.5 0 1 0 12 9a2.5 2.5 0 0 0 0 5Z"
        />
      </svg>
    )
  }
  return (
    <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden>
      <path
        fill="currentColor"
        d="M3.3 2.2 2.2 3.3l3.1 3.1C3.5 8 1.9 9.8 1 12c1.7 3.9 6 7 11 7 2 0 3.9-.5 5.5-1.3l3.2 3.2 1.1-1.1L3.3 2.2ZM12 17c-3.9 0-7.2-2.2-9-5 .7-1.3 1.8-2.5 3.1-3.4l2.1 2.1A5 5 0 0 0 14.3 15l1.9 1.9c-1.3.7-2.7 1.1-4.2 1.1Zm9-5c-.4 1-.9 1.9-1.6 2.7l-1.5-1.5c.4-.5.7-1.1.9-1.7-1.8-2.8-5.1-5-9-5-.5 0-1 0-1.5.1L6.4 5.7C8.1 5.2 10 5 12 5c5 0 9.3 3.1 11 7Z"
      />
    </svg>
  )
}

function SunIcon() {
  return (
    <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden>
      <path
        fill="currentColor"
        d="M12 18a6 6 0 1 1 0-12 6 6 0 0 1 0 12Zm0-16h0v2.5h0V2Zm0 19.5h0V24h0v-2.5ZM2 12h2.5v0H2v0Zm17.5 0H22v0h-2.5v0ZM5.05 5.05l1.77 1.77-1.77-1.77Zm12.13 12.13 1.77 1.77-1.77-1.77ZM18.95 5.05l-1.77 1.77 1.77-1.77ZM6.82 17.18l-1.77 1.77 1.77-1.77Z"
      />
      <circle cx="12" cy="12" r="4.25" fill="currentColor" />
      <g stroke="currentColor" strokeWidth="1.8" strokeLinecap="round">
        <path d="M12 3.2v2.1M12 18.7v2.1M3.2 12h2.1M18.7 12h2.1M5.6 5.6l1.5 1.5M16.9 16.9l1.5 1.5M16.9 5.6l-1.5 1.5M5.6 18.4l1.5-1.5" />
      </g>
    </svg>
  )
}

function MoonIcon() {
  return (
    <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden>
      <path
        fill="currentColor"
        d="M12.2 2a9.9 9.9 0 0 0-1.4.1 8.5 8.5 0 1 0 11.1 11.1A9.9 9.9 0 0 1 12.2 2Z"
      />
    </svg>
  )
}

function LangIcon() {
  return (
    <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden>
      <path
        fill="currentColor"
        d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Zm7.4 9h-3.1a15.6 15.6 0 0 0-1.3-5.1A8.1 8.1 0 0 1 19.4 11ZM12 3.9c.9 1.2 1.7 3.3 2.1 5.6H9.9C10.3 7.2 11.1 5.1 12 3.9ZM4.6 13h3.1c.2 1.8.7 3.5 1.3 5.1A8.1 8.1 0 0 1 4.6 13Zm3.1-2H4.6a8.1 8.1 0 0 1 4.4-5.1A15.6 15.6 0 0 0 7.7 11Zm1.9 2h4.8c-.3 1.9-.9 3.7-1.7 5-.3.1-.7.1-1.1.1s-.8 0-1.1-.1c-.8-1.3-1.4-3.1-1.7-5Zm4.8-2H9.6c.3-1.9.9-3.7 1.7-5 .3-.1.7-.1 1.1-.1s.8 0 1.1.1c.8 1.3 1.4 3.1 1.7 5Zm.9 7.1c.6-1.6 1.1-3.3 1.3-5.1h3.1a8.1 8.1 0 0 1-4.4 5.1Z"
      />
    </svg>
  )
}

export function LoginPage() {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const login = useLogin()
  const router = useRouter()
  const searchParams = useSearchParams()
  const from = searchParams.get('from') || '/dashboard'
  const { t, isDark, toggleTheme, isEnglish, toggleLocale } = usePrefs()

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault()
    try {
      await login.mutateAsync({ username: username.trim(), password })
      if (isFcmConfigured() && Notification.permission === 'granted') {
        void registerWebFcm()
      }
      router.replace(from)
    } catch {
      // error shown below via login.error
    }
  }

  return (
    <div className="login-page">
      <div className="login-shell">
        <aside className="login-brand" aria-hidden={false}>
          <div className="login-brand-glow" aria-hidden />
          <div className="login-brand-grid" aria-hidden />
          <div className="login-brand-content">
            <div className="login-mark">
              <WrenchMark />
            </div>
            <p className="login-kicker">{t('loginKicker')}</p>
            <h1 className="login-brand-title">{t('appName')}</h1>
            <p className="login-brand-copy">{t('loginTagline')}</p>
          </div>
        </aside>

        <section className="login-panel">
          <form className="login-form" onSubmit={onSubmit} noValidate>
            <div className="login-form-top">
              <header className="login-form-head">
                <h2>{t('login')}</h2>
                <p>{t('signInContinue')}</p>
              </header>
              <div className="login-icon-actions" aria-label={t('appearance')}>
                <button
                  type="button"
                  className="login-icon-btn"
                  onClick={toggleTheme}
                  title={isDark ? t('darkModeOn') : t('darkModeOff')}
                  aria-label={t('darkMode')}
                  aria-pressed={isDark}
                >
                  {isDark ? <MoonIcon /> : <SunIcon />}
                </button>
                <button
                  type="button"
                  className="login-icon-btn"
                  onClick={toggleLocale}
                  title={isEnglish ? t('languageEn') : t('languageId')}
                  aria-label={t('language')}
                  aria-pressed={isEnglish}
                >
                  <LangIcon />
                  <span className="login-lang-code">
                    {isEnglish ? 'EN' : 'ID'}
                  </span>
                </button>
              </div>
            </div>

            <label className="login-field">
              <span>{t('username')}</span>
              <input
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                autoComplete="username"
                placeholder="nama.pengguna"
                required
              />
            </label>

            <label className="login-field">
              <span>{t('password')}</span>
              <div className="login-input-wrap">
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  autoComplete="current-password"
                  placeholder="••••••••"
                  required
                />
                <button
                  type="button"
                  className="login-eye"
                  onClick={() => setShowPassword((v) => !v)}
                  aria-label={showPassword ? t('hide') : t('show')}
                >
                  <EyeIcon open={showPassword} />
                </button>
              </div>
            </label>

            {login.isError && (
              <div className="alert alert-error login-error" role="alert">
                {(login.error as Error)?.message || 'Login gagal'}
              </div>
            )}

            <button
              type="submit"
              className="login-submit"
              disabled={login.isPending}
            >
              {login.isPending ? t('signingIn') : t('login')}
            </button>
          </form>
        </section>
      </div>
    </div>
  )
}
