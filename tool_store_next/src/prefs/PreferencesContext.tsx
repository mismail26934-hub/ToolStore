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
import { messages, type LocaleCode, type MessageKey } from '@/i18n/messages'

const THEME_KEY = 'toolstore:is_dark_mode'
const LOCALE_KEY = 'toolstore:app_locale_code'

type ThemeMode = 'light' | 'dark'

type PrefsContextValue = {
  ready: boolean
  theme: ThemeMode
  isDark: boolean
  setDark: (enabled: boolean) => void
  toggleTheme: () => void
  locale: LocaleCode
  isEnglish: boolean
  setEnglish: (enabled: boolean) => void
  toggleLocale: () => void
  t: (key: MessageKey) => string
}

const PrefsContext = createContext<PrefsContextValue | null>(null)

function readTheme(): ThemeMode {
  if (typeof window === 'undefined') return 'light'
  return localStorage.getItem(THEME_KEY) === '1' ? 'dark' : 'light'
}

function readLocale(): LocaleCode {
  if (typeof window === 'undefined') return 'id'
  return localStorage.getItem(LOCALE_KEY) === 'en' ? 'en' : 'id'
}

function applyDomTheme(theme: ThemeMode) {
  document.documentElement.setAttribute('data-theme', theme)
  document.documentElement.style.colorScheme = theme
}

function applyDomLocale(locale: LocaleCode) {
  document.documentElement.lang = locale
}

export function PreferencesProvider({ children }: { children: ReactNode }) {
  const [ready, setReady] = useState(false)
  const [theme, setTheme] = useState<ThemeMode>('light')
  const [locale, setLocale] = useState<LocaleCode>('id')

  useEffect(() => {
    const nextTheme = readTheme()
    const nextLocale = readLocale()
    setTheme(nextTheme)
    setLocale(nextLocale)
    applyDomTheme(nextTheme)
    applyDomLocale(nextLocale)
    setReady(true)
  }, [])

  const setDark = useCallback((enabled: boolean) => {
    const next: ThemeMode = enabled ? 'dark' : 'light'
    setTheme(next)
    applyDomTheme(next)
    localStorage.setItem(THEME_KEY, enabled ? '1' : '0')
  }, [])

  const setEnglish = useCallback((enabled: boolean) => {
    const next: LocaleCode = enabled ? 'en' : 'id'
    setLocale(next)
    applyDomLocale(next)
    localStorage.setItem(LOCALE_KEY, next)
  }, [])

  const t = useCallback(
    (key: MessageKey) => messages[locale][key] ?? messages.en[key] ?? key,
    [locale],
  )

  const value = useMemo<PrefsContextValue>(
    () => ({
      ready,
      theme,
      isDark: theme === 'dark',
      setDark,
      toggleTheme: () => setDark(theme !== 'dark'),
      locale,
      isEnglish: locale === 'en',
      setEnglish,
      toggleLocale: () => setEnglish(locale !== 'en'),
      t,
    }),
    [ready, theme, locale, setDark, setEnglish, t],
  )

  return <PrefsContext.Provider value={value}>{children}</PrefsContext.Provider>
}

export function usePrefs() {
  const ctx = useContext(PrefsContext)
  if (!ctx) throw new Error('usePrefs must be used within PreferencesProvider')
  return ctx
}
