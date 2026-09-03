'use client'

import { useInfiniteQuery, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
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

export function useFormsInfinite(filters: Omit<FormListFilters, 'page'>) {
  return useInfiniteQuery({
    queryKey: queryKeys.forms(filters),
    initialPageParam: 1,
    queryFn: ({ pageParam }) =>
      fetchForms({
        ...filters,
        page: pageParam,
        limit: filters.limit ?? FORM_PAGE_SIZE,
      }),
    getNextPageParam: (lastPage, allPages) => {
      const loaded = allPages.reduce((n, p) => n + p.items.length, 0)
      if (lastPage.items.length < (filters.limit ?? FORM_PAGE_SIZE)) {
        return undefined
      }
      if (lastPage.total != null && loaded >= lastPage.total) {
        return undefined
      }
      return allPages.length + 1
    },
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
