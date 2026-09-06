import {
  filledStepsFromMilestone,
  isApprovedValue,
  normFormMilestone,
} from '@/features/forms/formMilestones'
import type {
  FormRow,
  RcvToolRow,
  RcvWhRow,
  SoRow,
  ToolDetailRow,
} from '@/types/models'

export type TimelineCompute = {
  filled: number
  redStep: number | null
  /** 0-based step index that is partially filled, or null. */
  partialStepIndex: number | null
  /** 0..1 fill amount for the partial step node. */
  partialProgress: number | null
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

function detailIdSet(rows: { idFormDetail: string }[] | undefined) {
  return new Set((rows ?? []).map((r) => r.idFormDetail.trim()).filter(Boolean))
}

export function computeOrderTimeline(
  form: FormRow,
  opts?: {
    tools?: ToolDetailRow[]
    so?: SoRow[]
    rcvWh?: RcvWhRow[]
    rcvTool?: RcvToolRow[]
  },
): TimelineCompute {
  if (!form.idForm.trim()) {
    return {
      filled: 0,
      redStep: null,
      partialStepIndex: null,
      partialProgress: null,
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
      partialProgress: null,
      nextLabel: NEXT_LABELS[0],
    }
  }
  if (n === 'REJECTED BY SERVICE DEPT HEAD') {
    return {
      filled: 3,
      redStep: 3,
      partialStepIndex: null,
      partialProgress: null,
      nextLabel: NEXT_LABELS[2],
    }
  }
  if (mUpper === 'HOLD BY SERVICE ADMIN' || n === 'HOLD BY SERVICE ADMIN') {
    return {
      filled: 2,
      redStep: 2,
      partialStepIndex: null,
      partialProgress: null,
      nextLabel: NEXT_LABELS[1],
    }
  }

  let filled = filledStepsFromMilestone(form.formMilestone)
  let partialStepIndex: number | null = null
  let partialProgress: number | null = null

  if (isApprovedValue(form.formSuperiorAprd)) filled = Math.max(filled, 2)
  if (form.formSadminComment.trim()) filled = Math.max(filled, 3)
  if (isApprovedValue(form.formSheadAprd)) filled = Math.max(filled, 4)

  const tools = opts?.tools ?? []
  const detailIds = detailIdSet(tools)
  const total = detailIds.size

  if (filled >= 4 && total > 0) {
    const soIds = detailIdSet(opts?.so)
    const whIds = detailIdSet(opts?.rcvWh)
    const toolRcvIds = detailIdSet(opts?.rcvTool)

    const soCount = [...detailIds].filter((id) => soIds.has(id)).length
    const whCount = [...detailIds].filter((id) => whIds.has(id)).length
    const toolRcvCount = [...detailIds].filter((id) => toolRcvIds.has(id)).length

    const allSo = soCount === total
    const anySo = soCount > 0
    const allRcvWh = whCount === total
    const anyRcvWh = whCount > 0
    const allRcvTool = toolRcvCount === total
    const anyRcvTool = toolRcvCount > 0

    // Process steps prefer live related coverage over milestone alone.
    if (allRcvTool) {
      filled = Math.max(filled, 7)
      partialStepIndex = null
      partialProgress = null
    } else if (anyRcvTool) {
      filled = Math.max(filled, 6)
      partialStepIndex = 6
      partialProgress = toolRcvCount / total
    } else if (allRcvWh) {
      filled = Math.max(filled, 6)
      partialStepIndex = null
      partialProgress = null
    } else if (anyRcvWh) {
      filled = Math.max(filled, 5)
      partialStepIndex = 5
      partialProgress = whCount / total
    } else if (allSo) {
      // Semua tool sudah punya SO → step 5 penuh.
      filled = Math.max(filled, 5)
      partialStepIndex = null
      partialProgress = null
    } else if (anySo || filled >= 5) {
      // Ada SO sebagian (atau milestone processing tapi SO belum lengkap).
      // Jangan centang penuh step 5 — tampilkan isi warna % SO.
      filled = 4
      partialStepIndex = 4
      partialProgress = soCount / total
    }
  }

  switch (n) {
    case 'RECEIVED TOOL STORE':
    case 'RECEIVED BY TOOL STORE':
      filled = STEP_COUNT
      partialStepIndex = null
      partialProgress = null
      break
    case 'PARTIAL RECEIVED TOOL STORE':
    case 'PARTIAL RECEIVED BY TOOL STORE':
      if (partialStepIndex !== 6) {
        filled = Math.max(filled, 6)
        partialStepIndex = 6
        if (partialProgress == null && total > 0) {
          const toolRcvIds = detailIdSet(opts?.rcvTool)
          const toolRcvCount = [...detailIds].filter((id) =>
            toolRcvIds.has(id),
          ).length
          partialProgress = toolRcvCount / total
        }
      }
      break
    case 'RECEIVED BY WH/GA':
      filled = Math.max(filled, 6)
      if (partialStepIndex === 6) {
        partialStepIndex = null
        partialProgress = null
      }
      break
    case 'PARTIAL RECEIVED BY WH/GA':
      if (partialStepIndex == null || partialStepIndex > 5) {
        filled = Math.max(Math.min(filled, 5), 5)
        // Keep SO/WH partial logic above if already set for step 5.
        if (partialStepIndex !== 5) {
          partialStepIndex = 5
          if (total > 0) {
            const whIds = detailIdSet(opts?.rcvWh)
            const whCount = [...detailIds].filter((id) => whIds.has(id)).length
            partialProgress = whCount / total
          }
        }
      }
      break
    default:
      break
  }

  filled = Math.min(STEP_COUNT, Math.max(0, filled))
  const nextLabel =
    filled >= STEP_COUNT
      ? 'COMPLETED'
      : NEXT_LABELS[Math.min(filled, NEXT_LABELS.length - 1)]

  return {
    filled,
    redStep: null,
    partialStepIndex,
    partialProgress,
    nextLabel,
  }
}
