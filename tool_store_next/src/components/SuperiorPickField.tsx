'use client'

import { ClearIcon } from '@/components/SearchTextInput'

type Props = {
  value: string
  placeholder?: string
  clearLabel?: string
  showClear?: boolean
  onOpen: () => void
  onClear: () => void
}

export function SuperiorPickField({
  value,
  placeholder = 'Pilih superior…',
  clearLabel = 'Clear',
  showClear,
  onOpen,
  onClear,
}: Props) {
  const visibleClear = showClear ?? !!value.trim()

  return (
    <div className="search-input-wrap picker-input-wrap">
      <input
        type="text"
        className="search-input-field picker-input-field"
        value={value}
        readOnly
        placeholder={placeholder}
        onClick={onOpen}
        onKeyDown={(e) => {
          if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault()
            onOpen()
          }
        }}
        role="button"
        aria-haspopup="dialog"
        aria-label={placeholder}
      />
      {visibleClear && <ClearIcon label={clearLabel} onClick={onClear} />}
    </div>
  )
}
