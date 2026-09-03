import axios, { AxiosError, type AxiosInstance } from 'axios'
import { readSession } from '../auth/session'

function applyAuthField(
  merged: Record<string, string>,
  key: string,
  value: string,
) {
  if (!value) return
  const current = merged[key]
  if (current == null || String(current).trim() === '') {
    merged[key] = value
  }
}

/** Mirrors Flutter `withAuthFields` — PHP api_auth.php convention. */
export function withAuthFields(
  body: Record<string, string | number | undefined | null>,
): Record<string, string> {
  const session = readSession()
  const merged: Record<string, string> = {}
  for (const [k, v] of Object.entries(body)) {
    if (v == null) continue
    merged[k] = String(v)
  }
  if (session) {
    applyAuthField(merged, 'token', session.token)
    applyAuthField(merged, 'auth_id_users', session.idUsersApp)
    applyAuthField(merged, 'id_users_app', session.idUsersApp)
  }
  return merged
}

let client: AxiosInstance | null = null

export function getApiClient(): AxiosInstance {
  if (client) return client
  client = axios.create({
    timeout: 20_000,
  })
  client.interceptors.request.use((config) => {
    const session = readSession()
    if (session?.token) {
      config.headers.Authorization = `Bearer ${session.token}`
    }
    return config
  })
  return client
}

/** POST as multipart FormData — same as Flutter Dio FormData.fromMap. */
export async function apiPost(
  url: string,
  body: Record<string, string | number | undefined | null>,
  options?: { attachAuth?: boolean },
): Promise<unknown> {
  const attachAuth = options?.attachAuth !== false
  const payload = attachAuth ? withAuthFields(body) : Object.fromEntries(
    Object.entries(body)
      .filter(([, v]) => v != null)
      .map(([k, v]) => [k, String(v)]),
  )

  const form = new FormData()
  for (const [k, v] of Object.entries(payload)) {
    form.append(k, v)
  }

  const res = await getApiClient().post(url, form)
  return res.data
}

/** POST FormData expecting binary (xlsx export). */
export async function apiPostBytes(
  url: string,
  body: Record<string, string | number | undefined | null>,
  options?: { attachAuth?: boolean; timeoutMs?: number },
): Promise<{ data: ArrayBuffer; contentType: string; contentDisposition: string }> {
  const attachAuth = options?.attachAuth !== false
  const payload = attachAuth
    ? withAuthFields(body)
    : Object.fromEntries(
        Object.entries(body)
          .filter(([, v]) => v != null)
          .map(([k, v]) => [k, String(v)]),
      )

  const form = new FormData()
  for (const [k, v] of Object.entries(payload)) {
    form.append(k, v)
  }

  const res = await getApiClient().post(url, form, {
    responseType: 'arraybuffer',
    timeout: options?.timeoutMs ?? 180_000,
  })

  const contentType = String(res.headers['content-type'] ?? '')
  const contentDisposition = String(res.headers['content-disposition'] ?? '')
  return {
    data: res.data as ArrayBuffer,
    contentType,
    contentDisposition,
  }
}

export function messageForApiError(err: unknown): string {
  if (axios.isAxiosError(err)) {
    return resolveAxiosError(err)
  }
  if (err instanceof Error) {
    const msg = err.message.replace(/^Error:\s*/, '')
    if (msg.startsWith('Server Error:')) return 'Server sedang bermasalah'
    return msg || 'Server sedang bermasalah'
  }
  return 'Server sedang bermasalah'
}

function resolveAxiosError(e: AxiosError): string {
  if (
    e.code === 'ERR_NETWORK' ||
    e.code === 'ECONNABORTED' ||
    e.message.includes('Network Error')
  ) {
    return 'Cek koneksi internet'
  }
  const status = e.response?.status
  if (status === 401 || status === 403) return 'Sesi berakhir, silakan login ulang'
  if (status != null && status >= 500) return 'Server sedang bermasalah'
  return 'Server sedang bermasalah'
}
