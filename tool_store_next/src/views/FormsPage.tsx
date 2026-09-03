'use client'

import { useEffect, useMemo, useState, type FormEvent } from 'react'
import Link from 'next/link'
import { useRouter, useSearchParams } from 'next/navigation'
import { useAuth } from '@/auth/AuthContext'
import { canAddOrEditForm } from '@/auth/roles'
import { FORM_INBOX_FETCH_LIMIT, FORM_PAGE_SIZE } from '@/api/params'
import { DateFilterModal } from '@/components/DateFilterModal'
import { ExcelExportModal } from '@/components/ExcelExportModal'
import { FormApprovalSection } from '@/components/FormApprovalSection'
import { OrderTimeline } from '@/components/OrderTimeline'
import { ToolRelatedSections } from '@/components/ToolRelatedSections'
import { resolveFormIdByFormNo } from '@/features/forms/exportApi'
import {
  inboxTitle,
  matchesInboxFilter,
  needsInboxFetchLimit,
  resolveInboxMode,
} from '@/features/forms/formInbox'
import { useFormsInfinite } from '@/features/forms/useForms'
import { useFormRelated, useRelatedMutations } from '@/features/related/useRelated'
import { useToolDetails } from '@/features/tools/useToolDetails'
import type { FormRow } from '@/types/models'

function FormCard({
  form,
  expanded,
  onToggle,
  canEditForm,
}: {
  form: FormRow
  expanded: boolean
  onToggle: () => void
  canEditForm: boolean
}) {
  const details = useToolDetails(form.idForm, expanded)
  const related = useFormRelated(form.idForm, expanded)
  const mut = useRelatedMutations(form.idForm)
  const hasTools = (details.data?.length ?? 0) > 0

  return (
    <article className="form-card">
      <button type="button" className="form-card-head" onClick={onToggle}>
        <div className="form-card-head-main">
          <div className="form-card-title-row">
            <div className="form-card-title">{form.formNo || '—'}</div>
            <span className="chip">{form.formStatusOrder || '—'}</span>
          </div>
          <div className="muted">
            {form.formServName || 'No serviceman'} · {form.formMilestone || '—'}
          </div>
          <OrderTimeline
            form={form}
            compact={!expanded}
            tools={expanded ? details.data : undefined}
            rcvWh={expanded ? related.rcvWh.data : undefined}
            rcvTool={expanded ? related.rcvTool.data : undefined}
          />
        </div>
      </button>

      {expanded && (
        <div className="form-card-body">
          <div className="meta-grid">
            <div>
              <span className="muted">ID Form</span>
              <div>{form.idForm}</div>
            </div>
            <div>
              <span className="muted">Updated</span>
              <div>{form.fromDateUpdate || '—'}</div>
            </div>
          </div>

          {canEditForm && (
            <div className="section-title-row">
              <h3>Request</h3>
              <Link
                className="btn btn-secondary btn-sm"
                href={`/forms/${form.idForm}/edit`}
              >
                Edit request
              </Link>
            </div>
          )}

          <FormApprovalSection form={form} hasTools={hasTools} />

          <div className="section-title-row">
            <h3>Tool items</h3>
            <Link
              className="btn btn-primary btn-sm"
              href={`/forms/${form.idForm}/tools/new`}
            >
              + Add item
            </Link>
          </div>

          {details.isLoading && <p className="muted">Loading items…</p>}
          {details.isError && (
            <div className="alert alert-error">
              {(details.error as Error)?.message}
            </div>
          )}
          {details.data && details.data.length === 0 && (
            <p className="muted">Belum ada tool item.</p>
          )}
          {details.data && details.data.length > 0 && (
            <ul className="tool-list">
              {details.data.map((row) => (
                <li key={row.idFormDetail || `${row.pnGroup}-${row.pnDesc}`}>
                  <div className="tool-item-block">
                    <Link href={`/forms/${form.idForm}/tools/${row.idFormDetail}`}>
                      <strong>{row.pnGroup || '—'}</strong>
                      <span className="muted">
                        {' '}
                        · qty {row.qty || '0'} · {row.pnDesc || ''}
                      </span>
                    </Link>
                    <ToolRelatedSections
                      tool={row}
                      related={related}
                      mut={mut}
                    />
                  </div>
                </li>
              ))}
            </ul>
          )}
        </div>
      )}
    </article>
  )
}

