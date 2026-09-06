'use client'

import { useEffect, useMemo, useState, type FormEvent } from 'react'
import Link from 'next/link'
import { useParams, useRouter } from 'next/navigation'
import { useAuth } from '@/auth/AuthContext'
import { PageHeader } from '@/components/PageHeader'
import {
  useToolDetailMutations,
  useToolDetails,
} from '@/features/tools/useToolDetails'
import type { ToolDetailRow } from '@/types/models'

type RowForm = {
  pnGroup: string
  qty: string
  pnDesc: string
  partValue: string
  valType: string
  brand: string
  spesifikasi: string
  explan: string
  actionNote: string
  idFormDetail: string
}

const emptyRow = (): RowForm => ({
  pnGroup: '',
  qty: '',
  pnDesc: '',
  partValue: '',
  valType: '',
  brand: '',
  spesifikasi: '',
  explan: '',
  actionNote: '',
  idFormDetail: '',
})

function fromApi(row: ToolDetailRow): RowForm {
  return {
    pnGroup: row.pnGroup,
    qty: row.qty,
    pnDesc: row.pnDesc,
    partValue: row.partValue,
    valType: row.valType,
    brand: row.brand ?? '',
    spesifikasi: row.spesifikasi ?? '',
    explan: row.explan,
    actionNote: row.actionNote,
    idFormDetail: row.idFormDetail,
  }
}

