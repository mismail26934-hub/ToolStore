'use server'

import {
  dbDashboardCounts,
  dbExportFormDetails,
  dbGetFormById,
  dbListForms,
  dbMutateForm,
} from '@/db/forms'
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
    return await dbMutateForm(input)
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
