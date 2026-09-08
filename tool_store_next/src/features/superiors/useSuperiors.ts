'use client'

import {
  useMutation,
  useQuery,
  useQueryClient,
} from '@tanstack/react-query'
import { queryKeys } from '@/api/queryKeys'
import { USER_PAGE_SIZE } from '@/types/models'
import {
  addSuperior,
  deleteSuperior,
  editSuperior,
  fetchSuperiorById,
  fetchSuperiors,
  importSuperiors,
  type SaveSuperiorInput,
  type SuperiorImportRow,
  type SuperiorListFilters,
} from './superiorsApi'

export function useSuperiorsList(filters: SuperiorListFilters) {
  return useQuery({
    queryKey: queryKeys.superiors(filters),
    queryFn: () =>
      fetchSuperiors({
        ...filters,
        page: filters.page ?? 1,
        limit: filters.limit ?? USER_PAGE_SIZE,
      }),
  })
}

export function useSuperior(id: string | undefined, enabled = true) {
  return useQuery({
    queryKey: ['superior', id ?? ''],
    queryFn: () => fetchSuperiorById(id!),
    enabled: enabled && !!id?.trim(),
  })
}

export function useSuperiorMutations() {
  const qc = useQueryClient()
  const invalidate = () => {
    void qc.invalidateQueries({ queryKey: ['superiors'] })
    void qc.invalidateQueries({ queryKey: ['superior'] })
    void qc.invalidateQueries({ queryKey: ['users'] })
  }

  const add = useMutation({
    mutationFn: (input: SaveSuperiorInput) => addSuperior(input),
    onSuccess: invalidate,
  })
  const edit = useMutation({
    mutationFn: (input: SaveSuperiorInput) => editSuperior(input),
    onSuccess: invalidate,
  })
  const remove = useMutation({
    mutationFn: (input: SaveSuperiorInput) => deleteSuperior(input),
    onSuccess: invalidate,
  })
  const importRows = useMutation({
    mutationFn: (rows: SuperiorImportRow[]) => importSuperiors(rows),
    onSuccess: invalidate,
  })

  return { add, edit, remove, importRows }
}
