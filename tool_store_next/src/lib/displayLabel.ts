/** Treat blank / dash placeholders as empty for UI labels. */
export function meaningfulLabel(value?: string | null): string {
  const v = String(value ?? '').trim()
  if (!v || v === '-' || v === '—') return ''
  return v
}

const USER_ID_RE =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

export function looksLikeUserId(value?: string | null): boolean {
  return USER_ID_RE.test(String(value ?? '').trim())
}

/** Prefer a human name; never surface a stored user UUID. */
export function nameNotId(value?: string | null): string {
  const v = meaningfulLabel(value)
  if (!v || looksLikeUserId(v)) return ''
  return v
}

export function servicemanDisplay(form: {
  formServNameLabel?: string
  formServName?: string
}): string {
  return nameNotId(form.formServNameLabel) || nameNotId(form.formServName)
}

export function formCheckByDisplay(form: {
  formCheckByLabel?: string
  formCheckBy?: string
}): string {
  return nameNotId(form.formCheckByLabel) || nameNotId(form.formCheckBy)
}

export function userPickLabel(row: {
  namaUser?: string
  username?: string
  idUsers?: string
}): string {
  return (
    meaningfulLabel(row.namaUser) ||
    meaningfulLabel(row.username) ||
    meaningfulLabel(row.idUsers) ||
    ''
  )
}

export function superiorDisplayName(parts: {
  namaUser?: string
  namaSuperior?: string
  username?: string
  idTu?: string
}): string {
  return (
    meaningfulLabel(parts.namaUser) ||
    meaningfulLabel(parts.namaSuperior) ||
    meaningfulLabel(parts.username) ||
    meaningfulLabel(parts.idTu) ||
    ''
  )
}
