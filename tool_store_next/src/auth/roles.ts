import type { FormRow, SessionUser } from '@/types/models'
import {
  isCheckByToolStore,
  isDraftMilestone,
  isRejectedBySuperior,
  isReviewedByServiceAdmin,
  isSuperiorApproved,
  normFormMilestone,
} from '@/features/forms/formMilestones'

function levelOf(user: { level?: string } | null) {
  return (user?.level ?? '').toUpperCase()
}

export function canAddOrEditForm(user: { level?: string } | null) {
  const lv = levelOf(user)
  return lv === 'SUPERADMIN' || lv === 'TOOL_KEEPER'
}

/**
 * Header / tool items lock after Order Request (step 1–7).
 * DRAFT and REJECTED BY SUPERIOR stay editable for Tool Keeper.
 */
export function isFormContentLocked(milestone: string | null | undefined) {
  const m = normFormMilestone(milestone)
  if (m === '' || m === 'DRAFT') return false
  if (m === 'REJECTED BY SUPERIOR') return false
  return true
}

export function canMutateFormContent(
  user: { level?: string } | null,
  milestone: string | null | undefined,
) {
  if (!canAddOrEditForm(user)) return false
  if (levelOf(user) === 'SUPERADMIN') return true
  return !isFormContentLocked(milestone)
}

export function formContentDeniedMessage(
  user: { level?: string } | null,
  milestone: string | null | undefined,
) {
  if (canMutateFormContent(user, milestone)) return null
  if (!canAddOrEditForm(user)) {
    return 'Hanya Super Admin atau Tool Keeper yang boleh mengubah form / tool item'
  }
  return 'Form sudah masuk proses (step 1–7). Hanya Super Admin yang boleh mengubah'
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
