'use client'

import { useEffect, useState } from 'react'
import { useAuth } from '@/auth/AuthContext'
import {
  isFcmConfigured,
  isFcmSupported,
  registerWebFcm,
  type FcmStatus,
} from '@/features/fcm/registerWebFcm'
import { usePrefs } from '@/prefs/PreferencesContext'

function BellIcon({ active }: { active?: boolean }) {
  return (
    <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden fill="none">
      <path
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
        strokeLinejoin="round"
        d="M15.5 17.5H8.5M18 17.5H6l1.2-1.4a2 2 0 0 0 .5-1.3V10a4.3 4.3 0 1 1 8.6 0v4.8c0 .5.2 1 .5 1.3L18 17.5Z"
      />
      {active ? (
        <circle cx="17.5" cy="7" r="2.2" fill="currentColor" />
      ) : (
        <path
          stroke="currentColor"
          strokeWidth="1.8"
          strokeLinecap="round"
          d="M12 4.2V3.5"
        />
      )}
    </svg>
  )
}

export function FcmRegistrar({
  auto = true,
  variant = 'card',
}: {
  auto?: boolean
  variant?: 'card' | 'icon'
}) {
  const { user, ready } = useAuth()
  const { t } = usePrefs()
  const [status, setStatus] = useState<FcmStatus>(() => {
    if (!isFcmSupported()) return 'unsupported'
    if (!isFcmConfigured()) return 'not_configured'
    if (
      typeof window !== 'undefined' &&
      localStorage.getItem('toolstore:fcm_token')
    ) {
      return 'saved'
    }
    return 'ready'
  })
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const run = async () => {
    if (!user) return
    setBusy(true)
    setError(null)
    const result = await registerWebFcm()
    setStatus(result.status)
    if (result.message) setError(result.message)
    setBusy(false)
  }

  useEffect(() => {
    if (!auto || !ready || !user) return
    if (!isFcmConfigured() || !isFcmSupported()) return
    if (localStorage.getItem('toolstore:fcm_token')) {
      setStatus('saved')
      return
    }
    if (Notification.permission === 'granted') {
      void run()
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [auto, ready, user?.idUsersApp])

  const statusText =
    status === 'saved'
      ? t('pushEnabled')
      : status === 'unsupported'
        ? t('pushUnsupported')
        : status === 'not_configured'
          ? t('pushNotConfigured')
          : status === 'denied'
            ? t('pushDisabled')
            : error
              ? error
              : t('pushDisabled')

  const canEnable =
    status !== 'unsupported' &&
    status !== 'not_configured' &&
    status !== 'saved'

  if (variant === 'icon') {
    return (
      <button
        type="button"
        className={`btn btn-icon${status === 'saved' ? ' is-active' : ''}`}
        disabled={busy || !user || !canEnable}
        title={statusText}
        aria-label={`${t('pushNotifications')}: ${statusText}`}
        aria-pressed={status === 'saved'}
        onClick={() => {
          if (canEnable) void run()
        }}
      >
        <BellIcon active={status === 'saved'} />
      </button>
    )
  }

  return (
    <div className="pref-card">
      <div className="pref-card-body">
        <div className="pref-card-title">{t('pushNotifications')}</div>
        <div className="pref-card-sub muted">{statusText}</div>
      </div>
      {canEnable && (
        <button
          type="button"
          className="btn btn-secondary btn-sm"
          disabled={busy || !user}
          onClick={() => void run()}
        >
          {busy ? '…' : t('enablePush')}
        </button>
      )}
    </div>
  )
}
