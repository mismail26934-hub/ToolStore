import { isApprovedValue, normFormMilestone } from '@/features/forms/formMilestones'
import type { FormRow, RcvToolRow, RcvWhRow, ToolDetailRow } from '@/types/models'

export type TimelineCompute = {
  filled: number
  redStep: number | null
  /** 0-based step index that is partially filled, or null. */
  partialStepIndex: number | null
  nextLabel: string
}

const NEXT_LABELS = [
  '1. CHECK BY TOOL STORE',
  '2. SUPERIOR APPROVED',
  '3. REVIEWED BY SERVICE ADMIN',
  '4. APPROVED BY SERVICE DEPT HEAD',
  '5. PROCESSING ORDER',
  '6. RECEIVED BY WH/GA',
  '7. RECEIVED TOOL STORE',
]

const STEP_COUNT = 7

function filledStepsFromMilestoneNorm(n: string): number {
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

export function computeOrderTimeline(
  form: FormRow,
  opts?: {
    tools?: ToolDetailRow[]
    rcvWh?: RcvWhRow[]
    rcvTool?: RcvToolRow[]
  },
): TimelineCompute {
  if (!form.idForm.trim()) {
    return {
      filled: 0,
      redStep: null,
      partialStepIndex: null,
      nextLabel: NEXT_LABELS[0],
    }
  }

  const mUpper = form.formMilestone.trim().toUpperCase()
  const n = normFormMilestone(form.formMilestone)

  if (mUpper === 'REJECTED BY SUPERIOR' || n === 'REJECTED BY SUPERIOR') {
    return {
      filled: 1,
      redStep: 1,
      partialStepIndex: null,
      nextLabel: NEXT_LABELS[0],
    }
  }
  if (n === 'REJECTED BY SERVICE DEPT HEAD') {
    return {
      filled: 3,
      redStep: 3,
      partialStepIndex: null,
      nextLabel: NEXT_LABELS[2],
    }
  }
  if (mUpper === 'HOLD BY SERVICE ADMIN' || n === 'HOLD BY SERVICE ADMIN') {
    return {
      filled: 2,
      redStep: 2,
      partialStepIndex: null,
      nextLabel: NEXT_LABELS[1],
    }
  }

  let filled = filledStepsFromMilestoneNorm(n)
  let partialStepIndex: number | null = null

  if (isApprovedValue(form.formSuperiorAprd)) filled = Math.max(filled, 2)
  if (form.formSadminComment.trim()) filled = Math.max(filled, 3)
  if (isApprovedValue(form.formSheadAprd)) filled = Math.max(filled, 4)

  const tools = opts?.tools ?? []
  if (filled >= 5 && tools.length > 0) {
    const detailIds = new Set(
      tools.map((t) => t.idFormDetail.trim()).filter(Boolean),
    )
    if (detailIds.size > 0) {
      const total = detailIds.size
      const whIds = new Set(
        (opts?.rcvWh ?? []).map((r) => r.idFormDetail.trim()).filter(Boolean),
      )
      const toolIds = new Set(
        (opts?.rcvTool ?? []).map((r) => r.idFormDetail.trim()).filter(Boolean),
      )
      const whCount = [...detailIds].filter((id) => whIds.has(id)).length
      const toolCount = [...detailIds].filter((id) => toolIds.has(id)).length
      const allRcvWh = whCount === total
      const anyRcvWh = whCount > 0
      const allRcvTool = toolCount === total
      const anyRcvTool = toolCount > 0

      if (allRcvTool) {
        filled = Math.max(filled, 7)
      } else if (anyRcvTool) {
        filled = Math.max(filled, 6)
        partialStepIndex = 6
      } else if (allRcvWh) {
        filled = Math.max(filled, 6)
      } else if (anyRcvWh) {
        filled = Math.max(filled, 5)
        partialStepIndex = 5
      }
    }
  }

  switch (n) {
    case 'RECEIVED TOOL STORE':
    case 'RECEIVED BY TOOL STORE':
      filled = STEP_COUNT
      partialStepIndex = null
      break
    case 'PARTIAL RECEIVED TOOL STORE':
    case 'PARTIAL RECEIVED BY TOOL STORE':
      filled = Math.max(filled, 6)
      partialStepIndex = 6
      break
    case 'RECEIVED BY WH/GA':
      filled = Math.max(filled, 6)
      if (partialStepIndex === 6) partialStepIndex = null
      break
    case 'PARTIAL RECEIVED BY WH/GA':
      filled = Math.max(filled, 5)
      partialStepIndex = 5
      break
    default:
      break
  }

  filled = Math.min(STEP_COUNT, Math.max(0, filled))
  const nextLabel =
    filled >= STEP_COUNT
      ? 'COMPLETED'
      : NEXT_LABELS[Math.min(filled, NEXT_LABELS.length - 1)]

  return { filled, redStep: null, partialStepIndex, nextLabel }
}
