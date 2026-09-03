/** API path segments — mirrors Flutter `lib/controller/api_url/api.dart`. */

const envBase = process.env.NEXT_PUBLIC_API_BASE?.trim()

/**
 * In the browser we call same-origin `/api_tool/...` (Next.js rewrites).
 * On the server, use the absolute backend URL.
 */
export function getApiBase(): string {
  if (typeof window !== 'undefined') return '/'
  if (!envBase) return '/'
  return envBase.endsWith('/') ? envBase : `${envBase}/`
}

const API = 'api_tool/api_toolstore/v1'

export const ApiUrl = {
  login: () => `${getApiBase()}${API}/auth/login`,
  user: () => `${getApiBase()}${API}/user`,
  form: () => `${getApiBase()}${API}/form`,
  formDetail: () => `${getApiBase()}${API}/form/detail`,
  formDetailExport: () => `${getApiBase()}${API}/form/detail/export`,
  po: () => `${getApiBase()}${API}/po`,
  so: () => `${getApiBase()}${API}/so`,
  superior: () => `${getApiBase()}${API}/superior`,
  rcvWh: () => `${getApiBase()}${API}/receive/wh`,
  rcvTool: () => `${getApiBase()}${API}/receive/tool`,
  fcm: () => `${getApiBase()}${API}/device/fcm`,
} as const
