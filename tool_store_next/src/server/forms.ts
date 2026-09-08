'use server'

import { ApiParam } from '@/api/params'
import {
  dbDashboardCounts,
  dbExportFormDetails,
  dbGetFormById,
  dbListForms,
  dbMutateForm,
} from '@/db/forms'
import { notifyFormMilestoneChange } from '@/features/forms/notifyMilestone'
import type { FormListFilters, SaveFormInput } from '@/features/forms/types'
import type { DashboardCounts, FormRow, PaginatedList } from '@/types/models'

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
    let prevMilestone = ''
    if (input.param === ApiParam.editForm && input.idForm?.trim()) {
      const prev = await dbGetFormById(input.idForm)
      prevMilestone = prev?.formMilestone ?? ''
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
