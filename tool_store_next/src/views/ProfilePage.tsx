'use client'

import { useEffect, useState, type FormEvent } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { useAuth } from '@/auth/AuthContext'
import { updateSessionProfile } from '@/auth/session'
import { SuperiorPickerModal } from '@/components/SuperiorPickerModal'
import { useUser, useUserMutations } from '@/features/users/useUsers'

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

export function ProfilePage() {
  const { user, refresh } = useAuth()
  const router = useRouter()
  const idUsers = user?.idUsersApp ?? ''
  const remote = useUser(idUsers || undefined, !!idUsers)
  const { edit } = useUserMutations()
  const [form, setForm] = useState<FormState | null>(null)
  const [pickerOpen, setPickerOpen] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [saved, setSaved] = useState(false)

  useEffect(() => {
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
        namaSuperior: remote.data.namaSuperior,
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
        namaSuperior: user.namaSuperior,
      })
    }
  }, [remote.data, remote.isLoading, user])

  const patch = (p: Partial<FormState>) =>
    setForm((f) => (f ? { ...f, ...p } : f))

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault()
    if (!form) return
    setError(null)
    setSaved(false)

    const password = form.password.trim()
    const confirm =
      form.confirmPassword.trim() === ''
        ? password
        : form.confirmPassword.trim()

    if (!form.username.trim()) return setError('Username wajib diisi')
    if (!password) return setError('Password wajib diisi')
    if (password !== confirm)
      return setError('Password dan konfirmasi tidak sama')
    if (!form.namaUser.trim()) return setError('Nama wajib diisi')
    if (!form.noTelp.trim()) return setError('No. Telp wajib diisi')
    if (!form.idTu.trim()) return setError('ID TU wajib diisi')
    if (!form.superiorId.trim()) return setError('Superior wajib dipilih')

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

  if (!user) {
    return <div className="panel">Redirecting…</div>
  }

  return (
    <div className="page">
      <header className="page-header">
        <div>
          <h1>My Profile</h1>
          <p className="muted">Edit akun login Anda (level tidak dapat diubah)</p>
        </div>
        <div className="page-header-actions">
          <button
            type="button"
            className="btn btn-ghost"
            onClick={() => router.back()}
          >
            Back
          </button>
        </div>
      </header>

      {remote.isLoading && !form && <div className="panel">Loading profile…</div>}
      {remote.isError && (
        <div className="alert alert-error">
          {(remote.error as Error)?.message}
        </div>
      )}

      {form && (
        <form className="panel stack" onSubmit={onSubmit}>
          <h3>User Information</h3>
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

          <h3>Access & Role</h3>
          <div className="grid-2">
            <label className="field">
              <span>Level</span>
              <input value={form.level} readOnly className="input-readonly" />
            </label>
            <label className="field">
              <span>Superior</span>
              <div className="password-row">
                <input
                  value={
                    form.namaSuperior
                      ? `${form.namaSuperior} (${form.superiorId})`
                      : form.superiorId
                  }
                  readOnly
                  placeholder="Pilih superior…"
                />
                <button
                  type="button"
                  className="btn btn-secondary"
                  onClick={() => setPickerOpen(true)}
                >
                  Pick
                </button>
              </div>
            </label>
          </div>

          {error && <div className="alert alert-error">{error}</div>}
          {saved && (
            <div className="alert alert-ok">Profile updated successfully.</div>
          )}

          <div className="row-gap">
            <button
              type="submit"
              className="btn btn-primary"
              disabled={edit.isPending}
            >
              {edit.isPending ? 'Saving…' : 'Update Profile'}
            </button>
            <Link className="btn btn-ghost" href="/dashboard">
              Dashboard
            </Link>
          </div>
        </form>
      )}

      <SuperiorPickerModal
        open={pickerOpen}
        onClose={() => setPickerOpen(false)}
        onSelect={(row) =>
          patch({
            superiorId: row.superiorId,
            namaSuperior:
              row.namaSuperior || row.namaUser || row.username || '',
          })
        }
      />
    </div>
  )
}
