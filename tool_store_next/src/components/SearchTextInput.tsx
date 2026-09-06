'use client'

import { forwardRef, type InputHTMLAttributes } from 'react'

export function ClearIcon({
  label,
  onClick,
  className = 'search-clear-icon',
}: {
  label: string
  onClick: () => void
  className?: string
}) {
  return (
    <button
      type="button"
      className={className}
      aria-label={label}
      title={label}
      onClick={(e) => {
        e.preventDefault()
        e.stopPropagation()
        onClick()
      }}
    >
      <svg viewBox="0 0 24 24" width="16" height="16" aria-hidden fill="none">
        <path
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          d="M7 7l10 10M17 7 7 17"
        />
      </svg>
    </button>
  )
}

type Props = Omit<InputHTMLAttributes<HTMLInputElement>, 'type'> & {
  clearLabel: string
  onClear: () => void
  showClear?: boolean
}

export const SearchTextInput = forwardRef<HTMLInputElement, Props>(
  function SearchTextInput(
    { clearLabel, onClear, showClear, className, value, ...rest },
    ref,
  ) {
    const hasValue = String(value ?? '').length > 0
    const visible = showClear ?? hasValue

    return (
      <div className={`search-input-wrap${className ? ` ${className}` : ''}`}>
        <input
          ref={ref}
          type="text"
          className="search-input-field"
          value={value}
          {...rest}
        />
        {visible && <ClearIcon label={clearLabel} onClick={onClear} />}
      </div>
    )
  },
)
