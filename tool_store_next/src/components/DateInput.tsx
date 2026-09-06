'use client'

import { useEffect, useId, useRef, useState } from 'react'
import { dmyToYmd, maskDmyInput, ymdToDmy } from '@/lib/dateFormat'

type Props = {
  value: string
  onChange: (ymd: string) => void
  required?: boolean
  disabled?: boolean
  name?: string
  id?: string
  'aria-label'?: string
}

function CalendarIcon() {
  return (
    <svg
      viewBox="0 0 24 24"
      width="18"
      height="18"
      aria-hidden
      fill="none"
    >
      <path
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
        strokeLinejoin="round"
        d="M7 3v3M17 3v3M4.5 8.5h15M6 6h12a1.5 1.5 0 0 1 1.5 1.5V19a1.5 1.5 0 0 1-1.5 1.5H6A1.5 1.5 0 0 1 4.5 19V7.5A1.5 1.5 0 0 1 6 6Z"
      />
      <path
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
        d="M8.5 13h3M14.5 13h1M8.5 16.5h7"
      />
    </svg>
  )
}

export function DateInput({
  value,
  onChange,
  required,
  disabled,
  name,
  id,
  'aria-label': ariaLabel,
}: Props) {
  const autoId = useId()
  const inputId = id ?? autoId
  const pickerRef = useRef<HTMLInputElement>(null)
  const [text, setText] = useState(() => ymdToDmy(value))

  useEffect(() => {
    setText(ymdToDmy(value))
  }, [value])

  const openPicker = () => {
    const el = pickerRef.current
    if (!el || disabled) return
    try {
      el.showPicker()
    } catch {
      el.click()
    }
  }

  return (
    <div className={`date-input${disabled ? ' is-disabled' : ''}`}>
      <input
        id={inputId}
        type="text"
        className="date-input-text"
        name={name}
        inputMode="numeric"
        autoComplete="off"
        placeholder="dd/mm/yyyy"
        value={text}
        disabled={disabled}
        required={required}
        aria-label={ariaLabel}
        onChange={(e) => {
          const next = maskDmyInput(e.target.value)
          setText(next)
          const ymd = dmyToYmd(next)
          if (ymd) onChange(ymd)
        }}
        onBlur={() => {
          const ymd = dmyToYmd(text)
          if (ymd) {
            onChange(ymd)
            setText(ymdToDmy(ymd))
            return
          }
          setText(ymdToDmy(value))
        }}
      />
      <button
        type="button"
        className="date-input-icon"
        disabled={disabled}
        tabIndex={-1}
        aria-label="Open calendar"
        onClick={openPicker}
      >
        <CalendarIcon />
      </button>
      <input
        ref={pickerRef}
        type="date"
        className="date-input-native"
        value={value || ''}
        disabled={disabled}
        tabIndex={-1}
        aria-hidden
        onChange={(e) => {
          const ymd = e.target.value
          onChange(ymd)
          setText(ymdToDmy(ymd))
        }}
      />
    </div>
  )
}
