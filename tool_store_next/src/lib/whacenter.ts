/** Whacenter WhatsApp gateway — server-only. */

const DEFAULT_SEND_URL = 'https://app.whacenter.com/api/send'

export function isWhacenterEnabled() {
  const flag = process.env.WHACENTER_ENABLED?.trim().toLowerCase()
  if (flag === '0' || flag === 'false' || flag === 'no') return false
  return Boolean(process.env.WHACENTER_DEVICE_ID?.trim())
}

/** Normalize ID mobile numbers to 62xxxxxxxxxxx for Whacenter. */
export function normalizeWaNumber(raw: string | null | undefined): string | null {
  let n = (raw ?? '').trim().replace(/[^\d+]/g, '')
  if (!n) return null
  if (n.startsWith('+')) n = n.slice(1)
  if (n.startsWith('0')) n = `62${n.slice(1)}`
  else if (n.startsWith('8')) n = `62${n}`
  if (!n.startsWith('62')) return null
  if (n.length < 11 || n.length > 15) return null
  return n
}

export async function sendWhacenterMessage(input: {
  number: string
  message: string
}): Promise<{ ok: boolean; error?: string }> {
  const deviceId = process.env.WHACENTER_DEVICE_ID?.trim() ?? ''
  if (!deviceId) return { ok: false, error: 'WHACENTER_DEVICE_ID kosong' }

  const number = normalizeWaNumber(input.number)
  if (!number) return { ok: false, error: `Nomor tidak valid: ${input.number}` }

  const url = process.env.WHACENTER_API_URL?.trim() || DEFAULT_SEND_URL
  const body = new URLSearchParams({
    device_id: deviceId,
    number,
    message: input.message,
  })

  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body,
      signal: AbortSignal.timeout(15_000),
    })
    const json = (await res.json().catch(() => null)) as {
      status?: boolean
      message?: string
    } | null
    if (!res.ok || !json?.status) {
      return {
        ok: false,
        error: json?.message || `HTTP ${res.status}`,
      }
    }
    return { ok: true }
  } catch (e) {
    return {
      ok: false,
      error: e instanceof Error ? e.message : 'Gagal kirim Whacenter',
    }
  }
}
