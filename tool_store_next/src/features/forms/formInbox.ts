import type { FormRow } from '@/types/models'
import { normFormMilestone } from '@/features/forms/formMilestones'

/** Terminal / parked milestones excluded from default "Data Tool" inbox. */
export const ACTIVE_EXCLUDES = [
  'RECEIVED TOOL STORE',
  'HOLD BY SERVICE ADMIN',
  'REJECTED BY SUPERIOR',
  'REJECTED BY SERVICE DEPT HEAD',
] as const

export type InboxPreset =
  | 'active'
  | 'all'
  | 'blank'
  | 'completed'
  | 'hold'
  | 'rejected-superior'
  | 'rejected-dept'
  | 'check-by'
  | 'superior-approved'
  | 'reviewed-sadmin'
  | 'approved-dept'
  | 'tool-received-wh'

export type InboxMode =
  | { type: 'active' }
  | { type: 'all' }
  | { type: 'blank' }
  | { type: 'include'; milestones: string[] }

export const INBOX_PRESETS: Record<
  InboxPreset,
  { label: string; mode: InboxMode }
> = {
  active: { label: 'Data Tool', mode: { type: 'active' } },
  all: { label: 'All forms', mode: { type: 'all' } },
  blank: { label: 'Draft', mode: { type: 'blank' } },
  completed: {
    label: 'Completed',
    mode: { type: 'include', milestones: ['RECEIVED TOOL STORE'] },
  },
  hold: {
    label: 'Hold',
    mode: { type: 'include', milestones: ['HOLD BY SERVICE ADMIN'] },
  },
  'rejected-superior': {
    label: 'Rejected (Superior)',
    mode: { type: 'include', milestones: ['REJECTED BY SUPERIOR'] },
  },
  'rejected-dept': {
    label: 'Rejected (Dept Head)',
    mode: { type: 'include', milestones: ['REJECTED BY SERVICE DEPT HEAD'] },
  },
  'check-by': {
    label: 'Superior Approval',
    mode: { type: 'include', milestones: ['CHECK BY TOOL STORE'] },
  },
  'superior-approved': {
    label: 'Service Admin',
    mode: { type: 'include', milestones: ['SUPERIOR APPROVED'] },
  },
  'reviewed-sadmin': {
    label: 'Dept Head',
    mode: { type: 'include', milestones: ['REVIEWED BY SERVICE ADMIN'] },
  },
  'approved-dept': {
    label: 'Counter GA',
    mode: {
      type: 'include',
      milestones: ['APPROVED BY SERVICE DEPT. HEAD', 'APPROVED BY SERVICE DEPT HEAD'],
    },
  },
  'tool-received-wh': {
    label: 'Tool Received WH/GA',
    mode: {
      type: 'include',
      milestones: [
        'RECEIVED BY WH/GA',
        'PARTIAL RECEIVED BY WH/GA',
        'PARTIAL RECEIVED TOOL STORE',
        'PARTIAL RECEIVED BY TOOL STORE',
      ],
    },
  },
}

export function resolveInboxMode(
  inbox: string | null,
  milestonesParam: string | null,
  legacyMilestone?: string | null,
): InboxMode {
  if (milestonesParam?.trim()) {
    return {
      type: 'include',
      milestones: milestonesParam
        .split('|')
        .map((s) => s.trim())
        .filter(Boolean),
    }
  }
  if (legacyMilestone != null && legacyMilestone !== '') {
    const legacy = legacyMilestone.trim()
    if (legacy.toUpperCase() === 'DRAFT') return { type: 'blank' }
    return { type: 'include', milestones: [legacy] }
  }
  const key = (inbox?.trim() || 'active') as InboxPreset
  return INBOX_PRESETS[key]?.mode ?? { type: 'active' }
}

export function inboxTitle(
  inbox: string | null,
  milestonesParam: string | null,
  legacyMilestone?: string | null,
): string {
  if (milestonesParam?.trim()) return 'Filtered forms'
  if (legacyMilestone != null && legacyMilestone !== '') {
    return `Filter: ${legacyMilestone}`
  }
  const key = (inbox?.trim() || 'active') as InboxPreset
  return INBOX_PRESETS[key]?.label ?? 'Data Tool'
}

/** Include / blank filters need a large page (Flutter dashboard fetch). */
export function needsInboxFetchLimit(mode: InboxMode): boolean {
  return mode.type === 'include' || mode.type === 'blank'
}

export function matchesInboxFilter(form: FormRow, mode: InboxMode): boolean {
  const m = normFormMilestone(form.formMilestone)
  if (mode.type === 'all') return true
  if (mode.type === 'blank') return m === '' || m === 'DRAFT'
  if (mode.type === 'active') {
    const excluded = ACTIVE_EXCLUDES.map(normFormMilestone)
    return !excluded.includes(m)
  }
  const wanted = mode.milestones.map(normFormMilestone)
  return wanted.includes(m)
}

/** Fetch limit when client-side inbox filtering (matches Flutter dashboard fetch). */
export const INBOX_FETCH_LIMIT = 1000
