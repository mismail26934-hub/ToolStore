'use client'

import type { CSSProperties } from 'react'
import { WORKFLOW_STEP_KEYS } from '@/i18n/messages'
import { computeOrderTimeline } from '@/features/forms/orderTimeline'
import { usePrefs } from '@/prefs/PreferencesContext'
import type {
  FormRow,
  RcvToolRow,
  RcvWhRow,
  SoRow,
  ToolDetailRow,
} from '@/types/models'

const STEPS = 7

export function OrderTimeline({
  form,
  tools,
  so,
  rcvWh,
  rcvTool,
  compact = true,
}: {
  form: FormRow
  tools?: ToolDetailRow[]
  so?: SoRow[]
  rcvWh?: RcvWhRow[]
  rcvTool?: RcvToolRow[]
  /** Compact rail for form cards; full labeled strip when false. */
  compact?: boolean
}) {
  const { t } = usePrefs()
  const vm = computeOrderTimeline(form, { tools, so, rcvWh, rcvTool })
  // redStep from compute is 1-based step number; convert to 0-based index.
  const redIndex = vm.redStep != null ? vm.redStep - 1 : null
  const partialIndex = vm.partialStepIndex
  const partialProgress = vm.partialProgress
  const filled = vm.filled
  const trackThrough =
    redIndex != null
      ? redIndex + 1
      : partialIndex != null
        ? Math.max(filled, partialIndex + 1)
        : filled

  const statusLine =
    filled >= STEPS
      ? t('timelineCompleted')
      : redIndex != null
        ? `${t('timelineStopped')} · ${t(WORKFLOW_STEP_KEYS[redIndex].title)}`
        : partialIndex != null && partialProgress != null
          ? `${t('timelinePartial')}: ${t(WORKFLOW_STEP_KEYS[partialIndex].title)} (${Math.round(partialProgress * 100)}%)`
          : `${t('timelineNext')}: ${t(WORKFLOW_STEP_KEYS[Math.min(filled, STEPS - 1)].title)}`

  return (
    <div className={`timeline-panel${compact ? ' compact' : ''}`}>
      <div className="timeline-rail" aria-hidden>
        {Array.from({ length: STEPS }, (_, i) => {
          const isRed = redIndex === i
          const isPartial = !isRed && partialIndex === i
          const isDone = !isRed && !isPartial && i < filled
          const pct =
            isPartial && partialProgress != null
              ? Math.max(0, Math.min(1, partialProgress))
              : null

          return (
            <div key={i} className="timeline-seg">
              <div
                className={[
                  'timeline-node',
                  isDone ? 'done' : '',
                  isRed ? 'red' : '',
                  isPartial ? 'partial' : '',
                  pct != null ? 'partial-pct' : '',
                ]
                  .filter(Boolean)
                  .join(' ')}
                style={
                  pct != null
                    ? ({ ['--pct' as string]: pct * 100 } as CSSProperties)
                    : undefined
                }
                title={
                  pct != null
                    ? `${t(WORKFLOW_STEP_KEYS[i].title)} (${Math.round(pct * 100)}%)`
                    : t(WORKFLOW_STEP_KEYS[i].title)
                }
              >
                {isRed ? (
                  <span className="timeline-node-icon">×</span>
                ) : isDone ? (
                  <span className="timeline-node-icon">✓</span>
                ) : isPartial && pct != null ? (
                  <span className="timeline-node-pct-label">
                    {Math.round(pct * 100)}%
                  </span>
                ) : isPartial ? (
                  <span className="timeline-node-icon">···</span>
                ) : (
                  <span className="timeline-node-num">{i + 1}</span>
                )}
              </div>
              {i < STEPS - 1 && (
                <div
                  className={`timeline-connector${i < trackThrough ? ' on' : ''}`}
                />
              )}
            </div>
          )
        })}
      </div>

      {!compact && (
        <div className="timeline-labels">
          {WORKFLOW_STEP_KEYS.map((step, i) => {
            const isRed = redIndex === i
            const isPartial = !isRed && partialIndex === i
            const isDone = !isRed && !isPartial && i < filled
            const above = i % 2 === 0
            const pct =
              isPartial && partialProgress != null
                ? Math.round(partialProgress * 100)
                : null
            return (
              <div
                key={step.title}
                className={[
                  'timeline-label-card',
                  above ? 'above' : 'below',
                  isDone ? 'done' : '',
                  isRed ? 'red' : '',
                  isPartial ? 'partial' : '',
                ]
                  .filter(Boolean)
                  .join(' ')}
              >
                <div className="timeline-label-title">{t(step.title)}</div>
                <div className="timeline-label-sub">
                  {isPartial
                    ? pct != null
                      ? `${t('timelinePartial')} · ${pct}%`
                      : t('timelinePartial')
                    : t(step.sub)}
                </div>
              </div>
            )
          })}
        </div>
      )}

      <div className="timeline-status muted">{statusLine}</div>
    </div>
  )
}
