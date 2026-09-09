'use server'

import { ApiParam } from '@/api/params'
import {
  canAccessSuperiorApproval,
  canAddOrEditForm,
  formContentDeniedMessage,
} from '@/auth/roles'
import {
  dbDashboardCounts,
  dbExportFormDetails,
  dbGetFormById,
  dbListForms,
  dbMutateForm,
} from '@/db/forms'
import { dbGetUserById } from '@/db/usersRepo'
import { notifyFormMilestoneChange } from '@/features/forms/notifyMilestone'
import { normFormMilestone } from '@/features/forms/formMilestones'
import type { FormListFilters, SaveFormInput } from '@/features/forms/types'
import type { DashboardCounts, FormRow, PaginatedList } from '@/types/models'

function isSuperiorDecisionMilestone(milestone: string): boolean {
  const n = normFormMilestone(milestone)
  return n === 'SUPERIOR APPROVED' || n === 'REJECTED BY SUPERIOR'
}

async function actorFromUserId(userId?: string) {
  const id = (userId ?? '').trim()
  if (!id) return null
  const row = await dbGetUserById(id)
  return row ? { level: row.level } : null
}

function dateKey(value?: string) {
  return (value ?? '').trim().slice(0, 10)
}

function headerFieldsChanged(prev: FormRow, input: SaveFormInput) {
  const n = (v?: string) => (v ?? '').trim()
  return (
    n(input.formNo) !== n(prev.formNo) ||
    n(input.formServName) !== n(prev.formServName) ||
    n(input.formCheckBy) !== n(prev.formCheckBy) ||
    dateKey(input.formDateCheckBy) !== dateKey(prev.formDateCheckBy) ||
    dateKey(input.formDateServName) !== dateKey(prev.formDateServName) ||
    n(input.formServComment) !== n(prev.formServComment) ||
    n(input.formStatusOrder) !== n(prev.formStatusOrder)
  )
}

async function assertFormContentAllowed(
  userId: string | undefined,
  milestone: string | null | undefined,
) {
  const actor = await actorFromUserId(userId)
  const denied = formContentDeniedMessage(actor, milestone)
  if (denied) throw new Error(denied)
}

async function assertSuperiorDecisionAllowed(
  prev: FormRow,
  input: SaveFormInput,
): Promise<void> {
  const next = input.formMilestone ?? ''
  if (!isSuperiorDecisionMilestone(next)) return
  if (normFormMilestone(prev.formMilestone) === normFormMilestone(next)) return

  const actorId = (input.formUserUpdate ?? '').trim()
  const actor = actorId ? await dbGetUserById(actorId) : null
  const allowed = canAccessSuperiorApproval(
    actor
      ? { idUsersApp: actor.idUsers, level: actor.level }
      : null,
    prev,
  )
  if (!allowed) {
    throw new Error(
      'Hanya Super Admin atau superior serviceman yang boleh approve / reject order ini',
    )
  }
}

export async function fetchForms(
  filters: FormListFilters = {},
): Promise<PaginatedList<FormRow>> {
  try {
    return await dbListForms(filters)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal memuat forms')
  }
}

export async function fetchFormById(idForm: string): Promise<FormRow | null> {
  try {
    return await dbGetFormById(idForm)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal memuat form')
  }
}

export async function fetchDashboardCounts(): Promise<DashboardCounts> {
  try {
    return await dbDashboardCounts()
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal memuat dashboard')
  }
}

export async function mutateForm(input: SaveFormInput): Promise<string> {
  try {
    const actorId = input.formUserUpdate
    if (input.param === ApiParam.addForm) {
      const actor = await actorFromUserId(actorId)
      if (!canAddOrEditForm(actor)) {
        throw new Error(
          'Hanya Super Admin atau Tool Keeper yang boleh mengubah form / tool item',
        )
      }
    }

    let prevMilestone = ''
    if (
      (input.param === ApiParam.editForm ||
        input.param === ApiParam.deleteForm) &&
      input.idForm?.trim()
    ) {
      const prev = await dbGetFormById(input.idForm)
      prevMilestone = prev?.formMilestone ?? ''
      if (input.param === ApiParam.deleteForm && prev) {
        await assertFormContentAllowed(actorId, prev.formMilestone)
      }
      if (input.param === ApiParam.editForm && prev) {
        await assertSuperiorDecisionAllowed(prev, input)
        if (headerFieldsChanged(prev, input)) {
          await assertFormContentAllowed(actorId, prev.formMilestone)
        }
      }
    }
    const msg = await dbMutateForm(input)
    if (input.param === ApiParam.editForm && input.idForm?.trim()) {
      try {
        await notifyFormMilestoneChange({
          idForm: input.idForm,
          prevMilestone,
          nextMilestone: input.formMilestone ?? '',
          formNo: input.formNo,
          formServName: input.formServName,
        })
      } catch (notifyErr) {
        console.error('[whacenter] notify failed', notifyErr)
      }
    }
    return msg
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal menyimpan form')
  }
}

export async function exportFormDetailRows(input: {
  idForm?: string
  fromDateUpdate?: string
  toDateUpdate?: string
}): Promise<Array<Record<string, string>>> {
  try {
    return await dbExportFormDetails(input)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal export')
  }
}