function nowStamp() {
  const d = new Date()
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`
}

export function ToolDetailPage() {
  const params = useParams<{ idForm: string; idDetail: string }>()
  const idForm = params.idForm ?? ''
  const idDetail = params.idDetail ?? 'new'
  const isAdd = idDetail === 'new'
  const router = useRouter()
  const { user } = useAuth()
  const existing = useToolDetails(idForm, !isAdd)
  const { add, edit, remove } = useToolDetailMutations(idForm)

  const [rows, setRows] = useState<RowForm[]>([emptyRow()])
  const [message, setMessage] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)

  const seed = useMemo(() => {
    if (isAdd) return null
    return existing.data?.find((r) => r.idFormDetail === idDetail) ?? null
  }, [existing.data, idDetail, isAdd])

  useEffect(() => {
    if (isAdd) {
      setRows([emptyRow()])
      return
    }
    if (seed) setRows([fromApi(seed)])
  }, [isAdd, seed])

  const updateRow = (index: number, patch: Partial<RowForm>) => {
    setRows((prev) =>
      prev.map((r, i) => (i === index ? { ...r, ...patch } : r)),
    )
  }

  const addRow = () => setRows((prev) => [...prev, emptyRow()])
  const removeRow = (index: number) => {
    setRows((prev) => (prev.length <= 1 ? prev : prev.filter((_, i) => i !== index)))
  }

  const submitting = add.isPending || edit.isPending || remove.isPending

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault()
    setError(null)
    setMessage(null)

    try {
      for (const row of rows) {
        const actionNote =
          row.actionNote.trim().length > 0
            ? row.actionNote.trim().charAt(0)
            : ''
        const payload = {
          idForm,
          idFormDetail: row.idFormDetail,
          pnGroup: row.pnGroup.trim(),
          qty: row.qty.trim(),
          pnDesc: row.pnDesc.trim(),
          partValue: row.partValue.trim(),
          valType: row.valType.trim(),
          brand: row.brand.trim(),
          spesifikasi: row.spesifikasi.trim(),
          explan: row.explan.trim(),
          actionNote,
          formDetailDate: nowStamp(),
          formDetailUser: user?.idUsersApp ?? '',
        }

        if (isAdd) {
          await add.mutateAsync(payload)
        } else {
          await edit.mutateAsync(payload)
        }
      }
      setMessage(isAdd ? 'Data berhasil ditambahkan' : 'Data berhasil diupdate')
      router.replace(`/forms?expand=${encodeURIComponent(idForm)}`)
    } catch (err) {
      setError((err as Error).message)
    }
  }

  const onDelete = async () => {
    if (!seed || !window.confirm('Hapus tool item ini?')) return
    setError(null)
    try {
      await remove.mutateAsync({
        idForm,
        idFormDetail: seed.idFormDetail,
        pnGroup: seed.pnGroup,
        pnDesc: seed.pnDesc,
        qty: seed.qty,
        explan: seed.explan,
        actionNote: seed.actionNote,
        valType: seed.valType,
        partValue: seed.partValue,
        formDetailDate: seed.formDetailDate,
        formDetailUser: seed.formDetailUser,
      })
      router.replace(`/forms?expand=${encodeURIComponent(idForm)}`)
    } catch (err) {
      setError((err as Error).message)
    }
  }

  return (
    <div className="page">
      <PageHeader
        title={isAdd ? 'Add Tool Items' : 'Edit Tool Item'}
        subtitle={`${isAdd ? 'Multiple Detail Input' : 'Single Detail Input'} · Form ${idForm}`}
      >
        {isAdd && (
          <button type="button" className="btn btn-secondary" onClick={addRow}>
            + Row
          </button>
        )}
        <Link className="btn btn-ghost" href={`/forms?expand=${idForm}`}>
          Back
        </Link>
      </PageHeader>

      {!isAdd && existing.isLoading && (
        <div className="panel">Loading item…</div>
      )}
      {!isAdd && existing.isError && (
        <div className="alert alert-error">
          {(existing.error as Error)?.message}
        </div>
      )}

      <form className="stack" onSubmit={onSubmit}>
        {rows.map((row, i) => (
          <section key={i} className="panel tool-form-panel">
            <div className="section-title-row">
              <h3>
                Item {i + 1}
                {row.idFormDetail ? ` · ${row.idFormDetail}` : ''}
              </h3>
              {isAdd && rows.length > 1 && (
                <button
                  type="button"
                  className="btn btn-danger btn-sm"
                  onClick={() => removeRow(i)}
                >
                  Remove
                </button>
              )}
              {!isAdd && (
                <button
                  type="button"
                  className="btn btn-danger btn-sm"
                  onClick={onDelete}
                  disabled={submitting}
                >
                  Delete
                </button>
              )}
            </div>

            <div className="grid-2">
              <label className="field">
                <span>PN GROUP CONSIST</span>
                <input
                  value={row.pnGroup}
                  onChange={(e) => updateRow(i, { pnGroup: e.target.value })}
                  required
                />
              </label>
              <label className="field">
                <span>QTY</span>
                <input
                  value={row.qty}
                  onChange={(e) => updateRow(i, { qty: e.target.value })}
                  required
                />
              </label>
            </div>

            <label className="field">
              <span>DESCRIPTION</span>
              <input
                value={row.pnDesc}
                onChange={(e) => updateRow(i, { pnDesc: e.target.value })}
                required
              />
            </label>

            <div className="grid-2">
              <label className="field">
                <span>PRICE</span>
                <input
                  value={row.partValue}
                  onChange={(e) => updateRow(i, { partValue: e.target.value })}
                  required
                />
              </label>
              <label className="field">
                <span>CAT / LOCAL VENDOR</span>
                <select
                  value={row.valType}
                  onChange={(e) => updateRow(i, { valType: e.target.value })}
                  required
                >
                  <option value="">Select…</option>
                  <option value="CAT">CAT</option>
                  <option value="VENDOR">VENDOR</option>
                </select>
              </label>
            </div>

            <div className="grid-2">
              <label className="field">
                <span>BRAND</span>
                <input
                  value={row.brand}
                  onChange={(e) => updateRow(i, { brand: e.target.value })}
                />
              </label>
              <label className="field">
                <span>SPESIFIKASI</span>
                <input
                  value={row.spesifikasi}
                  onChange={(e) =>
                    updateRow(i, { spesifikasi: e.target.value })
                  }
                />
              </label>
            </div>

            <label className="field">
              <span>EXPLANATION</span>
              <input
                value={row.explan}
                onChange={(e) => updateRow(i, { explan: e.target.value })}
                required
              />
            </label>

            <label className="field">
              <span>ACTION NOTE (A/B/C/D)</span>
              <select
                value={row.actionNote}
                onChange={(e) => updateRow(i, { actionNote: e.target.value })}
                required
              >
                <option value="">Select…</option>
                <option value="A">A</option>
                <option value="B">B</option>
                <option value="C">C</option>
                <option value="D">D</option>
              </select>
            </label>
          </section>
        ))}

        {error && <div className="alert alert-error">{error}</div>}
        {message && <div className="alert alert-ok">{message}</div>}

        <button
          type="submit"
          className="btn btn-primary btn-block"
          disabled={submitting}
        >
          {submitting ? 'Saving…' : isAdd ? 'Save Data' : 'Update Data'}
        </button>
      </form>
    </div>
  )
}
