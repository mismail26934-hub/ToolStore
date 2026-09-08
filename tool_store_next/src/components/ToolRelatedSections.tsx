'use client'

import { useState, type FormEvent, type ReactNode } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import { ApiParam } from '@/api/params'
import { useAuth } from '@/auth/AuthContext'
import {
  canMutatePr,
  canMutateRcvTool,
  canMutateRcvWh,
  canMutateSo,
  todayYmd,
} from '@/auth/roles'
import { DateInput } from '@/components/DateInput'
import { syncFormProcessMilestone } from '@/features/forms/syncFormProcessMilestone'
import { formatDateDisplay } from '@/lib/dateFormat'
import {
  soNoteLabel,
  soNumberLabel,
  soSectionLabel,
} from '@/lib/orderDocLabel'
import { useFormRelated, useRelatedMutations } from '@/features/related/useRelated'
import type {
  FormRow,
  PrRow,
  RcvToolRow,
  RcvWhRow,
  SoRow,
  ToolDetailRow,
} from '@/types/models'

type Dialog =
  | { kind: 'pr'; row?: PrRow }
  | { kind: 'so'; row?: SoRow }
  | { kind: 'rcvWh'; row?: RcvWhRow }
  | { kind: 'rcvTool'; row?: RcvToolRow }
  | null

function byDetail<T extends { idFormDetail: string }>(
  rows: T[] | undefined,
  id: string,
) {
  return (rows ?? []).filter((r) => r.idFormDetail === id)
}

function dateSlice(value: string | null | undefined, fallback = '') {
  const v = value?.trim().slice(0, 10) ?? ''
  return v || fallback
}

function receiveQtyLine(qty: string, date: string, index: number, total: number) {
  const q = qty.trim() || '—'
  const d = formatDateDisplay(date)
  const body = d && d !== '—' ? `${q} · ${d}` : q
  return total > 1 ? `${index + 1}) ${body}` : body
}

function PlusIcon() {
  return (
    <svg
      className="btn-icon-svg"
      viewBox="0 0 24 24"
      width="15"
      height="15"
      aria-hidden
      fill="none"
    >
      <path
        d="M12 5v14M5 12h14"
        stroke="currentColor"
        strokeWidth="2.2"
        strokeLinecap="round"
      />
    </svg>
  )
}

function EditIcon() {
  return (
    <svg
      className="btn-icon-svg"
      viewBox="0 0 24 24"
      width="15"
      height="15"
      aria-hidden
      fill="none"
    >
      <path
        d="M14 5.5l4.5 4.5M5 15.5V19h3.5L19 8.5 14.5 4 5 13.5z"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  )
}

function TrashIcon() {
  return (
    <svg
      className="btn-icon-svg"
      viewBox="0 0 24 24"
      width="15"
      height="15"
      aria-hidden
      fill="none"
    >
      <path
        d="M4 7h16M9 7V5a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2M6 7l1 12a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2l1-12M10 11v6M14 11v6"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  )
}

function RelatedField({
  label,
  canAdd,
  onAdd,
  wide,
  children,
}: {
  label: string
  canAdd: boolean
  onAdd: () => void
  wide?: boolean
  children: ReactNode
}) {
  return (
    <div className={`related-inline-field${wide ? ' is-wide' : ''}`}>
      <div className="related-inline-label">
        <span className="muted">{label}</span>
        {canAdd && (
          <button
            type="button"
            className="btn btn-ghost btn-icon-only"
            title={`Add ${label}`}
            aria-label={`Add ${label}`}
            onClick={onAdd}
          >
            <PlusIcon />
          </button>
        )}
      </div>
      <div className="related-inline-list">{children}</div>
    </div>
  )
}

