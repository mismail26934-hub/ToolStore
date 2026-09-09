import type { FormRow, SessionUser } from '@/types/models'
import {
  isCheckByToolStore,
  isDraftMilestone,
  isRejectedBySuperior,
  isReviewedByServiceAdmin,
  isSuperiorApproved,
} from '@/features/forms/formMilestones'

function levelOf(user: { level?: string } | null) {
  return (user?.level ?? '').toUpperCase()
}

export function canAddOrEditForm(user: SessionUser | null) {
  const lv = levelOf(user)
  return lv === 'SUPERADMIN' || lv === 'TOOL_KEEPER'
}

export function canMutatePr(user: SessionUser | null) {
  const lv = levelOf(user)
  return lv === 'SUPERADMIN' || lv === 'TOOL_KEEPER'
}

export function canMutateSo(
  user: { level?: string } | null,
  valType?: string | null,
) {
  const lv = (user?.level ?? '').toUpperCase()
  if (lv === 'SUPERADMIN') return true
  const vt = (valType ?? '').trim().toUpperCase()
  if (lv === 'COUNTER') return vt === 'CAT'
  if (lv === 'GA') return vt === 'VENDOR'
  return false
}

export function canMutateRcvWh(user: SessionUser | null) {
  const lv = levelOf(user)
  return lv === 'SUPERADMIN' || lv === 'WH'
}

export function canMutateRcvTool(user: SessionUser | null) {
  const lv = levelOf(user)
  return lv === 'SUPERADMIN' || lv === 'TOOL_KEEPER'
}

export function canRequestOrder(user: SessionUser | null, form: FormRow, hasTools: boolean) {
  const lv = levelOf(user)
  if (!(lv === 'SUPERADMIN' || lv === 'SERVICE_ADMIN' || lv === 'TOOL_KEEPER')) {
    return false
  }
  return hasTools && isDraftMilestone(form.formMilestone)
}

export function canAccessSuperiorApproval(
  user: { idUsersApp?: string; level?: string } | null,
  form: FormRow,
) {
  const pending =
    isCheckByToolStore(form.formMilestone) ||
    isRejectedBySuperior(form.formMilestone)
  if (!pending) return false
  const lv = levelOf(user)
  return lv === 'SUPERADMIN' || isServicemanSuperior(user, form)
}

/** Logged-in user is the superior assigned to this form's serviceman. */
export function isServicemanSuperior(
  user: { idUsersApp?: string } | null,
  form: Pick<FormRow, 'servicemanSuperiorId' | 'superiorId'>,
) {
  const uid = user?.idUsersApp?.trim() ?? ''
  if (!uid) return false
  const servSid =
    form.servicemanSuperiorId?.trim() || form.superiorId?.trim() || ''
  return servSid !== '' && uid === servSid
}

export function canAccessServiceAdminApproval(user: SessionUser | null, form: FormRow) {
  if (!isSuperiorApproved(form.formMilestone)) return false
  const lv = levelOf(user)
  return lv === 'SUPERADMIN' || lv === 'SERVICE_ADMIN'
}

export function canAccessDeptHeadApproval(user: SessionUser | null, form: FormRow) {
  if (!isReviewedByServiceAdmin(form.formMilestone)) return false
  const lv = levelOf(user)
  return lv === 'SUPERADMIN' || lv === 'HEAD_SERVICE'
}

export function todayYmd() {
  const d = new Date()
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`
}
