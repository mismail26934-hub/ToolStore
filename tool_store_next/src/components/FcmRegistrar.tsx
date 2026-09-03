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

export function FcmRegistrar({ auto = true }: { auto?: boolean }) {
  const { user, ready } = useAuth()
  const { t } = usePrefs()
  const [status, setStatus] = useState<FcmStatus>(() => {
    if (!isFcmSupported()) return 'unsupported'
    if (!isFcmConfigured()) return 'not_configured'
    if (typeof window !== 'undefined' && localStorage.getItem('toolstore:fcm_token')) {
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
    // Soft auto-register only if permission already granted (no surprise prompt).
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

  return (
    <div className="pref-card">
      <div className="pref-card-body">
        <div className="pref-card-title">{t('pushNotifications')}</div>
        <div className="pref-card-sub muted">{statusText}</div>
      </div>
      {status !== 'unsupported' && status !== 'not_configured' && status !== 'saved' && (
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
