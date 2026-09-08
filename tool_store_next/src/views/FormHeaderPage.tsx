'use client'

import { useEffect, useState, type FormEvent } from 'react'
import Link from 'next/link'
import { useParams, usePathname, useRouter } from 'next/navigation'
import { ApiParam } from '@/api/params'
import { useAuth } from '@/auth/AuthContext'
import { canAddOrEditForm, todayYmd } from '@/auth/roles'
import { UserPickerModal } from '@/components/UserPickerModal'
import { DateInput } from '@/components/DateInput'
import { PageHeader } from '@/components/PageHeader'
import { useForm, useFormMutations } from '@/features/forms/useForms'
import { useToolDetails } from '@/features/tools/useToolDetails'
import { formCheckByDisplay, looksLikeUserId, servicemanDisplay, userPickLabel } from '@/lib/displayLabel'
import { useUser } from '@/features/users/useUsers'
import type { FormRow } from '@/types/models'

const HOLDER_CATS = ['MISSING', 'DAMAGE', 'ADDITIONAL']
const NON_HOLDER_CATS = ['BUDGET', 'NON BUDGET']

type FormState = {
  idForm: string
  formNo: string
  formStatusOrder: string
  formServComment: string
  formDateServName: string
  formServName: string
  formServNameLabel: string
  formCheckBy: string
  formCheckByLabel: string
  formDateCheckBy: string
  formSuperiorAprd: string
  formSuperiorComment: string
  formSadminComment: string
  formMilestone: string
  formSheadAprd: string
  formSheadComment: string
  fromDateUpdate: string
  formUserUpdate: string
}

function emptyForm(userId: string): FormState {
  const today = todayYmd()
  return {
    idForm: '',
    formNo: '',
    formStatusOrder: '',
    formServComment: '',
    formDateServName: today,
    formServName: '',
    formServNameLabel: '',
    formCheckBy: '',
    formCheckByLabel: '',
    formDateCheckBy: today,
    formSuperiorAprd: '',
    formSuperiorComment: '',
    formSadminComment: '',
    formMilestone: '',
    formSheadAprd: '',
    formSheadComment: '',
    fromDateUpdate: today,
    formUserUpdate: userId,
  }
}

function fromRow(row: FormRow): FormState {
  return {
    idForm: row.idForm,
    formNo: row.formNo,
    formStatusOrder: row.formStatusOrder || '',
    formServComment: row.formServComment || '',
    formDateServName: row.formDateServName.slice(0, 10),
    formServName: row.formServName,
    formServNameLabel: servicemanDisplay(row),
    formCheckBy: row.formCheckBy,
    formCheckByLabel: formCheckByDisplay(row),
    formDateCheckBy: row.formDateCheckBy.slice(0, 10),
    formSuperiorAprd: row.formSuperiorAprd,
    formSuperiorComment: row.formSuperiorComment,
    formSadminComment: row.formSadminComment,
    formMilestone: row.formMilestone,
    formSheadAprd: row.formSheadAprd,
    formSheadComment: row.formSheadComment,
    fromDateUpdate: row.fromDateUpdate.slice(0, 10) || todayYmd(),
    formUserUpdate: row.formUserUpdate,
  }
}

