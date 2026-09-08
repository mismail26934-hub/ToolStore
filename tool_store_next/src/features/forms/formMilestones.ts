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
  processingOrder: 'PROCESSING ORDER',
  partialReceivedByWh: 'PARTIAL RECEIVED BY WH/GA',
  receivedByWh: 'RECEIVED BY WH/GA',
  partialReceivedToolStore: 'PARTIAL RECEIVED TOOL STORE',
  receivedToolStore: 'RECEIVED TOOL STORE',
} as const

/** How many timeline steps are completed for a normalized milestone. */
export function filledStepsFromMilestone(milestone: string): number {
  const n = normFormMilestone(milestone)
  if (n === '' || n === 'DRAFT') return 0
  if (n === 'RECEIVED TOOL STORE' || n === 'RECEIVED BY TOOL STORE') return 7
  if (
    n === 'PARTIAL RECEIVED TOOL STORE' ||
    n === 'PARTIAL RECEIVED BY TOOL STORE'
  ) {
    return 6
  }
  if (n === 'RECEIVED BY WH/GA') return 6
  if (n === 'PARTIAL RECEIVED BY WH/GA') return 5
  if (n === 'ORDER PROCESSED' || n === 'PROCESSING ORDER') return 5
  if (n === 'APPROVED BY SERVICE DEPT HEAD') return 4
  if (n === 'REVIEWED BY SERVICE ADMIN' || n === 'CONTINUE') return 3
  if (n === 'SUPERIOR APPROVED') return 2
  if (n === 'CHECK BY TOOL STORE') return 1
  return 0
}

/** Progress rank — partials sit between full steps so upgrades are allowed. */
export function milestoneRank(milestone: string): number {
  const n = normFormMilestone(milestone)
  if (n === 'RECEIVED TOOL STORE' || n === 'RECEIVED BY TOOL STORE') return 70
  if (
    n === 'PARTIAL RECEIVED TOOL STORE' ||
    n === 'PARTIAL RECEIVED BY TOOL STORE'
  ) {
    return 65
  }
  if (n === 'RECEIVED BY WH/GA') return 60
  if (n === 'PARTIAL RECEIVED BY WH/GA') return 55
  if (n === 'ORDER PROCESSED' || n === 'PROCESSING ORDER') return 50
  if (n === 'APPROVED BY SERVICE DEPT HEAD') return 40
  return filledStepsFromMilestone(milestone) * 10
}

/**
 * After PO / SO / WH / Tool Room changes, set process milestone (steps 5–7).
 * Requires Dept Head approved. May move forward or back within process
 * milestones (e.g. semua SO dihapus → kembali ke Dept Head).
 */
export function resolveProcessMilestone(input: {
  currentMilestone: string
  formSheadAprd: string
  toolDetailIds: string[]
  /** True when at least one SO / PR exists for the form. */
  hasSo: boolean
  whDetailIds: string[]
  toolRcvDetailIds: string[]
}): string | null {
  const gateFilled = Math.max(
    filledStepsFromMilestone(input.currentMilestone),
    isApprovedValue(input.formSheadAprd) ? 4 : 0,
  )
  if (gateFilled < 4) return null

  const tools = new Set(
    input.toolDetailIds.map((id) => id.trim()).filter(Boolean),
  )
  const total = tools.size
  const wh = new Set(input.whDetailIds.map((id) => id.trim()).filter(Boolean))
  const rooms = new Set(
    input.toolRcvDetailIds.map((id) => id.trim()).filter(Boolean),
  )

  const whCount = total ? [...tools].filter((id) => wh.has(id)).length : 0
  const roomCount = total ? [...tools].filter((id) => rooms.has(id)).length : 0

  let next: string
  if (total > 0 && roomCount === total) {
    next = Milestone.receivedToolStore
  } else if (roomCount > 0) {
    next = Milestone.partialReceivedToolStore
  } else if (total > 0 && whCount === total) {
    next = Milestone.receivedByWh
  } else if (whCount > 0) {
    next = Milestone.partialReceivedByWh
  } else if (input.hasSo) {
    next = Milestone.processingOrder
  } else {
    // Tidak ada SO / WH / Tool Room → kembali ke milestone Dept Head.
    next = Milestone.approvedByDeptHead
  }

  if (normFormMilestone(next) === normFormMilestone(input.currentMilestone)) {
    return null
  }

  // Jangan sentuh milestone approval di bawah Dept Head.
  const currentRank = milestoneRank(input.currentMilestone)
  if (currentRank < 40 && !isApprovedValue(input.formSheadAprd)) {
    return null
  }

  return next
}
