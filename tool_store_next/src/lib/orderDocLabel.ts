/** Labels for the SO table (`so`), which vary by item Cat / Vendor. */

export function normValType(value: string | null | undefined): 'CAT' | 'VENDOR' | '' {
  const v = (value ?? '').trim().toUpperCase()
  if (v === 'CAT') return 'CAT'
  if (v === 'VENDOR') return 'VENDOR'
  return ''
}

/** Section title on the tool card and modal. */
export function soSectionLabel(valType?: string | null): string {
  const vt = normValType(valType)
  if (vt === 'CAT') return 'SO (Sales Order Internal)'
  if (vt === 'VENDOR') return 'PO (Purchase Order)'
  return 'SO / PR'
}

export function soNumberLabel(valType?: string | null): string {
  const vt = normValType(valType)
  if (vt === 'CAT') return 'SO number'
  if (vt === 'VENDOR') return 'PO number'
  return 'SO / PR number'
}

export function soNoteLabel(valType?: string | null): string {
  const vt = normValType(valType)
  if (vt === 'CAT') return 'Note SO'
  if (vt === 'VENDOR') return 'Note PO'
  return 'Note SO / PR'
}

/** Mix of CAT / VENDOR on a form. Empty or unknown counts as mixed. */
export type FormValTypeMix = 'CAT' | 'VENDOR' | 'MIXED'

export function formValTypeMix(
  valTypes: Array<string | null | undefined>,
): FormValTypeMix {
  let cat = false
  let vendor = false
  for (const raw of valTypes) {
    const vt = normValType(raw)
    if (vt === 'CAT') cat = true
    if (vt === 'VENDOR') vendor = true
  }
  if (cat && !vendor) return 'CAT'
  if (vendor && !cat) return 'VENDOR'
  return 'MIXED'
}

export function processorRoleLabel(mix: FormValTypeMix): string {
  if (mix === 'CAT') return 'Counter'
  if (mix === 'VENDOR') return 'GA'
  return 'Counter/GA'
}

export function processorLevels(mix: FormValTypeMix): string[] {
  if (mix === 'CAT') return ['COUNTER']
  if (mix === 'VENDOR') return ['GA']
  return ['COUNTER', 'GA']
}
