import { randomUUID } from 'crypto'

export function newId(): string {
  return randomUUID()
}

export function emptyToNull(value?: string | null): string | null {
  const v = (value ?? '').trim()
  return v === '' ? null : v
}

export function s(value: unknown, fallback = ''): string {
  if (value == null) return fallback
  if (value instanceof Date) {
    return value.toISOString().slice(0, 10)
  }
  return String(value)
}
