'use client'

import { useEffect, useState, type FormEvent } from 'react'
import { useAuth } from '@/auth/AuthContext'
import { updateSessionProfile } from '@/auth/session'
import { SuperiorPickerModal } from '@/components/SuperiorPickerModal'
import { SuperiorPickField } from '@/components/SuperiorPickField'
import { usePrefs } from '@/prefs/PreferencesContext'
import { useUser, useUserMutations } from '@/features/users/useUsers'
import { superiorDisplayName } from '@/lib/displayLabel'

type FormState = {
  idUsers: string
  username: string
  password: string
  confirmPassword: string
  namaUser: string
  noTelp: string
  idTu: string
  level: string
  status: string
  superiorId: string
  namaSuperior: string
}

type Props = {
  open: boolean
  onClose: () => void
}

export function ProfileModal({ open, onClose }: Props) {
  const { user, refresh } = useAuth()
  const { t } = usePrefs()
  const idUsers = user?.idUsersApp ?? ''
  const remote = useUser(idUsers || undefined, open && !!idUsers)
  const { edit } = useUserMutations()
  const [form, setForm] = useState<FormState | null>(null)
  const [pickerOpen, setPickerOpen] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [saved, setSaved] = useState(false)

  useEffect(() => {
    if (!open) return
    setError(null)
    setSaved(false)
  }, [open])

  useEffect(() => {
    if (!open) return
    if (remote.data) {
      setForm({
        idUsers: remote.data.idUsers,
        username: remote.data.username,
        password: remote.data.password,
        confirmPassword: remote.data.password,
        namaUser: remote.data.namaUser,
        noTelp: remote.data.noTelp,
        idTu: remote.data.idTu,
        level: remote.data.level,
        status: remote.data.status,
        superiorId: remote.data.superiorId,
        namaSuperior: superiorDisplayName({
          namaSuperior: remote.data.namaSuperior,
        }),
      })
      return
    }
    if (user && !remote.isLoading && !remote.data) {
      setForm({
        idUsers: user.idUsersApp,
        username: user.username,
        password: user.password,
        confirmPassword: user.password,
        namaUser: user.name,
        noTelp: user.noTelp,
        idTu: user.idTu,
        level: user.level,
        status: user.status,
        superiorId: user.superiorId,
        namaSuperior: superiorDisplayName({
          namaSuperior: user.namaSuperior,
        }),
      })
    }
  }, [open, remote.data, remote.isLoading, user])

  useEffect(() => {
    if (!open) return
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && !pickerOpen) onClose()
    }
    document.addEventListener('keydown', onKey)
    return () => document.removeEventListener('keydown', onKey)
  }, [open, onClose, pickerOpen])

  if (!open) return null

  const patch = (p: Partial<FormState>) =>
    setForm((f) => (f ? { ...f, ...p } : f))

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault()
    if (!form) return
    setError(null)
    setSaved(false)

    const password = form.password.trim()
    const confirmPassword = form.confirmPassword.trim()
    if (password.length < 4) {
      setError('Password minimal 4 karakter')
      return
    }
    if (password !== confirmPassword) {
      setError('Konfirmasi password tidak cocok')
      return
    }

    try {
      await edit.mutateAsync({
        idUsers: form.idUsers,
        username: form.username.trim(),
        password,
        namaUser: form.namaUser.trim(),
        noTelp: form.noTelp.trim(),
        idTu: form.idTu.trim(),
        level: form.level.trim(),
        status: form.status,
        superiorId: form.superiorId.trim(),
        foto: user?.foto ?? '',
        token: user?.token ?? '',
      })
      updateSessionProfile({
        name: form.namaUser.trim(),
        username: form.username.trim(),
        password,
        noTelp: form.noTelp.trim(),
        idTu: form.idTu.trim(),
        superiorId: form.superiorId.trim(),
        namaSuperior: form.namaSuperior.trim(),
        level: form.level.trim(),
        status: form.status,
      })
      refresh()
      setSaved(true)
    } catch (err) {
      setError((err as Error).message)
    }
  }

  return (
    <div className="modal-backdrop" role="presentation" onClick={onClose}>
      <div
        className="modal-panel modal-panel-wide"
        role="dialog"
        aria-modal="true"
        aria-labelledby="profile-modal-title"
        onClick={(e) => e.stopPropagation()}
      >
        <header className="modal-header">
          <h3 id="profile-modal-title">{t('myProfile')}</h3>
          <p className="muted">
            Edit akun login Anda (level tidak dapat diubah)
          </p>
        </header>

        {remote.isLoading && !form && (
          <div className="muted">Loading profile…</div>
        )}
        {remote.isError && (
          <div className="alert alert-error">
            {(remote.error as Error)?.message}
          </div>
        )}

        {form && (
          <form className="modal-form" onSubmit={onSubmit}>
            <div className="modal-body">
              <div className="grid-2">
                <label className="field">
                  <span>Username</span>
                  <input
                    value={form.username}
                    onChange={(e) => patch({ username: e.target.value })}
                    required
                    autoComplete="username"
                  />
                </label>
                <label className="field">
                  <span>Nama</span>
                  <input
                    value={form.namaUser}
                    onChange={(e) => patch({ namaUser: e.target.value })}
                    required
                  />
                </label>
              </div>

              <div className="grid-2">
                <label className="field">
                  <span>Password</span>
                  <input
                    type="password"
                    value={form.password}
                    onChange={(e) => patch({ password: e.target.value })}
                    required
                    autoComplete="new-password"
                  />
                </label>
                <label className="field">
                  <span>Confirm Password</span>
                  <input
                    type="password"
                    value={form.confirmPassword}
                    onChange={(e) => patch({ confirmPassword: e.target.value })}
                    autoComplete="new-password"
                  />
                </label>
              </div>

              <div className="grid-2">
                <label className="field">
                  <span>No. Telp</span>
                  <input
                    value={form.noTelp}
                    onChange={(e) => patch({ noTelp: e.target.value })}
                    required
                  />
                </label>
                <label className="field">
                  <span>ID TU</span>
                  <input
                    value={form.idTu}
                    onChange={(e) => patch({ idTu: e.target.value })}
                    required
                  />
                </label>
              </div>

              <div className="grid-2">
                <label className="field">
                  <span>Level</span>
                  <input
                    value={form.level}
                    readOnly
                    className="input-readonly"
                  />
                </label>
                <label className="field">
                  <span>Superior</span>
                  <SuperiorPickField
                    value={form.namaSuperior || ''}
                    showClear={!!form.superiorId}
                    onOpen={() => setPickerOpen(true)}
                    onClear={() => patch({ superiorId: '', namaSuperior: '' })}
                  />
                </label>
              </div>

              {error && <div className="alert alert-error">{error}</div>}
              {saved && (
                <div className="alert alert-ok">
                  Profile updated successfully.
                </div>
              )}
            </div>

            <div className="modal-actions">
              <button type="button" className="btn btn-ghost" onClick={onClose}>
                {t('close')}
              </button>
              <button
                type="submit"
                className="btn btn-primary"
                disabled={edit.isPending}
              >
                {edit.isPending ? 'Saving…' : 'Update Profile'}
              </button>
            </div>
          </form>
        )}

        <SuperiorPickerModal
          open={pickerOpen}
          onClose={() => setPickerOpen(false)}
          onSelect={(row) =>
            patch({
              superiorId: row.superiorId,
              namaSuperior: superiorDisplayName(row),
            })
          }
        />
      </div>
    </div>
  )
}
