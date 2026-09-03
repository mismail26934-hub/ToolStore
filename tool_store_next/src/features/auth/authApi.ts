import { readSession, writeSessionFromLogin } from '../../auth/session'
import type { SessionUser } from '../../types/models'

export async function loginRequest(
  username: string,
  password: string,
): Promise<SessionUser> {
  const res = await fetch('/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      username: username.trim(),
      password,
    }),
  })

  let data: {
    value?: string
    message?: string
    user?: Record<string, unknown>
  }
  try {
    data = (await res.json()) as typeof data
  } catch {
    throw new Error('Respons login tidak valid')
  }

  const statusLogin = String(data.value ?? '0')
  const message = String(data.message ?? 'Login gagal')
  if (!res.ok || statusLogin !== '1' || !data.user) {
    throw new Error(message)
  }

  writeSessionFromLogin(data.user, statusLogin)
  const session = readSession()
  if (!session) throw new Error('Gagal menyimpan sesi login')
  return session
}
