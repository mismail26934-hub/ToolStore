'use client'

import { ACTION_NOTE_OPTIONS, normalizeActionNoteCode } from '@/lib/actionNotes'

type Props = {
  value: string
  onChange: (code: string) => void
  required?: boolean
  disabled?: boolean
}

export function ActionNoteField({
  value,
  onChange,
  required,
  disabled,
}: Props) {
  const code = normalizeActionNoteCode(value)

  return (
    <label className="field">
      <span>ACTION NOTE</span>
      <select
        value={code}
        onChange={(e) => onChange(e.target.value)}
        required={required}
        disabled={disabled}
      >
        <option value="">Select…</option>
        {ACTION_NOTE_OPTIONS.map((opt) => (
          <option key={opt.value} value={opt.value}>
            {opt.label}
          </option>
        ))}
      </select>
    </label>
  )
}
