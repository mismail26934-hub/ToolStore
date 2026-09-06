export const ACTION_NOTE_OPTIONS = [
  { value: 'A', label: 'A = Order Small Tool Account' },
  { value: 'B', label: 'B = Order Rep & Maint Account' },
  { value: 'C', label: 'C = Charge Personal Account' },
  { value: 'D', label: 'D = Charge to ...' },
] as const

export function normalizeActionNoteCode(raw: string | null | undefined): string {
  const c = (raw ?? '').trim().charAt(0).toUpperCase()
  return ACTION_NOTE_OPTIONS.some((o) => o.value === c) ? c : ''
}

export function formatActionNote(raw: string | null | undefined): string {
  const code = normalizeActionNoteCode(raw)
  if (!code) return '—'
  return (
    ACTION_NOTE_OPTIONS.find((o) => o.value === code)?.label ?? code
  )
}
