'use client'

import { useEffect, useMemo, useRef, useState, type FormEvent } from 'react'
import Link from 'next/link'
import { useRouter, useSearchParams } from 'next/navigation'
import { useAuth } from '@/auth/AuthContext'
import { canAddOrEditForm } from '@/auth/roles'
import { FORM_INBOX_FETCH_LIMIT, FORM_PAGE_SIZE } from '@/api/params'
import { DateFilterModal } from '@/components/DateFilterModal'
import { ExcelExportModal } from '@/components/ExcelExportModal'
import { FormApprovalSection } from '@/components/FormApprovalSection'
import { OrderTimeline } from '@/components/OrderTimeline'
import { PageHeader } from '@/components/PageHeader'
import { SearchTextInput, ClearIcon } from '@/components/SearchTextInput'
import { Pagination } from '@/components/Pagination'
import {
  EmptyState,
  ListShimmer,
  LoadingSpinner,
} from '@/components/ListStates'
import { ToolRelatedSections } from '@/components/ToolRelatedSections'
import { usePrefs } from '@/prefs/PreferencesContext'
import { formatDateDisplay } from '@/lib/dateFormat'
import { resolveFormIdByFormNo } from '@/features/forms/exportApi'
import {
  inboxTitle,
  matchesInboxFilter,
  needsInboxFetchLimit,
  resolveInboxMode,
} from '@/features/forms/formInbox'
import { useFormsList } from '@/features/forms/useForms'
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
              <div>{formatDateDisplay(form.fromDateUpdate)}</div>
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
  const { t } = usePrefs()
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
  const [searchOpen, setSearchOpen] = useState(() => !!params.get('q')?.trim())
  const [expandedId, setExpandedId] = useState<string | null>(
    params.get('expand'),
  )
  const [exportOpen, setExportOpen] = useState(false)
  const [dateFilterOpen, setDateFilterOpen] = useState(false)
  const [actionsOpen, setActionsOpen] = useState(false)
  const [deepLinkError, setDeepLinkError] = useState<string | null>(null)
  const actionsRef = useRef<HTMLDivElement>(null)
  const searchInputRef = useRef<HTMLInputElement>(null)

  const hasActiveSearch = !!(params.get('q')?.trim())

  useEffect(() => {
    if (!searchOpen) return
    const id = window.setTimeout(() => searchInputRef.current?.focus(), 50)
    return () => window.clearTimeout(id)
  }, [searchOpen])

  useEffect(() => {
    if (!actionsOpen) return
    const onDoc = (e: MouseEvent) => {
      if (!actionsRef.current?.contains(e.target as Node)) setActionsOpen(false)
    }
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') setActionsOpen(false)
    }
    document.addEventListener('mousedown', onDoc)
    document.addEventListener('keydown', onKey)
    return () => {
      document.removeEventListener('mousedown', onDoc)
      document.removeEventListener('keydown', onKey)
    }
  }, [actionsOpen])

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

  const page = Math.max(1, Number(params.get('page') || '1') || 1)
  const pageSize = FORM_PAGE_SIZE

  const filters = useMemo(
    () => ({
      keyword: params.get('q') ?? '',
      searchField: params.get('field') ?? 'all',
      inbox: inbox ?? 'active',
      milestones: milestonesParam ?? '',
      milestone: legacyMilestone ?? '',
      fromDateUpdate: fromDate,
      toDateUpdate: toDate || fromDate,
      page: largeFetch ? 1 : page,
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
      page,
    ],
  )

  const query = useFormsList(filters)
  const matchedForms = useMemo(() => {
    const raw = query.data?.items ?? []
    return raw.filter((f) => matchesInboxFilter(f, mode))
  }, [query.data, mode])

  const totalItems = largeFetch
    ? matchedForms.length
    : (query.data?.total ?? matchedForms.length)
  const totalPages = Math.max(1, Math.ceil(totalItems / pageSize))
  const safePage = Math.min(page, totalPages)

  const forms = useMemo(() => {
    if (!largeFetch) return matchedForms
    const start = (safePage - 1) * pageSize
    return matchedForms.slice(start, start + pageSize)
  }, [largeFetch, matchedForms, safePage, pageSize])

  const searchResultCount =
    largeFetch
      ? matchedForms.length
      : (query.data?.total ?? (query.isLoading ? null : matchedForms.length))

  const replaceParams = (mutate: (next: URLSearchParams) => void) => {
    const next = new URLSearchParams(params.toString())
    mutate(next)
    router.replace(`/forms?${next.toString()}`)
  }

  const setPage = (nextPage: number) => {
    replaceParams((next) => {
      if (nextPage <= 1) next.delete('page')
      else next.set('page', String(nextPage))
    })
  }

  const onSearch = (e: FormEvent) => {
    e.preventDefault()
    if (!keyword.trim()) return
    replaceParams((next) => {
      next.delete('form_no')
      next.set('q', keyword.trim())
      next.set('field', searchField)
      next.delete('page')
    })
  }

  const clearSearch = () => {
    setKeyword('')
    setSearchField('all')
    replaceParams((next) => {
      next.delete('form_no')
      next.delete('q')
      next.delete('field')
      next.delete('page')
    })
  }

  const applyDateFilter = (from: string, to: string) => {
    replaceParams((next) => {
      next.set('from', from)
      next.set('to', to)
      next.delete('page')
    })
  }

  const clearDateFilter = () => {
    replaceParams((next) => {
      next.delete('from')
      next.delete('to')
      next.delete('page')
    })
  }

  const formsSubtitle =
    (mode.type === 'active'
      ? 'Active forms (excludes completed / hold / rejected)'
      : mode.type === 'blank'
        ? 'Draft forms only'
        : mode.type === 'all'
          ? 'All forms'
          : `Milestone filter · ${forms.length} shown`) +
    (hasDateFilter
      ? ` · Updated ${formatDateDisplay(fromDate)}${toDate && toDate !== fromDate ? ` → ${formatDateDisplay(toDate)}` : ''}`
      : '')

  return (
    <div className="page">
      <PageHeader title={title} subtitle={formsSubtitle}>
        <button
          type="button"
          className={`btn btn-ghost btn-with-icon${searchOpen || hasActiveSearch ? ' btn-filter-active' : ''}`}
          title={t('search')}
          aria-label={t('search')}
          aria-expanded={searchOpen}
          aria-pressed={searchOpen}
          onClick={() => setSearchOpen((v) => !v)}
        >
          <svg
            className="btn-icon-svg"
            viewBox="0 0 24 24"
            width="18"
            height="18"
            aria-hidden
            fill="none"
          >
            <circle
              cx="11"
              cy="11"
              r="6.5"
              stroke="currentColor"
              strokeWidth="1.8"
            />
            <path
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              d="m16.2 16.2 3.3 3.3"
            />
          </svg>
          <span className="btn-label">{t('search')}</span>
        </button>
        <div
          className={`nav-manage page-actions-menu${actionsOpen ? ' is-open' : ''}${hasDateFilter ? ' has-filter' : ''}`}
          ref={actionsRef}
        >
          <button
            type="button"
            className={`btn btn-ghost btn-with-icon page-actions-trigger${hasDateFilter ? ' btn-filter-active' : ''}`}
            aria-expanded={actionsOpen}
            aria-haspopup="menu"
            title={t('actions')}
            aria-label={t('actions')}
            onClick={() => setActionsOpen((v) => !v)}
          >
            <svg
              className="btn-icon-svg"
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
                d="M4 7h11M4 12h11M4 17h7"
              />
              <path
                stroke="currentColor"
                strokeWidth="1.8"
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M18.5 5.5v5M16 8h5"
              />
              <path
                stroke="currentColor"
                strokeWidth="1.8"
                strokeLinecap="round"
                strokeLinejoin="round"
                d="m15.5 16.2 2.3 2.3 4-4"
              />
            </svg>
            <span className="btn-label">{t('actions')}</span>
            <span className="nav-manage-caret btn-label" aria-hidden>
              ▾
            </span>
          </button>
          {actionsOpen && (
            <div className="nav-manage-menu page-actions-dropdown" role="menu">
              <button
                type="button"
                role="menuitem"
                className={`nav-manage-item btn-with-icon${hasDateFilter ? ' is-active' : ''}`}
                onClick={() => {
                  setActionsOpen(false)
                  setDateFilterOpen(true)
                }}
              >
                <svg
                  className="btn-icon-svg"
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
                <span>
                  {hasDateFilter ? t('changeDates') : t('filterDates')}
                </span>
              </button>
              <button
                type="button"
                role="menuitem"
                className="nav-manage-item btn-with-icon"
                onClick={() => {
                  setActionsOpen(false)
                  setExportOpen(true)
                }}
              >
                <svg
                  className="btn-icon-svg"
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
                    d="M8 3.5h5.5L18 8v12.5a1 1 0 0 1-1 1H8a1 1 0 0 1-1-1V4.5a1 1 0 0 1 1-1Z"
                  />
                  <path
                    stroke="currentColor"
                    strokeWidth="1.8"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M13.5 3.5V8H18M9.2 13.2 11.5 16l2.3-2.8M9.2 18.5h4.6"
                  />
                </svg>
                <span>{t('exportExcel')}</span>
              </button>
            </div>
          )}
        </div>
        {canEdit && (
          <Link
            className="btn btn-secondary btn-with-icon"
            href="/forms/new"
            title={t('addForm')}
            aria-label={t('addForm')}
          >
            <svg
              className="btn-icon-svg"
              viewBox="0 0 24 24"
              width="18"
              height="18"
              aria-hidden
              fill="none"
            >
              <path
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                d="M12 5v14M5 12h14"
              />
            </svg>
            <span className="btn-label">{t('addForm')}</span>
          </Link>
        )}
      </PageHeader>

      {hasDateFilter && (
        <div className="filter-chip-row">
          <span className="chip chip-filter">
            Date update: {formatDateDisplay(fromDate)}
            {toDate && toDate !== fromDate
              ? ` → ${formatDateDisplay(toDate)}`
              : ''}
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

      {hasActiveSearch && (
        <div className="filter-chip-row">
          <span className="chip chip-filter">
            {t('search')}: {params.get('q')}
            {params.get('field') && params.get('field') !== 'all'
              ? ` · ${params.get('field')}`
              : ''}
            {searchResultCount != null
              ? ` · ${t('dataCount').replace('{n}', String(searchResultCount))}`
              : query.isFetching
                ? ' · …'
                : ''}
            <ClearIcon
              label={t('clearSearch')}
              onClick={clearSearch}
              className="chip-clear-icon"
            />
          </span>
        </div>
      )}

      {searchOpen && (
        <form className="toolbar" onSubmit={onSearch}>
          <select
            value={searchField}
            onChange={(e) => setSearchField(e.target.value)}
            aria-label="Search field"
          >
            <option value="all">All fields</option>
            <option value="formNo">Form No</option>
            <option value="serviceman">Serviceman</option>
            <option value="status">Status</option>
            <option value="idForm">ID Form</option>
            <option value="pnGroup">PN Group</option>
            <option value="pnDesc">Description</option>
          </select>
          <SearchTextInput
            ref={searchInputRef}
            placeholder="Search…"
            value={keyword}
            onChange={(e) => setKeyword(e.target.value)}
            aria-label={t('search')}
            required
            clearLabel={t('clearSearch')}
            onClear={clearSearch}
            showClear={!!keyword || hasActiveSearch}
          />
          <button
            type="submit"
            className="btn btn-primary"
            disabled={!keyword.trim()}
          >
            {t('search')}
          </button>
        </form>
      )}

      {deepLinkError && <div className="alert alert-error">{deepLinkError}</div>}
      {query.isLoading && (
        <div className="stack">
          <LoadingSpinner label={t('loading')} />
          <ListShimmer rows={4} />
        </div>
      )}
      {query.isError && (
        <div className="alert alert-error">
          {(query.error as Error)?.message}
        </div>
      )}

      {!query.isLoading && !query.isError && forms.length === 0 && (
        <EmptyState message={t('noData')} />
      )}

      {!query.isLoading && !query.isError && forms.length > 0 && (
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
      )}

      <Pagination
        page={safePage}
        totalPages={totalPages}
        totalItems={totalItems}
        pageSize={pageSize}
        onPageChange={setPage}
        disabled={query.isFetching}
      />

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
