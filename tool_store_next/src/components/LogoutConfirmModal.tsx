'use client'

import { useEffect } from 'react'
import { usePrefs } from '@/prefs/PreferencesContext'

type Props = {
  open: boolean
  busy?: boolean
  onClose: () => void
  onConfirm: () => void
}

export function LogoutConfirmModal({
  open,
  busy,
  onClose,
  onConfirm,
}: Props) {
  const { t } = usePrefs()

  useEffect(() => {
    if (!open) return
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose()
    }
    document.addEventListener('keydown', onKey)
    return () => document.removeEventListener('keydown', onKey)
  }, [open, onClose])

  if (!open) return null

  return (
    <div className="modal-backdrop" role="presentation" onClick={onClose}>
      <div
        className="modal-panel"
        role="dialog"
        aria-modal="true"
        aria-labelledby="logout-modal-title"
        onClick={(e) => e.stopPropagation()}
      >
        <header className="modal-header">
          <h3 id="logout-modal-title">{t('logout')}</h3>
          <p className="muted">{t('logoutConfirm')}</p>
        </header>
        <div className="modal-actions">
          <button
            type="button"
            className="btn btn-ghost"
            onClick={onClose}
            disabled={busy}
          >
            {t('close')}
          </button>
          <button
            type="button"
            className="btn btn-danger"
            onClick={onConfirm}
            disabled={busy}
          >
            {busy ? '…' : t('logout')}
          </button>
        </div>
      </div>
    </div>
  )
}
