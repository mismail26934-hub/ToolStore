import type { FormRow, SessionUser } from '@/types/models'
import {
  isCheckByToolStore,
  isDraftMilestone,
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

export function canMutateSo(user: SessionUser | null) {
  const lv = levelOf(user)
  return lv === 'SUPERADMIN' || lv === 'COUNTER' || lv === 'GA'
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
  if (!isCheckByToolStore(form.formMilestone)) return false
  const lv = levelOf(user)
  if (lv === 'SUPERADMIN' || lv === 'SUPERIOR') return true
  const sid = user?.superiorId?.trim() ?? ''
  const fid = form.superiorId?.trim() ?? ''
  return sid !== '' && fid !== '' && sid === fid
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
