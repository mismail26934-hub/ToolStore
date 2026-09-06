/** Treat blank / dash placeholders as empty for UI labels. */
export function meaningfulLabel(value?: string | null): string {
  const v = String(value ?? '').trim()
  if (!v || v === '-' || v === '—') return ''
  return v
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
