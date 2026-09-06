'use client'

import { useEffect, useState, type FormEvent } from 'react'
import Link from 'next/link'
import { useParams, usePathname, useRouter } from 'next/navigation'
import { PageHeader } from '@/components/PageHeader'
import {
  useSuperior,
  useSuperiorMutations,
} from '@/features/superiors/useSuperiors'
import { usePrefs } from '@/prefs/PreferencesContext'
import type { SuperiorRow } from '@/types/models'

type FormState = {
  superiorId: string
  namaSuperior: string
  statusSuperior: string
  username: string
  namaUser: string
}

function emptyForm(): FormState {
  return {
    superiorId: '',
    namaSuperior: '',
    statusSuperior: 'ACTIVE',
    username: '',
    namaUser: '',
  }
}

function fromRow(row: SuperiorRow): FormState {
  return {
    superiorId: row.superiorId,
    namaSuperior: row.namaSuperior,
    statusSuperior: row.statusSuperior || 'ACTIVE',
    username: row.username,
    namaUser: row.namaUser,
  }
}

export function SuperiorFormPage() {
  const { t } = usePrefs()
  const params = useParams<{ id: string }>()
  const id = params.id
  const pathname = usePathname()
  const router = useRouter()
  const isAdd = pathname.endsWith('/new') || !id
  const remote = useSuperior(isAdd ? undefined : id, !isAdd)
  const [form, setForm] = useState<FormState>(emptyForm)
  const [error, setError] = useState<string | null>(null)
  const { add, edit, remove } = useSuperiorMutations()
  const submitting = add.isPending || edit.isPending || remove.isPending

  useEffect(() => {
    if (remote.data && !isAdd) setForm(fromRow(remote.data))
  }, [remote.data, isAdd])

  const patch = (p: Partial<FormState>) => setForm((f) => ({ ...f, ...p }))

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault()
    setError(null)
    if (!form.namaSuperior.trim()) {
      setError('Nama superior wajib diisi')
      return
    }
    try {
      if (isAdd) {
        await add.mutateAsync({
          namaSuperior: form.namaSuperior.trim(),
          statusSuperior: form.statusSuperior.trim() || 'ACTIVE',
          username: form.username.trim(),
          namaUser: form.namaUser.trim(),
        })
      } else {
        await edit.mutateAsync({
          superiorId: form.superiorId || id,
          namaSuperior: form.namaSuperior.trim(),
          statusSuperior: form.statusSuperior.trim() || 'ACTIVE',
          username: form.username.trim(),
          namaUser: form.namaUser.trim(),
        })
      }
      router.replace('/superiors')
    } catch (err) {
      setError((err as Error).message)
    }
  }

  const onDelete = async () => {
    if (!window.confirm(`Hapus superior ${form.namaSuperior}?`)) return
    try {
      await remove.mutateAsync({
        superiorId: form.superiorId || id,
        namaSuperior: form.namaSuperior,
      })
      router.replace('/superiors')
    } catch (err) {
      setError((err as Error).message)
    }
  }

  return (
    <div className="page">
      <PageHeader
        title={isAdd ? t('addSuperior') : t('editSuperior')}
        subtitle={t('superiorsSubtitle')}
      >
        <Link className="btn btn-ghost" href="/superiors">
          Back
        </Link>
      </PageHeader>

      {!isAdd && remote.isLoading && (
        <div className="panel">{t('loading')}</div>
      )}
      {!isAdd && remote.isError && (
        <div className="alert alert-error">
          {(remote.error as Error).message}
        </div>
      )}

      <form className="panel stack" onSubmit={onSubmit}>
        <div className="form-panel-header">
          <h3>{isAdd ? t('addSuperior') : t('editSuperior')}</h3>
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
        {!isAdd && (
          <label className="field">
            <span>Superior ID</span>
            <input value={form.superiorId} readOnly className="input-readonly" />
          </label>
        )}
        <label className="field">
          <span>Nama superior</span>
          <input
            value={form.namaSuperior}
            onChange={(e) => patch({ namaSuperior: e.target.value })}
            required
          />
        </label>
        <div className="grid-2">
          <label className="field">
            <span>Status</span>
            <select
              value={form.statusSuperior}
              onChange={(e) => patch({ statusSuperior: e.target.value })}
            >
              <option value="ACTIVE">ACTIVE</option>
              <option value="INACTIVE">INACTIVE</option>
            </select>
          </label>
          <label className="field">
            <span>Username</span>
            <input
              value={form.username}
              onChange={(e) => patch({ username: e.target.value })}
            />
          </label>
        </div>
        <label className="field">
          <span>Nama user</span>
          <input
            value={form.namaUser}
            onChange={(e) => patch({ namaUser: e.target.value })}
          />
        </label>

        {error && <div className="alert alert-error">{error}</div>}

        <button
          type="submit"
          className="btn btn-primary btn-block"
          disabled={submitting}
        >
          {submitting ? t('loading') : isAdd ? 'Save' : 'Update'}
        </button>
      </form>
    </div>
  )
}