function RelatedItemRow({
  label,
  details,
  canEdit,
  onEdit,
}: {
  label: string
  details?: { label: string; value: string }[]
  canEdit: boolean
  onEdit: () => void
}) {
  return (
    <div className="related-inline-row">
      <div className="related-inline-content">
        {details && details.length > 0 ? (
          <table className="related-mini-table">
            <tbody>
              {label ? (
                <tr>
                  <th colSpan={2}>{label}</th>
                </tr>
              ) : null}
              {details.map((d) => (
                <tr key={d.label}>
                  <th>{d.label}</th>
                  <td>{d.value || '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <span className="meta-value">{label}</span>
        )}
      </div>
      {canEdit && (
        <button
          type="button"
          className="btn btn-ghost btn-icon-only"
          title="Edit"
          aria-label="Edit"
          onClick={onEdit}
        >
          <EditIcon />
        </button>
      )}
    </div>
  )
}

export function ToolRelatedSections({
  form,
  tool,
  related,
  mut,
}: {
  form: FormRow
  tool: ToolDetailRow
  related: ReturnType<typeof useFormRelated>
  mut: ReturnType<typeof useRelatedMutations>
}) {
  const { user } = useAuth()
  const queryClient = useQueryClient()
  const [dialog, setDialog] = useState<Dialog>(null)
  const [error, setError] = useState<string | null>(null)
  const [dateField, setDateField] = useState('')
  const [qtyField, setQtyField] = useState('')

  const prs = byDetail(related.pr.data, tool.idFormDetail)
  const sos = byDetail(related.so.data, tool.idFormDetail)
  const whs = byDetail(related.rcvWh.data, tool.idFormDetail)
  const rooms = byDetail(related.rcvTool.data, tool.idFormDetail)
  const canSo = canMutateSo(user, tool.valType)
  const soLabel = soSectionLabel(tool.valType)
  const soNumLabel = soNumberLabel(tool.valType)
  const soNote = soNoteLabel(tool.valType)

  const busy =
    mut.pr.isPending ||
    mut.so.isPending ||
    mut.rcvWh.isPending ||
    mut.rcvTool.isPending

  const syncMilestone = async () => {
    try {
      await syncFormProcessMilestone({
        form,
        userId: user?.idUsersApp ?? '',
        queryClient,
      })
    } catch {
      // Related save already succeeded; milestone sync is best-effort.
    }
  }

  const openDialog = (next: Exclude<Dialog, null>) => {
    setError(null)
    if (next.kind === 'so') {
      setDateField(dateSlice(next.row?.eta))
      setQtyField('')
    } else if (next.kind === 'rcvWh') {
      setDateField(dateSlice(next.row?.rcvWhDate, todayYmd()))
      setQtyField(next.row?.qty?.trim() || tool.qty.trim())
    } else if (next.kind === 'rcvTool') {
      setDateField(dateSlice(next.row?.rcvToolDate, todayYmd()))
      setQtyField(next.row?.qty?.trim() || tool.qty.trim())
    } else {
      setDateField('')
      setQtyField('')
    }
    setDialog(next)
  }

  const close = () => {
    setDialog(null)
    setError(null)
    setDateField('')
    setQtyField('')
  }

  const onPrSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const fd = new FormData(e.currentTarget)
    const prNo = String(fd.get('pr_no') ?? '').trim()
    if (!prNo) return setError('PR number wajib diisi')
    if (sos.length > 0) return setError('PR terkunci karena SO sudah ada')
    try {
      await mut.pr.mutateAsync({
        param:
          dialog &&
          'row' in dialog &&
          dialog.row &&
          'idPr' in dialog.row &&
          dialog.row.idPr
            ? ApiParam.editPr
            : ApiParam.addPr,
        idPr: dialog?.kind === 'pr' ? (dialog.row?.idPr ?? '') : '',
        idFormDetail: tool.idFormDetail,
        prNo,
        dateUpdatePr: todayYmd(),
        userUpdatePr: user?.idUsersApp ?? '',
      })
      await syncMilestone()
      close()
    } catch (err) {
      setError((err as Error).message)
    }
  }

  const onSoSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const fd = new FormData(e.currentTarget)
    const so = String(fd.get('so') ?? '').trim()
    const noteSo = String(fd.get('note_so') ?? '').trim()
    const boComplete = String(fd.get('bo_complete') ?? 'NO').trim()
    const eta = dateField.trim()
    if (!so) return setError(`${soNumLabel} wajib diisi`)
    if (!eta) return setError('ETA wajib diisi')
    if (whs.length > 0)
      return setError('SO terkunci karena WH receive sudah ada')
    if (!canMutateSo(user, tool.valType)) {
      return setError(
        'SO / PR: CAT hanya Counter, VENDOR hanya GA. Super Admin boleh keduanya.',
      )
    }
    try {
      await mut.so.mutateAsync({
        param:
          dialog?.kind === 'so' && dialog.row?.idSo
            ? ApiParam.editSo
            : ApiParam.addSo,
        idSo: dialog?.kind === 'so' ? (dialog.row?.idSo ?? '') : '',
        idFormDetail: tool.idFormDetail,
        so,
        eta,
        noteSo,
        boComplete,
        dateUpdateSo: todayYmd(),
        idUpdateSo: user?.idUsersApp ?? '',
      })
      await syncMilestone()
      close()
    } catch (err) {
      setError((err as Error).message)
    }
  }

  const onWhSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const date = dateField.trim()
    const qty = qtyField.trim()
    if (!date) return setError('Tanggal wajib diisi')
    if (!qty) return setError('Qty WH Received wajib diisi')
    if (rooms.length > 0)
      return setError('WH receive terkunci karena Tool Room sudah ada')
    try {
      await mut.rcvWh.mutateAsync({
        param:
          dialog?.kind === 'rcvWh' && dialog.row?.idRcvWh
            ? ApiParam.editRcvWh
            : ApiParam.addRcvWh,
        idRcvWh: dialog?.kind === 'rcvWh' ? (dialog.row?.idRcvWh ?? '') : '',
        idFormDetail: tool.idFormDetail,
        rcvWhDate: date,
        qty,
        rcvWhIdInput: user?.idUsersApp ?? '',
        rcvWhDateInput: todayYmd(),
      })
      await syncMilestone()
      close()
    } catch (err) {
      setError((err as Error).message)
    }
  }

  const onToolRcvSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const date = dateField.trim()
    const qty = qtyField.trim()
    if (!date) return setError('Tanggal wajib diisi')
    if (!qty) return setError('Qty Tool Room Received wajib diisi')
    try {
      await mut.rcvTool.mutateAsync({
        param:
          dialog?.kind === 'rcvTool' && dialog.row?.idRcvTool
            ? ApiParam.editRcvTool
            : ApiParam.addRcvTool,
        idRcvTool:
          dialog?.kind === 'rcvTool' ? (dialog.row?.idRcvTool ?? '') : '',
        idFormDetail: tool.idFormDetail,
        rcvToolDate: date,
        qty,
        rcvToolIdInput: user?.idUsersApp ?? '',
        rcvToolDateInput: todayYmd(),
      })
      await syncMilestone()
      close()
    } catch (err) {
      setError((err as Error).message)
    }
  }

  const removePr = async (row: PrRow) => {
    if (sos.length > 0) return
    if (!window.confirm(`Hapus PR ${row.prNo || ''}?`)) return
    try {
      await mut.pr.mutateAsync({
        param: ApiParam.deletePr,
        idPr: row.idPr,
        idFormDetail: tool.idFormDetail,
        prNo: row.prNo,
        dateUpdatePr: todayYmd(),
        userUpdatePr: user?.idUsersApp ?? '',
      })
      await syncMilestone()
      close()
    } catch (err) {
      setError((err as Error).message)
    }
  }

  const removeSo = async (row: SoRow) => {
    if (whs.length > 0) return
    if (!canMutateSo(user, tool.valType)) return
    if (!window.confirm(`Hapus ${soLabel} ${row.so || ''}?`)) return
    try {
      await mut.so.mutateAsync({
        param: ApiParam.deleteSo,
        idSo: row.idSo,
        idFormDetail: tool.idFormDetail,
        so: row.so,
        eta: row.eta,
        noteSo: row.noteSo,
        boComplete: row.boComplete,
        dateUpdateSo: todayYmd(),
        idUpdateSo: user?.idUsersApp ?? '',
      })
      await syncMilestone()
      close()
    } catch (err) {
      setError((err as Error).message)
    }
  }

  const removeWh = async (row: RcvWhRow) => {
    if (rooms.length > 0) return
    if (!window.confirm('Hapus WH receive ini?')) return
    try {
      await mut.rcvWh.mutateAsync({
        param: ApiParam.deleteRcvWh,
        idRcvWh: row.idRcvWh,
        idFormDetail: tool.idFormDetail,
        rcvWhDate: row.rcvWhDate,
        qty: row.qty,
        rcvWhIdInput: user?.idUsersApp ?? '',
        rcvWhDateInput: todayYmd(),
      })
      await syncMilestone()
      close()
    } catch (err) {
      setError((err as Error).message)
    }
  }

  const removeToolRcv = async (row: RcvToolRow) => {
    if (!window.confirm('Hapus Tool Room receive ini?')) return
    try {
      await mut.rcvTool.mutateAsync({
        param: ApiParam.deleteRcvTool,
        idRcvTool: row.idRcvTool,
        idFormDetail: tool.idFormDetail,
        rcvToolDate: row.rcvToolDate,
        qty: row.qty,
        rcvToolIdInput: user?.idUsersApp ?? '',
        rcvToolDateInput: todayYmd(),
      })
      await syncMilestone()
      close()
    } catch (err) {
      setError((err as Error).message)
    }
  }

  const prLocked = sos.length > 0
  const soLocked = whs.length > 0
  const whLocked = rooms.length > 0

  return (
    <div className="related-inline-wrap">
      <div className="tool-item-block-grid related-inline-grid">
        <RelatedField
          label="PR"
          canAdd={canMutatePr(user) && !prLocked}
          onAdd={() => openDialog({ kind: 'pr' })}
        >
          {prs.length === 0 && <div className="meta-value muted">—</div>}
          {prs.map((row, i) => (
            <RelatedItemRow
              key={row.idPr}
              label={
                prs.length > 1
                  ? `${i + 1}) ${row.prNo || '—'}`
                  : row.prNo || '—'
              }
              canEdit={canMutatePr(user) && !prLocked}
              onEdit={() => openDialog({ kind: 'pr', row })}
            />
          ))}
        </RelatedField>

        <RelatedField
          label={soLabel}
          canAdd={canSo && !soLocked}
          onAdd={() => openDialog({ kind: 'so' })}
          wide
        >
          {sos.length === 0 && <div className="meta-value muted">—</div>}
          {sos.length > 0 && (
            <div className="related-data-table-wrap">
              <table className="related-data-table">
                <thead>
                  <tr>
                    <th>{soNumLabel}</th>
                    <th>ETA</th>
                    <th>{soNote}</th>
                    <th>BO Complete</th>
                    {canSo && !soLocked && <th className="actions" />}
                  </tr>
                </thead>
                <tbody>
                  {sos.map((row) => (
                    <tr key={row.idSo}>
                      <td>{row.so || '—'}</td>
                      <td>{formatDateDisplay(row.eta)}</td>
                      <td>{row.noteSo?.trim() || '—'}</td>
                      <td>{row.boComplete?.trim() || 'NO'}</td>
                      {canSo && !soLocked && (
                        <td className="actions">
                          <button
                            type="button"
                            className="btn btn-ghost btn-icon-only"
                            title="Edit"
                            aria-label="Edit"
                            onClick={() => openDialog({ kind: 'so', row })}
                          >
                            <EditIcon />
                          </button>
                        </td>
                      )}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </RelatedField>

        <RelatedField
          label="Qty WH Received"
          canAdd={canMutateRcvWh(user) && !whLocked}
          onAdd={() => openDialog({ kind: 'rcvWh' })}
        >
          {whs.length === 0 && <div className="meta-value muted">—</div>}
          {whs.map((row, i) => (
            <RelatedItemRow
              key={row.idRcvWh}
              label={receiveQtyLine(row.qty, row.rcvWhDate, i, whs.length)}
              canEdit={canMutateRcvWh(user) && !whLocked}
              onEdit={() => openDialog({ kind: 'rcvWh', row })}
            />
          ))}
        </RelatedField>

        <RelatedField
          label="Qty Tool Room Received"
          canAdd={canMutateRcvTool(user)}
          onAdd={() => openDialog({ kind: 'rcvTool' })}
        >
          {rooms.length === 0 && <div className="meta-value muted">—</div>}
          {rooms.map((row, i) => (
            <RelatedItemRow
              key={row.idRcvTool}
              label={receiveQtyLine(row.qty, row.rcvToolDate, i, rooms.length)}
              canEdit={canMutateRcvTool(user)}
              onEdit={() => openDialog({ kind: 'rcvTool', row })}
            />
          ))}
        </RelatedField>
      </div>

      {dialog && (
        <div className="modal-backdrop" onClick={close} role="presentation">
          <div
            className="modal-panel"
            onClick={(e) => e.stopPropagation()}
            role="dialog"
            aria-modal="true"
          >
            <div className="form-panel-header">
              <h3>
                {dialog.kind === 'pr' && 'PR'}
                {dialog.kind === 'so' && soLabel}
                {dialog.kind === 'rcvWh' && 'Qty WH Received'}
                {dialog.kind === 'rcvTool' && 'Qty Tool Room Received'}
              </h3>
              {dialog.row && (
                <button
                  type="button"
                  className="btn btn-danger btn-sm btn-with-icon"
                  disabled={busy}
                  onClick={() => {
                    if (dialog.kind === 'pr') void removePr(dialog.row!)
                    if (dialog.kind === 'so') void removeSo(dialog.row!)
                    if (dialog.kind === 'rcvWh') void removeWh(dialog.row!)
                    if (dialog.kind === 'rcvTool') void removeToolRcv(dialog.row!)
                  }}
                >
                  <TrashIcon />
                  <span className="btn-label">Delete</span>
                </button>
              )}
            </div>
            {error && <div className="alert alert-error">{error}</div>}

            {dialog.kind === 'pr' && (
              <form className="stack" onSubmit={onPrSubmit}>
                <label className="field">
                  <span>PR number</span>
                  <input
                    name="pr_no"
                    defaultValue={dialog.row?.prNo ?? ''}
                    required
                  />
                </label>
                <div className="row-gap">
                  <button
                    type="button"
                    className="btn btn-ghost"
                    onClick={close}
                  >
                    Close
                  </button>
                  <button className="btn btn-primary" disabled={busy} type="submit">
                    Save
                  </button>
                </div>
              </form>
            )}
            {dialog.kind === 'so' && (
              <form className="stack" onSubmit={onSoSubmit}>
                <label className="field">
                  <span>{soNumLabel}</span>
                  <input
                    name="so"
                    defaultValue={dialog.row?.so ?? ''}
                    required
                  />
                </label>
                <label className="field">
                  <span>ETA</span>
                  <DateInput
                    value={dateField}
                    onChange={setDateField}
                    required
                    aria-label="ETA"
                  />
                </label>
                <label className="field">
                  <span>{soNote}</span>
                  <input
                    name="note_so"
                    defaultValue={dialog.row?.noteSo ?? ''}
                  />
                </label>
                <label className="field">
                  <span>BO Complete</span>
                  <select
                    name="bo_complete"
                    defaultValue={
                      (dialog.row?.boComplete ?? 'NO').toUpperCase() === 'YES'
                        ? 'YES'
                        : 'NO'
                    }
                  >
                    <option value="NO">NO</option>
                    <option value="YES">YES</option>
                  </select>
                </label>
                <div className="row-gap">
                  <button
                    type="button"
                    className="btn btn-ghost"
                    onClick={close}
                  >
                    Close
                  </button>
                  <button className="btn btn-primary" disabled={busy} type="submit">
                    Save
                  </button>
                </div>
              </form>
            )}
            {dialog.kind === 'rcvWh' && (
              <form className="stack" onSubmit={onWhSubmit}>
                <label className="field">
                  <span>Qty WH Received</span>
                  <input
                    value={qtyField}
                    onChange={(e) => setQtyField(e.target.value)}
                    inputMode="decimal"
                    required
                    aria-label="Qty WH Received"
                  />
                </label>
                <label className="field">
                  <span>Date</span>
                  <DateInput
                    value={dateField}
                    onChange={setDateField}
                    required
                    aria-label="WH Received date"
                  />
                </label>
                <div className="row-gap">
                  <button
                    type="button"
                    className="btn btn-ghost"
                    onClick={close}
                  >
                    Close
                  </button>
                  <button className="btn btn-primary" disabled={busy} type="submit">
                    Save
                  </button>
                </div>
              </form>
            )}
            {dialog.kind === 'rcvTool' && (
              <form className="stack" onSubmit={onToolRcvSubmit}>
                <label className="field">
                  <span>Qty Tool Room Received</span>
                  <input
                    value={qtyField}
                    onChange={(e) => setQtyField(e.target.value)}
                    inputMode="decimal"
                    required
                    aria-label="Qty Tool Room Received"
                  />
                </label>
                <label className="field">
                  <span>Date</span>
                  <DateInput
                    value={dateField}
                    onChange={setDateField}
                    required
                    aria-label="Tool Room date"
                  />
                </label>
                <div className="row-gap">
                  <button
                    type="button"
                    className="btn btn-ghost"
                    onClick={close}
                  >
                    Close
                  </button>
                  <button className="btn btn-primary" disabled={busy} type="submit">
                    Save
                  </button>
                </div>
              </form>
            )}
          </div>
        </div>
      )}
    </div>
  )
}
