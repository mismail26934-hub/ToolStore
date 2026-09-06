'use client'

import { useEffect, useState, type FormEvent } from 'react'
import Link from 'next/link'
import { useParams, usePathname, useRouter } from 'next/navigation'
import { SuperiorPickerModal } from '@/components/SuperiorPickerModal'
import { SuperiorPickField } from '@/components/SuperiorPickField'
import { PageHeader } from '@/components/PageHeader'
import { useUser, useUserMutations } from '@/features/users/useUsers'
import { superiorDisplayName } from '@/lib/displayLabel'
import type { UserRow } from '@/types/models'
import { USER_LEVELS } from '@/types/models'

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

function emptyForm(): FormState {
  return {
    idUsers: '',
    username: '',
    password: '',
    confirmPassword: '',
    namaUser: '',
    noTelp: '',
    idTu: '',
    level: 'USER',
    status: '',
    superiorId: '',
    namaSuperior: '',
  }
}

function fromUser(user: UserRow): FormState {
  return {
    idUsers: user.idUsers,
    username: user.username,
    password: user.password,
    confirmPassword: user.password,
    namaUser: user.namaUser,
    noTelp: user.noTelp,
    idTu: user.idTu,
    level: user.level || 'USER',
    status: user.status,
    superiorId: user.superiorId,
    namaSuperior: superiorDisplayName({
      namaSuperior: user.namaSuperior,
    }),
  }
}

export function UserFormPage() {
  const params = useParams<{ idUsers: string }>()
  const idUsers = params.idUsers
  const pathname = usePathname()
  const router = useRouter()
  const isAdd = pathname.endsWith('/new') || !idUsers

  const remote = useUser(isAdd ? undefined : idUsers, !isAdd)
  const [form, setForm] = useState<FormState>(emptyForm)
  const [pickerOpen, setPickerOpen] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const { add, edit, remove } = useUserMutations()
  const submitting = add.isPending || edit.isPending || remove.isPending

  useEffect(() => {
    if (remote.data && !isAdd) {
      setForm(fromUser(remote.data))
    }
  }, [remote.data, isAdd])

  const patch = (p: Partial<FormState>) => setForm((f) => ({ ...f, ...p }))

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault()
    setError(null)

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
    if (!form.level.trim()) return setError('Level wajib dipilih')
    if (!form.superiorId.trim()) return setError('Superior wajib dipilih')

    const payload = {
      idUsers: isAdd ? '' : form.idUsers || idUsers || '',
      username: form.username.trim(),
      password,
      namaUser: form.namaUser.trim(),
      noTelp: form.noTelp.trim(),
      idTu: form.idTu.trim(),
      level: form.level.trim(),
      status: form.status,
      superiorId: form.superiorId.trim(),
      foto: '',
      token: '',
    }

    try {
      if (isAdd) await add.mutateAsync(payload)
      else await edit.mutateAsync(payload)
      router.replace('/users')
    } catch (err) {
      setError((err as Error).message)
    }
  }

  const onDelete = async () => {
    if (!window.confirm(`Hapus user ${form.username || form.idUsers}?`)) return
    setError(null)
    try {
      await remove.mutateAsync({
        idUsers: form.idUsers || idUsers || '',
        username: form.username,
        password: form.password,
        namaUser: form.namaUser,
        noTelp: form.noTelp,
        idTu: form.idTu,
        level: form.level,
        status: form.status,
        superiorId: form.superiorId,
      })
      router.replace('/users')
    } catch (err) {
      setError((err as Error).message)
    }
  }

  return (
    <div className="page">
      <PageHeader
        title={isAdd ? 'Add User' : 'Edit User'}
        subtitle="Informasi user & akses role"
      >
        <Link className="btn btn-ghost" href="/users">
          Back
        </Link>
      </PageHeader>

      {!isAdd && remote.isLoading && (
        <div className="panel">Loading user…</div>
      )}
      {!isAdd && remote.isError && (
        <div className="alert alert-error">
          {(remote.error as Error)?.message}
        </div>
      )}

      <form className="panel stack" onSubmit={onSubmit}>
        <div className="form-panel-header">
          <h3>User Information</h3>
          {!isAdd && (
            <button
              type="button"
              className="btn btn-danger btn-sm btn-with-icon"
              onClick={onDelete}
              disabled={submitting}
            >
              <svg
                className="btn-icon-svg"
                viewBox="0 0 24 24"
                width="18"
                height="18"
                aria-hidden
                fill="none"
              >
                <path
                  stroke="currentColor"
                  strokeWidth="1.8"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M4 7h16M9 7V5a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2M6 7l1 12a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2l1-12M10 11v6M14 11v6"
                />
              </svg>
              <span className="btn-label">Delete</span>
            </button>
          )}
        </div>
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
            <select
              value={form.level}
              onChange={(e) => patch({ level: e.target.value })}
              required
            >
              {USER_LEVELS.map((lv) => (
                <option key={lv} value={lv}>
                  {lv}
                </option>
              ))}
            </select>
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

        <button
          type="submit"
          className="btn btn-primary btn-block"
          disabled={submitting}
        >
          {submitting ? 'Saving…' : isAdd ? 'Save User' : 'Update User'}
        </button>
      </form>

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
  )
}