export function FormsPage() {
  const { user } = useAuth()
  const canEdit = canAddOrEditForm(user)
  const router = useRouter()
  const params = useSearchParams()
  const inbox = params.get('inbox')
  const milestonesParam = params.get('milestones')
  const legacyMilestone = params.get('milestone')
  const fromDate = params.get('from') ?? ''
  const toDate = params.get('to') ?? ''
  const hasDateFilter = !!fromDate.trim()

  const mode = useMemo(
    () => resolveInboxMode(inbox, milestonesParam, legacyMilestone),
    [inbox, milestonesParam, legacyMilestone],
  )
  const title = useMemo(
    () => inboxTitle(inbox, milestonesParam, legacyMilestone),
    [inbox, milestonesParam, legacyMilestone],
  )
  const largeFetch = needsInboxFetchLimit(mode)

  const [keyword, setKeyword] = useState(params.get('q') ?? '')
  const [searchField, setSearchField] = useState(params.get('field') ?? 'all')
  const [expandedId, setExpandedId] = useState<string | null>(
    params.get('expand'),
  )
  const [exportOpen, setExportOpen] = useState(false)
  const [dateFilterOpen, setDateFilterOpen] = useState(false)
  const [deepLinkError, setDeepLinkError] = useState<string | null>(null)

  useEffect(() => {
    const formNo = params.get('form_no')?.trim()
    if (!formNo) return
    let cancelled = false
    ;(async () => {
      try {
        const id = await resolveFormIdByFormNo(formNo)
        if (cancelled) return
        if (!id) {
          setDeepLinkError(`Form No "${formNo}" tidak ditemukan`)
          return
        }
        const next = new URLSearchParams()
        next.set('q', formNo)
        next.set('field', 'formNo')
        next.set('expand', id)
        next.set('inbox', 'all')
        setKeyword(formNo)
        setSearchField('formNo')
        setExpandedId(id)
        router.replace(`/forms?${next.toString()}`)
      } catch (e) {
        if (!cancelled) setDeepLinkError((e as Error).message)
      }
    })()
    return () => {
      cancelled = true
    }
  }, [params, router])

  const filters = useMemo(
    () => ({
      keyword: params.get('q') ?? '',
      searchField: params.get('field') ?? 'all',
      inbox: inbox ?? 'active',
      milestones: milestonesParam ?? '',
      milestone: legacyMilestone ?? '',
      fromDateUpdate: fromDate,
      toDateUpdate: toDate || fromDate,
      limit: largeFetch ? FORM_INBOX_FETCH_LIMIT : FORM_PAGE_SIZE,
      clientFilter: true as const,
    }),
    [
      params,
      inbox,
      milestonesParam,
      legacyMilestone,
      fromDate,
      toDate,
      largeFetch,
    ],
  )

  const query = useFormsInfinite(filters)
  const forms = useMemo(() => {
    const raw = query.data?.pages.flatMap((p) => p.items) ?? []
    return raw.filter((f) => matchesInboxFilter(f, mode))
  }, [query.data, mode])

  const replaceParams = (mutate: (next: URLSearchParams) => void) => {
    const next = new URLSearchParams(params.toString())
    mutate(next)
    router.replace(`/forms?${next.toString()}`)
  }

  const onSearch = (e: FormEvent) => {
    e.preventDefault()
    replaceParams((next) => {
      next.delete('form_no')
      if (keyword.trim()) next.set('q', keyword.trim())
      else next.delete('q')
      next.set('field', searchField)
    })
  }

  const applyDateFilter = (from: string, to: string) => {
    replaceParams((next) => {
      next.set('from', from)
      next.set('to', to)
    })
  }

  const clearDateFilter = () => {
    replaceParams((next) => {
      next.delete('from')
      next.delete('to')
    })
  }

  const isDefaultActive =
    mode.type === 'active' &&
    !legacyMilestone &&
    !milestonesParam &&
    (!inbox || inbox === 'active')

  return (
    <div className="page">
      <header className="page-header">
        <div>
          <h1>{title}</h1>
          <p className="muted">
            {mode.type === 'active'
              ? 'Active forms (excludes completed / hold / rejected)'
              : mode.type === 'blank'
                ? 'Draft forms only'
                : mode.type === 'all'
                  ? 'All forms'
                  : `Milestone filter · ${forms.length} shown`}
            {hasDateFilter
              ? ` · Updated ${fromDate}${toDate && toDate !== fromDate ? ` → ${toDate}` : ''}`
              : ''}
          </p>
        </div>
        <div className="page-header-actions">
          <button
            type="button"
            className={`btn btn-ghost${hasDateFilter ? ' btn-filter-active' : ''}`}
            onClick={() => setDateFilterOpen(true)}
          >
            {hasDateFilter ? 'Change dates' : 'Filter dates'}
          </button>
          <button
            type="button"
            className="btn btn-ghost"
            onClick={() => setExportOpen(true)}
          >
            Export Excel
          </button>
          {canEdit && (
            <Link className="btn btn-secondary" href="/forms/new">
              + Add form
            </Link>
          )}
          {!isDefaultActive && (
            <Link className="btn btn-ghost" href="/forms">
              Clear inbox
            </Link>
          )}
        </div>
      </header>

      {hasDateFilter && (
        <div className="filter-chip-row">
          <span className="chip chip-filter">
            Date update: {fromDate}
            {toDate && toDate !== fromDate ? ` → ${toDate}` : ''}
          </span>
          <button
            type="button"
            className="btn btn-ghost btn-sm"
            onClick={clearDateFilter}
          >
            Clear dates
          </button>
        </div>
      )}

      <form className="toolbar" onSubmit={onSearch}>
        <select
          value={searchField}
          onChange={(e) => setSearchField(e.target.value)}
        >
          <option value="all">All fields</option>
          <option value="formNo">Form No</option>
          <option value="serviceman">Serviceman</option>
          <option value="status">Status</option>
          <option value="idForm">ID Form</option>
          <option value="pnGroup">PN Group</option>
          <option value="pnDesc">Description</option>
        </select>
        <input
          placeholder="Search…"
          value={keyword}
          onChange={(e) => setKeyword(e.target.value)}
        />
        <button type="submit" className="btn btn-primary">
          Search
        </button>
      </form>

      {deepLinkError && <div className="alert alert-error">{deepLinkError}</div>}
      {query.isLoading && <div className="panel">Loading forms…</div>}
      {query.isError && (
        <div className="alert alert-error">
          {(query.error as Error)?.message}
        </div>
      )}

      {!query.isLoading && !query.isError && forms.length === 0 && (
        <div className="panel muted">No forms match this filter.</div>
      )}

      <div className="stack">
        {forms.map((form) => (
          <FormCard
            key={form.idForm}
            form={form}
            expanded={expandedId === form.idForm}
            canEditForm={canEdit}
            onToggle={() =>
              setExpandedId((id) => (id === form.idForm ? null : form.idForm))
            }
          />
        ))}
      </div>

      {query.hasNextPage && (
        <div className="center-row">
          <button
            type="button"
            className="btn btn-secondary"
            disabled={query.isFetchingNextPage}
            onClick={() => query.fetchNextPage()}
          >
            {query.isFetchingNextPage ? 'Loading…' : 'Load more'}
          </button>
        </div>
      )}

      <ExcelExportModal open={exportOpen} onClose={() => setExportOpen(false)} />
      <DateFilterModal
        open={dateFilterOpen}
        onClose={() => setDateFilterOpen(false)}
        initialFrom={fromDate}
        initialTo={toDate}
        showClear={hasDateFilter}
        onApply={applyDateFilter}
        onClear={clearDateFilter}
      />
    </div>
  )
}
