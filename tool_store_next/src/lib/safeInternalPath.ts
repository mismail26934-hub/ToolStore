/** Allow only same-origin relative paths (blocks open redirects). */
export function safeInternalPath(
  raw: string | null | undefined,
  fallback = '/dashboard',
): string {
  const v = (raw ?? '').trim()
  if (!v.startsWith('/') || v.startsWith('//') || v.includes('\\')) {
    return fallback
  }
  return v
}
