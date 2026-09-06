'use client'

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { queryKeys } from '../../api/queryKeys'
import { FORM_PAGE_SIZE } from '../../api/params'
import {
  fetchDashboardCounts,
  fetchFormById,
  fetchForms,
  mutateForm,
  type FormListFilters,
  type SaveFormInput,
} from './formsApi'

export function useDashboardCounts() {
  return useQuery({
    queryKey: queryKeys.dashboardCounts,
    queryFn: fetchDashboardCounts,
  })
}

export function useFormsList(filters: FormListFilters) {
  return useQuery({
    queryKey: queryKeys.forms(filters),
    queryFn: () =>
      fetchForms({
        ...filters,
        page: filters.page ?? 1,
        limit: filters.limit ?? FORM_PAGE_SIZE,
      }),
  })
}

export function useForm(idForm: string | undefined, enabled = true) {
  return useQuery({
    queryKey: queryKeys.form(idForm ?? ''),
    queryFn: () => fetchFormById(idForm!),
    enabled: enabled && !!idForm?.trim(),
  })
}

export function useFormMutations() {
  const qc = useQueryClient()
  const invalidate = () => {
    qc.invalidateQueries({ queryKey: ['forms'] })
    qc.invalidateQueries({ queryKey: queryKeys.dashboardCounts })
  }

  return useMutation({
    mutationFn: (input: SaveFormInput) => mutateForm(input),
    onSuccess: invalidate,
  })
}
