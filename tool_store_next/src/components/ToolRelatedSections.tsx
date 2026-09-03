'use client'

import { useState, type FormEvent } from 'react'
import { ApiParam } from '@/api/params'
import { useAuth } from '@/auth/AuthContext'
import {
  canMutatePo,
  canMutateRcvTool,
  canMutateRcvWh,
  canMutateSo,
  todayYmd,
} from '@/auth/roles'
import { useFormRelated, useRelatedMutations } from '@/features/related/useRelated'
import type { PoRow, RcvToolRow, RcvWhRow, SoRow, ToolDetailRow } from '@/types/models'

type Dialog =
  | { kind: 'po'; row?: PoRow }
  | { kind: 'so'; row?: SoRow }
  | { kind: 'rcvWh'; row?: RcvWhRow }
  | { kind: 'rcvTool'; row?: RcvToolRow }
  | null

function byDetail<T extends { idFormDetail: string }>(rows: T[] | undefined, id: string) {
  return (rows ?? []).filter((r) => r.idFormDetail === id)
}

export function ToolRelatedSections({
  tool,
  related,
  mut,
}: {
  tool: ToolDetailRow
  related: ReturnType<typeof useFormRelated>
  mut: ReturnType<typeof useRelatedMutations>
}) {
  const { user } = useAuth()
  const [dialog, setDialog] = useState<Dialog>(null)
  const [error, setError] = useState<string | null>(null)

  const pos = byDetail(related.po.data, tool.idFormDetail)
  const sos = byDetail(related.so.data, tool.idFormDetail)
  const whs = byDetail(related.rcvWh.data, tool.idFormDetail)
  const rooms = byDetail(related.rcvTool.data, tool.idFormDetail)

  const busy =
    mut.po.isPending || mut.so.isPending || mut.rcvWh.isPending || mut.rcvTool.isPending

  const close = () => {
    setDialog(null)
    setError(null)
  }

  const onPoSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const fd = new FormData(e.currentTarget)
    const poNo = String(fd.get('po_no') ?? '').trim()
    if (!poNo) return setError('PO number wajib diisi')
    if (sos.length > 0) return setError('PO terkunci karena SO sudah ada')
    try {
      await mut.po.mutateAsync({
        param: dialog && 'row' in dialog && dialog.row && 'idPo' in dialog.row && dialog.row.idPo
          ? ApiParam.editPo
          : ApiParam.addPo,
        idPo: dialog?.kind === 'po' ? dialog.row?.idPo ?? '' : '',
        idFormDetail: tool.idFormDetail,
        poNo,
        dateUpdatePo: todayYmd(),
        userUpdatePo: user?.idUsersApp ?? '',
      })
      close()
    } catch (err) {
      setError((err as Error).message)
    }
  }

  const onSoSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const fd = new FormData(e.currentTarget)
    const so = String(fd.get('so') ?? '').trim()
    const eta = String(fd.get('eta') ?? '').trim()
    const noteSo = String(fd.get('note_so') ?? '').trim()
    if (!so) return setError('SO / PR number wajib diisi')
    if (!eta) return setError('ETA wajib diisi')
    if (whs.length > 0) return setError('SO terkunci karena WH receive sudah ada')
    try {
      await mut.so.mutateAsync({
        param:
          dialog?.kind === 'so' && dialog.row?.idSo
            ? ApiParam.editSo
            : ApiParam.addSo,
        idSo: dialog?.kind === 'so' ? dialog.row?.idSo ?? '' : '',
        idFormDetail: tool.idFormDetail,
        so,
        eta,
        noteSo,
        dateUpdateSo: todayYmd(),
        idUpdateSo: user?.idUsersApp ?? '',
      })
      close()
    } catch (err) {
      setError((err as Error).message)
    }
  }

  const onWhSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const fd = new FormData(e.currentTarget)
    const date = String(fd.get('date') ?? '').trim()
    if (!date) return setError('Tanggal wajib diisi')
    if (rooms.length > 0) return setError('WH receive terkunci karena Tool Room sudah ada')
    try {
      await mut.rcvWh.mutateAsync({
        param:
          dialog?.kind === 'rcvWh' && dialog.row?.idRcvWh
            ? ApiParam.editRcvWh
            : ApiParam.addRcvWh,
        idRcvWh: dialog?.kind === 'rcvWh' ? dialog.row?.idRcvWh ?? '' : '',
        idFormDetail: tool.idFormDetail,
        rcvWhDate: date,
        rcvWhIdInput: user?.idUsersApp ?? '',
        rcvWhDateInput: todayYmd(),
      })
      close()
    } catch (err) {
      setError((err as Error).message)
    }
  }

  const onToolRcvSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const fd = new FormData(e.currentTarget)
    const date = String(fd.get('date') ?? '').trim()
    if (!date) return setError('Tanggal wajib diisi')
    try {
      await mut.rcvTool.mutateAsync({
        param:
          dialog?.kind === 'rcvTool' && dialog.row?.idRcvTool
            ? ApiParam.editRcvTool
            : ApiParam.addRcvTool,
        idRcvTool: dialog?.kind === 'rcvTool' ? dialog.row?.idRcvTool ?? '' : '',
        idFormDetail: tool.idFormDetail,
        rcvToolDate: date,
        rcvToolIdInput: user?.idUsersApp ?? '',
        rcvToolDateInput: todayYmd(),
      })
      close()
    } catch (err) {
      setError((err as Error).message)
    }
  }

  const removePo = async (row: PoRow) => {
    if (sos.length > 0) return
    if (!window.confirm('Hapus PO ini?')) return
    await mut.po.mutateAsync({
      param: ApiParam.deletePo,
      idPo: row.idPo,
      idFormDetail: tool.idFormDetail,
      poNo: row.poNo,
      dateUpdatePo: todayYmd(),
      userUpdatePo: user?.idUsersApp ?? '',
    })
  }

  const removeSo = async (row: SoRow) => {
    if (whs.length > 0) return
    if (!window.confirm('Hapus SO ini?')) return
    await mut.so.mutateAsync({
      param: ApiParam.deleteSo,
      idSo: row.idSo,
      idFormDetail: tool.idFormDetail,
      so: row.so,
      eta: row.eta,
      noteSo: row.noteSo,
      dateUpdateSo: todayYmd(),
      idUpdateSo: user?.idUsersApp ?? '',
    })
  }

  const removeWh = async (row: RcvWhRow) => {
    if (rooms.length > 0) return
    if (!window.confirm('Hapus WH receive ini?')) return
    await mut.rcvWh.mutateAsync({
      param: ApiParam.deleteRcvWh,
      idRcvWh: row.idRcvWh,
      idFormDetail: tool.idFormDetail,
      rcvWhDate: row.rcvWhDate,
      rcvWhIdInput: user?.idUsersApp ?? '',
      rcvWhDateInput: todayYmd(),
    })
  }

  const removeToolRcv = async (row: RcvToolRow) => {
    if (!window.confirm('Hapus Tool Room receive ini?')) return
    await mut.rcvTool.mutateAsync({
      param: ApiParam.deleteRcvTool,
      idRcvTool: row.idRcvTool,
      idFormDetail: tool.idFormDetail,
      rcvToolDate: row.rcvToolDate,
      rcvToolIdInput: user?.idUsersApp ?? '',
      rcvToolDateInput: todayYmd(),
    })
  }

  return (
    <div className="related-wrap">
      <RelatedBlock
        title="Purchase Order"
        canAdd={canMutatePo(user) && sos.length === 0}
        onAdd={() => setDialog({ kind: 'po' })}
      >
        {pos.map((row) => (
          <div key={row.idPo} className="related-line">
            <span>PO : {row.poNo}</span>
            {canMutatePo(user) && sos.length === 0 && (
              <span className="row-gap">
                <button type="button" className="btn btn-ghost btn-sm" onClick={() => setDialog({ kind: 'po', row })}>
                  Edit
                </button>
                <button type="button" className="btn btn-danger btn-sm" onClick={() => removePo(row)}>
                  Del
                </button>
              </span>
            )}
          </div>
        ))}
        {pos.length === 0 && <p className="muted">Belum ada PO.</p>}
      </RelatedBlock>

      <RelatedBlock
        title="Sales Order / PR"
        canAdd={canMutateSo(user) && whs.length === 0}
        onAdd={() => setDialog({ kind: 'so' })}
      >
        {sos.map((row) => (
          <div key={row.idSo} className="related-line">
            <span>
              SO : {row.so}
              <span className="muted"> · ETA {row.eta || '—'} · {row.noteSo || '-'}</span>
            </span>
            {canMutateSo(user) && whs.length === 0 && (
              <span className="row-gap">
                <button type="button" className="btn btn-ghost btn-sm" onClick={() => setDialog({ kind: 'so', row })}>
                  Edit
                </button>
                <button type="button" className="btn btn-danger btn-sm" onClick={() => removeSo(row)}>
                  Del
                </button>
              </span>
            )}
          </div>
        ))}
        {sos.length === 0 && <p className="muted">Belum ada SO.</p>}
      </RelatedBlock>

      <RelatedBlock
        title="Date WH Received"
        canAdd={canMutateRcvWh(user) && rooms.length === 0}
        onAdd={() => setDialog({ kind: 'rcvWh' })}
      >
        {whs.map((row) => (
          <div key={row.idRcvWh} className="related-line">
            <span>{row.rcvWhDate}</span>
            {canMutateRcvWh(user) && rooms.length === 0 && (
              <span className="row-gap">
                <button type="button" className="btn btn-ghost btn-sm" onClick={() => setDialog({ kind: 'rcvWh', row })}>
                  Edit
                </button>
                <button type="button" className="btn btn-danger btn-sm" onClick={() => removeWh(row)}>
                  Del
                </button>
              </span>
            )}
          </div>
        ))}
        {whs.length === 0 && <p className="muted">Belum ada WH receive.</p>}
      </RelatedBlock>

      <RelatedBlock
        title="Date Tool Room Received"
        canAdd={canMutateRcvTool(user)}
        onAdd={() => setDialog({ kind: 'rcvTool' })}
      >
        {rooms.map((row) => (
          <div key={row.idRcvTool} className="related-line">
            <span>{row.rcvToolDate}</span>
            {canMutateRcvTool(user) && (
              <span className="row-gap">
                <button type="button" className="btn btn-ghost btn-sm" onClick={() => setDialog({ kind: 'rcvTool', row })}>
                  Edit
                </button>
                <button type="button" className="btn btn-danger btn-sm" onClick={() => removeToolRcv(row)}>
                  Del
                </button>
              </span>
            )}
          </div>
        ))}
        {rooms.length === 0 && <p className="muted">Belum ada Tool Room receive.</p>}
      </RelatedBlock>

      {dialog && (
        <div className="modal-backdrop" onClick={close} role="presentation">
          <div className="modal-panel" onClick={(e) => e.stopPropagation()}>
            <div className="section-title-row">
              <h3>
                {dialog.kind === 'po' && 'PO'}
                {dialog.kind === 'so' && 'SO / PR'}
                {dialog.kind === 'rcvWh' && 'WH Received'}
                {dialog.kind === 'rcvTool' && 'Tool Room Received'}
              </h3>
              <button type="button" className="btn btn-ghost btn-sm" onClick={close}>
                Close
              </button>
            </div>
            {error && <div className="alert alert-error">{error}</div>}

            {dialog.kind === 'po' && (
              <form className="stack" onSubmit={onPoSubmit}>
                <label className="field">
                  <span>PO number</span>
                  <input name="po_no" defaultValue={dialog.row?.poNo ?? ''} required />
                </label>
                <button className="btn btn-primary" disabled={busy} type="submit">
                  Save
                </button>
              </form>
            )}
            {dialog.kind === 'so' && (
              <form className="stack" onSubmit={onSoSubmit}>
                <label className="field">
                  <span>SO / PR number</span>
                  <input name="so" defaultValue={dialog.row?.so ?? ''} required />
                </label>
                <label className="field">
                  <span>ETA</span>
                  <input type="date" name="eta" defaultValue={dialog.row?.eta?.slice(0, 10) ?? ''} required />
                </label>
                <label className="field">
                  <span>Note SO / PR</span>
                  <input name="note_so" defaultValue={dialog.row?.noteSo ?? ''} />
                </label>
                <button className="btn btn-primary" disabled={busy} type="submit">
                  Save
                </button>
              </form>
            )}
            {dialog.kind === 'rcvWh' && (
              <form className="stack" onSubmit={onWhSubmit}>
                <label className="field">
                  <span>Date</span>
                  <input type="date" name="date" defaultValue={dialog.row?.rcvWhDate?.slice(0, 10) ?? todayYmd()} required />
                </label>
                <button className="btn btn-primary" disabled={busy} type="submit">
                  Save
                </button>
              </form>
            )}
            {dialog.kind === 'rcvTool' && (
              <form className="stack" onSubmit={onToolRcvSubmit}>
                <label className="field">
                  <span>Date</span>
                  <input type="date" name="date" defaultValue={dialog.row?.rcvToolDate?.slice(0, 10) ?? todayYmd()} required />
                </label>
                <button className="btn btn-primary" disabled={busy} type="submit">
                  Save
                </button>
              </form>
            )}
          </div>
        </div>
      )}
    </div>
  )
}

function RelatedBlock({
  title,
  canAdd,
  onAdd,
  children,
}: {
  title: string
  canAdd: boolean
  onAdd: () => void
  children: React.ReactNode
}) {
  return (
    <div className="related-block">
      <div className="section-title-row">
        <strong>{title}</strong>
        {canAdd && (
          <button type="button" className="btn btn-primary btn-sm" onClick={onAdd}>
            +
          </button>
        )}
      </div>
      {children}
    </div>
  )
}
