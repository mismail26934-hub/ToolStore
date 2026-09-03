import type { SessionUser } from '../types/models'

const PREFIX = 'toolstore:'

const KEYS = {
  value: `${PREFIX}value`,
  idUsersApp: `${PREFIX}idUsersApp`,
  name: `${PREFIX}name`,
  username: `${PREFIX}username`,
  password: `${PREFIX}password`,
  level: `${PREFIX}level`,
  token: `${PREFIX}token`,
  status: `${PREFIX}status`,
  idTu: `${PREFIX}idTu`,
  foto: `${PREFIX}foto`,
  superiorId: `${PREFIX}superiorId`,
  namaSuperior: `${PREFIX}namaSuperior`,
  noTelp: `${PREFIX}noTelp`,
} as const

function get(key: string): string {
  if (typeof window === 'undefined') return ''
  return localStorage.getItem(key)?.trim() ?? ''
}

function set(key: string, value: string) {
  if (typeof window === 'undefined') return
  localStorage.setItem(key, value)
}

export function readSession(): SessionUser | null {
  const idUsersApp = get(KEYS.idUsersApp)
  if (!idUsersApp || idUsersApp === 'null') return null

  return {
    idUsersApp,
    name: get(KEYS.name),
    username: get(KEYS.username),
    password: get(KEYS.password),
    level: get(KEYS.level),
    token: get(KEYS.token),
    status: get(KEYS.status),
    idTu: get(KEYS.idTu),
    foto: get(KEYS.foto),
    superiorId: get(KEYS.superiorId),
    namaSuperior: get(KEYS.namaSuperior),
    noTelp: get(KEYS.noTelp),
    value: get(KEYS.value) || '1',
  }
}

export function writeSessionFromLogin(payload: Record<string, unknown>, statusLogin: string) {
  const str = (v: unknown) => (v == null ? '' : String(v))
  set(KEYS.value, statusLogin)
  set(KEYS.idUsersApp, str(payload.id_users))
  set(KEYS.name, str(payload.nama_user))
  set(KEYS.username, str(payload.username))
  set(KEYS.password, str(payload.password))
  set(KEYS.level, str(payload.level))
  set(KEYS.token, str(payload.token))
  set(KEYS.status, str(payload.status))
  set(KEYS.idTu, str(payload.id_tu))
  set(KEYS.foto, str(payload.foto))
  set(KEYS.superiorId, str(payload.superior_id))
  set(KEYS.namaSuperior, str(payload.nama_superior))
  set(KEYS.noTelp, str(payload.no_telp))
}

/** Patch session fields after profile self-edit (keeps login token/value). */
export function updateSessionProfile(patch: {
  name?: string
  username?: string
  password?: string
  noTelp?: string
  idTu?: string
  superiorId?: string
  namaSuperior?: string
  level?: string
  status?: string
}) {
  if (patch.name != null) set(KEYS.name, patch.name)
  if (patch.username != null) set(KEYS.username, patch.username)
  if (patch.password != null) set(KEYS.password, patch.password)
  if (patch.noTelp != null) set(KEYS.noTelp, patch.noTelp)
  if (patch.idTu != null) set(KEYS.idTu, patch.idTu)
  if (patch.superiorId != null) set(KEYS.superiorId, patch.superiorId)
  if (patch.namaSuperior != null) set(KEYS.namaSuperior, patch.namaSuperior)
  if (patch.level != null) set(KEYS.level, patch.level)
  if (patch.status != null) set(KEYS.status, patch.status)
}

export function clearSession() {
  if (typeof window === 'undefined') return
  Object.values(KEYS).forEach((k) => localStorage.removeItem(k))
}

export function isAuthenticated(): boolean {
  return readSession() != null
}

export function isSuperAdmin(session: SessionUser | null): boolean {
  return (session?.level ?? '').toUpperCase() === 'SUPERADMIN'
}
