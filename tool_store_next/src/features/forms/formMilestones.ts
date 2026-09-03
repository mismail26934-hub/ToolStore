/** Milestone helpers — mirrors Flutter form approval gates. */

export function normFormMilestone(value: string | null | undefined): string {
  return (value ?? '')
    .trim()
    .toUpperCase()
    .replace(/\./g, '')
    .replace(/\s+/g, ' ')
}

export function isApprovedValue(value: string): boolean {
  const v = value.trim().toUpperCase()
  return v === 'APPROVED' || v.startsWith('APPROVED')
}

export function isRejectedValue(value: string): boolean {
  const v = value.trim().toUpperCase()
  return v === 'REJECTED' || v.startsWith('REJECTED')
}

export function isDraftMilestone(milestone: string): boolean {
  const m = normFormMilestone(milestone)
  return m === '' || m === 'DRAFT'
}

export function isCheckByToolStore(milestone: string): boolean {
  return normFormMilestone(milestone) === 'CHECK BY TOOL STORE'
}

export function isSuperiorApproved(milestone: string): boolean {
  const m = normFormMilestone(milestone)
  return m === 'SUPERIOR APPROVED' || m === 'HOLD BY SERVICE ADMIN'
}

export function isReviewedByServiceAdmin(milestone: string): boolean {
  const m = normFormMilestone(milestone)
  return (
    m === 'REVIEWED BY SERVICE ADMIN' ||
    m === 'REJECTED BY SERVICE DEPT HEAD'
  )
}

export const Milestone = {
  checkByToolStore: 'CHECK BY TOOL STORE',
  superiorApproved: 'SUPERIOR APPROVED',
  rejectedBySuperior: 'REJECTED BY SUPERIOR',
  reviewedByServiceAdmin: 'REVIEWED BY SERVICE ADMIN',
  holdByServiceAdmin: 'HOLD BY SERVICE ADMIN',
  approvedByDeptHead: 'APPROVED BY SERVICE DEPT. HEAD',
  rejectedByDeptHead: 'REJECTED BY SERVICE DEPT. HEAD',
} as const
