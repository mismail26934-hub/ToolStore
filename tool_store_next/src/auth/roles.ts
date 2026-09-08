import type { FormRow, SessionUser } from '@/types/models'
import {
  isCheckByToolStore,
  isDraftMilestone,
  isRejectedBySuperior,
  isReviewedByServiceAdmin,
  isSuperiorApproved,
} from '@/features/forms/formMilestones'

function levelOf(user: SessionUser | null) {
  return (user?.level ?? '').toUpperCase()
}

export function canAddOrEditForm(user: SessionUser | null) {
  const lv = levelOf(user)
  return lv === 'SUPERADMIN' || lv === 'TOOL_KEEPER'
}

export function canMutatePo(user: SessionUser | null) {
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

export function canAccessSuperiorApproval(user: SessionUser | null, form: FormRow) {
  const lv = levelOf(user)
  if (isRejectedBySuperior(form.formMilestone)) {
    return lv === 'SUPERADMIN' || isServicemanSuperior(user, form)
  }
  if (!isCheckByToolStore(form.formMilestone)) return false
  if (lv === 'SUPERADMIN' || lv === 'SUPERIOR') return true
  const sid = user?.superiorId?.trim() ?? ''
  const fid = form.superiorId?.trim() ?? ''
  return sid !== '' && fid !== '' && sid === fid
}

/** Logged-in user is the superior assigned to this form's serviceman. */
function isServicemanSuperior(user: SessionUser | null, form: FormRow) {
  const uid = user?.idUsersApp?.trim() ?? ''
  if (!uid) return false
  const servSid = form.servicemanSuperiorId?.trim() || form.superiorId?.trim() || ''
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
