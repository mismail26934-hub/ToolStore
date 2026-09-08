'use client'

import { useState, type FormEvent } from 'react'
import { useAuth } from '@/auth/AuthContext'
import {
  canAccessDeptHeadApproval,
  canAccessServiceAdminApproval,
  canAccessSuperiorApproval,
  canRequestOrder,
} from '@/auth/roles'
import { formEditPayload } from '@/features/forms/formEdit'
import { isRejectedBySuperior, Milestone } from '@/features/forms/formMilestones'
import { useFormMutations } from '@/features/forms/useForms'
import { formatDateDisplay } from '@/lib/dateFormat'
import { formCheckByDisplay } from '@/lib/displayLabel'
import type { FormRow } from '@/types/models'

type Props = {
  form: FormRow
  hasTools: boolean
}

export function FormApprovalSection({ form, hasTools }: Props) {
  const { user } = useAuth()
  const mutate = useFormMutations()
  const [dialog, setDialog] = useState<
    'request' | 'superior' | 'sadmin' | 'dept' | null
  >(null)
  const [error, setError] = useState<string | null>(null)
  const [decision, setDecision] = useState('APPROVED')
  const [comment, setComment] = useState('')

  const showRequest = canRequestOrder(user, form, hasTools)
  const showSuperior = canAccessSuperiorApproval(user, form)
  const reopenSuperior = isRejectedBySuperior(form.formMilestone)
  const showSadmin = canAccessServiceAdminApproval(user, form)
  const showDept = canAccessDeptHeadApproval(user, form)

  const close = () => {
    setDialog(null)
    setError(null)
    setComment('')
    setDecision('APPROVED')
  }

  const run = async (patch: Parameters<typeof formEditPayload>[1]) => {
    setError(null)
    try {
      await mutate.mutateAsync(
        formEditPayload(form, patch, user?.idUsersApp ?? ''),
      )
      close()
    } catch (e) {
      setError((e as Error).message)
    }
  }

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault()
    if (!dialog) return

    if (dialog === 'request') {
      await run({
        formCheckBy: user?.idUsersApp || form.formCheckBy,
        formDateCheckBy: new Date().toISOString().slice(0, 10),
        formMilestone: Milestone.checkByToolStore,
      })
      return
    }

    if (!comment.trim()) {
      setError('Comment wajib diisi')
      return
    }

    if (dialog === 'superior') {
      const approved = decision === 'APPROVED'
      await run({
        formSuperiorAprd: decision,
        formSuperiorComment: comment.trim(),
        formMilestone: approved
          ? Milestone.superiorApproved
          : Milestone.rejectedBySuperior,
      })
      return
    }

    if (dialog === 'sadmin') {
      const cont = decision === 'CONTINUE'
      await run({
        formSadminComment: comment.trim(),
        formMilestone: cont
          ? Milestone.reviewedByServiceAdmin
          : Milestone.holdByServiceAdmin,
      })
      return
    }

    if (dialog === 'dept') {
      const approved = decision === 'APPROVED'
      await run({
        formSheadAprd: decision,
        formSheadComment: comment.trim(),
        formMilestone: approved
          ? Milestone.approvedByDeptHead
          : Milestone.rejectedByDeptHead,
      })
    }
  }

  return (
    <div className="approval-section">
      <div className="section-title-row">
        <h3>Approvals</h3>
        <span className="chip">{form.formMilestone || 'DRAFT'}</span>
      </div>

      <div className="approval-grid">
        <ApprovalTile
          title="Check / Request"
          value={formCheckByDisplay(form) || '—'}
          sub={
            form.formDateCheckBy
              ? formatDateDisplay(form.formDateCheckBy)
              : ''
          }
          actionLabel={showRequest ? 'Request Order' : undefined}
          onAction={showRequest ? () => setDialog('request') : undefined}
        />
        <ApprovalTile
          title="Superior"
          value={form.formSuperiorAprd || '—'}
          sub={form.formSuperiorComment || ''}
          actionLabel={
            showSuperior ? (reopenSuperior ? 'Reopen' : 'Approve') : undefined
          }
          onAction={
            showSuperior
              ? () => {
                  setDecision('APPROVED')
                  setDialog('superior')
                }
              : undefined
          }
        />
        <ApprovalTile
          title="Service Admin"
          value={form.formSadminComment ? 'Noted' : '—'}
          sub={form.formSadminComment || ''}
          actionLabel={showSadmin ? 'Review' : undefined}
          onAction={
            showSadmin
              ? () => {
                  setDecision('CONTINUE')
                  setDialog('sadmin')
                }
              : undefined
          }
        />
        <ApprovalTile
          title="Dept Head"
          value={form.formSheadAprd || '—'}
          sub={form.formSheadComment || ''}
          actionLabel={showDept ? 'Approve' : undefined}
          onAction={
            showDept
              ? () => {
                  setDecision('APPROVED')
                  setDialog('dept')
                }
              : undefined
          }
        />
      </div>

      {dialog && (
        <div className="modal-backdrop" role="presentation" onClick={close}>
          <div
            className="modal-panel"
            role="dialog"
            aria-modal="true"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="section-title-row">
              <h3>
                {dialog === 'request' && 'Request Order'}
                {dialog === 'superior' &&
                  (reopenSuperior ? 'Reopen Superior Approval' : 'Superior Approval')}
                {dialog === 'sadmin' && 'Service Admin'}
                {dialog === 'dept' && 'Dept Head Approval'}
              </h3>
              <button type="button" className="btn btn-ghost btn-sm" onClick={close}>
                Close
              </button>
            </div>

            <form className="stack" onSubmit={onSubmit}>
              {dialog === 'request' && (
                <p className="muted">
                  Kirim form ke superior? Check By akan diisi nama Anda dan
                  milestone menjadi CHECK BY TOOL STORE.
                </p>
              )}

              {dialog === 'superior' && (
                <>
                  {reopenSuperior && (
                    <p className="muted">
                      Ubah keputusan Superior. APPROVED akan lanjut ke Service
                      Admin; REJECTED tetap menahan form.
                    </p>
                  )}
                  <label className="field">
                    <span>Decision</span>
                    <select
                      value={decision}
                      onChange={(e) => setDecision(e.target.value)}
                    >
                      <option value="APPROVED">APPROVED</option>
                      <option value="REJECTED">REJECTED</option>
                    </select>
                  </label>
                  <label className="field">
                    <span>Comment</span>
                    <textarea
                      rows={3}
                      value={comment}
                      onChange={(e) => setComment(e.target.value)}
                      required
                    />
                  </label>
                </>
              )}

              {dialog === 'sadmin' && (
                <>
                  <label className="field">
                    <span>Decision</span>
                    <select
                      value={decision}
                      onChange={(e) => setDecision(e.target.value)}
                    >
                      <option value="CONTINUE">CONTINUE</option>
                      <option value="HOLD">HOLD</option>
                    </select>
                  </label>
                  <label className="field">
                    <span>Comment</span>
                    <textarea
                      rows={3}
                      value={comment}
                      onChange={(e) => setComment(e.target.value)}
                      required
                    />
                  </label>
                </>
              )}

              {dialog === 'dept' && (
                <>
                  <label className="field">
                    <span>Decision</span>
                    <select
                      value={decision}
                      onChange={(e) => setDecision(e.target.value)}
                    >
                      <option value="APPROVED">APPROVED</option>
                      <option value="REJECTED">REJECTED</option>
                    </select>
                  </label>
                  <label className="field">
                    <span>Comment</span>
                    <textarea
                      rows={3}
                      value={comment}
                      onChange={(e) => setComment(e.target.value)}
                      required
                    />
                  </label>
                </>
              )}

              {error && <div className="alert alert-error">{error}</div>}

              <button
                type="submit"
                className="btn btn-primary"
                disabled={mutate.isPending}
              >
                {mutate.isPending ? 'Saving…' : 'Confirm'}
              </button>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}

function ApprovalTile({
  title,
  value,
  sub,
  actionLabel,
  onAction,
}: {
  title: string
  value: string
  sub: string
  actionLabel?: string
  onAction?: () => void
}) {
  return (
    <div className="approval-tile">
      <div className="muted">{title}</div>
      <strong>{value}</strong>
      {sub && <div className="muted approval-sub">{sub}</div>}
      {actionLabel && onAction && (
        <button type="button" className="btn btn-primary btn-sm" onClick={onAction}>
          {actionLabel}
        </button>
      )}
    </div>
  )
}