export function FormHeaderPage() {
  const params = useParams<{ idForm: string }>()
  const pathname = usePathname()
  const router = useRouter()
  const { user } = useAuth()
  const isAdd = pathname.endsWith('/new') || !params.idForm
  const idForm = params.idForm
  const remote = useForm(isAdd ? undefined : idForm, !isAdd)
  const tools = useToolDetails(idForm ?? '', !isAdd)
  const mutate = useFormMutations()
  const [form, setForm] = useState<FormState>(() =>
    emptyForm(user?.idUsersApp ?? ''),
  )
  const [error, setError] = useState<string | null>(null)
  const [picker, setPicker] = useState<'serv' | 'check' | null>(null)

  useEffect(() => {
    if (remote.data && !isAdd) setForm(fromRow(remote.data))
  }, [remote.data, isAdd])

  const servLookup = useUser(
    looksLikeUserId(form.formServName) ? form.formServName : undefined,
    looksLikeUserId(form.formServName) && !servicemanDisplay(form),
  )
  const checkLookup = useUser(
    looksLikeUserId(form.formCheckBy) ? form.formCheckBy : undefined,
    looksLikeUserId(form.formCheckBy) && !formCheckByDisplay(form),
  )
  const servShown =
    servicemanDisplay(form) ||
    userPickLabel(servLookup.data ?? {}) ||
    (servLookup.isFetching ? 'Memuat…' : '')
  const checkShown =
    formCheckByDisplay(form) ||
    userPickLabel(checkLookup.data ?? {}) ||
    (checkLookup.isFetching ? 'Memuat…' : '')

  const allowed = canAddOrEditForm(user)
  const cats =
    form.formStatusOrder === 'NON HOLDER'
      ? NON_HOLDER_CATS
      : form.formStatusOrder === 'HOLDER'
        ? HOLDER_CATS
        : []
  const patch = (p: Partial<FormState>) => setForm((f) => ({ ...f, ...p }))

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault()
    setError(null)
    if (!allowed) return setError('Anda tidak berhak mengubah form ini')
    if (!form.formNo.trim()) return setError('Form Number wajib diisi')
    if (!form.formStatusOrder.trim())
      return setError('Status Order wajib dipilih')
    if (!form.formServComment.trim()) return setError('Category wajib dipilih')
    if (!form.formServName.trim()) return setError('Serviceman wajib dipilih')
    if (!form.formCheckBy.trim()) return setError('Check By wajib dipilih')

    try {
      await mutate.mutateAsync({
        param: isAdd ? ApiParam.addForm : ApiParam.editForm,
        idForm: isAdd ? '' : form.idForm || idForm,
        formNo: form.formNo.trim(),
        formServName: form.formServName.trim(),
        formCheckBy: form.formCheckBy.trim(),
        formDateCheckBy: form.formDateCheckBy,
        formDateServName: form.formDateServName,
        formServComment: form.formServComment,
        formSuperiorAprd: form.formSuperiorAprd,
        formSuperiorComment: form.formSuperiorComment,
        formSadminComment: form.formSadminComment,
        formMilestone: form.formMilestone,
        formStatusOrder: form.formStatusOrder,
        formSheadAprd: form.formSheadAprd,
        formSheadComment: form.formSheadComment,
        fromDateUpdate: form.fromDateUpdate || todayYmd(),
        formUserUpdate: user?.idUsersApp ?? form.formUserUpdate,
      })
      router.replace('/forms')
    } catch (err) {
      setError((err as Error).message)
    }
  }

  const onDelete = async () => {
    if ((tools.data?.length ?? 0) > 0) {
      setError('Tidak bisa hapus form yang masih punya tool item')
      return
    }
    if (!window.confirm(`Hapus form ${form.formNo}?`)) return
    try {
      await mutate.mutateAsync({
        param: ApiParam.deleteForm,
        idForm: form.idForm || idForm,
        formNo: form.formNo,
        formServName: form.formServName,
        formCheckBy: form.formCheckBy,
        formDateCheckBy: form.formDateCheckBy,
        formDateServName: form.formDateServName,
        formServComment: form.formServComment,
        formMilestone: form.formMilestone,
        formStatusOrder: form.formStatusOrder,
        fromDateUpdate: form.fromDateUpdate,
        formUserUpdate: user?.idUsersApp ?? '',
      })
      router.replace('/forms')
    } catch (err) {
      setError((err as Error).message)
    }
  }

  return (
    <div className="page">
      <PageHeader
        title={isAdd ? 'Add Form' : 'Edit Form'}
        subtitle="Request header"
      >
        <Link className="btn btn-ghost" href="/forms">
          Back
        </Link>
      </PageHeader>

      {!isAdd && remote.isLoading && <div className="panel">Loading form…</div>}
      {!isAdd && remote.isError && (
        <div className="alert alert-error">{(remote.error as Error).message}</div>
      )}

      <form className="panel stack" onSubmit={onSubmit}>
        <div className="form-panel-header">
          <h3>Request header</h3>
          {!isAdd && allowed && (
            <button
              type="button"
              className="btn btn-danger btn-sm btn-with-icon"
              onClick={onDelete}
              disabled={mutate.isPending}
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
            <span>Form Number</span>
            <input
              value={form.formNo}
              onChange={(e) => patch({ formNo: e.target.value })}
              required
            />
          </label>
          <label className="field">
            <span>Status Order</span>
            <select
              value={form.formStatusOrder}
              onChange={(e) => {
                const next = e.target.value
                const nextCats =
                  next === 'NON HOLDER'
                    ? NON_HOLDER_CATS
                    : next === 'HOLDER'
                      ? HOLDER_CATS
                      : []
                patch({
                  formStatusOrder: next,
                  formServComment: nextCats.includes(form.formServComment)
                    ? form.formServComment
                    : '',
                })
              }}
              required
            >
              <option value="" disabled>
                Pilih status…
              </option>
              <option value="HOLDER">HOLDER</option>
              <option value="NON HOLDER">NON HOLDER</option>
            </select>
          </label>
        </div>

        <div className="grid-2">
          <label className="field">
            <span>Category</span>
            <select
              value={form.formServComment}
              onChange={(e) => patch({ formServComment: e.target.value })}
              required
              disabled={!form.formStatusOrder}
            >
              <option value="" disabled>
                {form.formStatusOrder
                  ? 'Pilih category…'
                  : 'Pilih status dulu…'}
              </option>
              {cats.map((c) => (
                <option key={c} value={c}>
                  {c}
                </option>
              ))}
            </select>
          </label>
          <label className="field">
            <span>Create Date</span>
            <DateInput
              value={form.formDateServName}
              onChange={(v) => patch({ formDateServName: v })}
              required
              aria-label="Create Date"
            />
          </label>
        </div>

        <div className="grid-2">
          <label className="field">
            <span>Serviceman</span>
            <div className="picker-input-wrap">
              <input
                type="text"
                className="picker-input-field"
                value={servShown}
                readOnly
                required
                placeholder="Pilih serviceman…"
                onClick={() => setPicker('serv')}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault()
                    setPicker('serv')
                  }
                }}
                role="button"
                aria-haspopup="dialog"
                aria-label="Pilih serviceman"
              />
            </div>
          </label>
          <label className="field">
            <span>Check By</span>
            <div className="picker-input-wrap">
              <input
                type="text"
                className="picker-input-field"
                value={checkShown}
                readOnly
                required
                placeholder="Pilih check by…"
                onClick={() => setPicker('check')}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault()
                    setPicker('check')
                  }
                }}
                role="button"
                aria-haspopup="dialog"
                aria-label="Pilih check by"
              />
            </div>
          </label>
        </div>

        <label className="field">
          <span>Check Date</span>
          <DateInput
            value={form.formDateCheckBy}
            onChange={(v) => patch({ formDateCheckBy: v })}
            required
            aria-label="Check Date"
          />
        </label>

        {error && <div className="alert alert-error">{error}</div>}

        <button
          type="submit"
          className="btn btn-primary btn-block"
          disabled={mutate.isPending || !allowed}
        >
          {mutate.isPending ? 'Saving…' : isAdd ? 'Save Form' : 'Update Form'}
        </button>
      </form>

      <UserPickerModal
        open={picker === 'serv'}
        title="Pilih Serviceman"
        levelFilter="MECHANIC"
        onClose={() => setPicker(null)}
        onSelect={(row) => {
          const id = row.idUsers.trim()
          if (!id) return
          patch({
            formServName: id,
            formServNameLabel: userPickLabel(row),
          })
        }}
      />
      <UserPickerModal
        open={picker === 'check'}
        title="Pilih Check By"
        levelFilter="TOOL_KEEPER"
        onClose={() => setPicker(null)}
        onSelect={(row) => {
          const id = row.idUsers.trim()
          if (!id) return
          patch({
            formCheckBy: id,
            formCheckByLabel: userPickLabel(row),
          })
        }}
      />
    </div>
  )
}
