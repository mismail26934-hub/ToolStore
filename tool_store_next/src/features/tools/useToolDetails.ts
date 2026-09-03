'use client'

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { queryKeys } from '../../api/queryKeys'
import {
  addToolDetail,
  deleteToolDetail,
  editToolDetail,
  fetchToolDetails,
  type ToolDetailPayload,
} from './toolsApi'

export function useToolDetails(idForm: string, enabled = true) {
  return useQuery({
    queryKey: queryKeys.toolDetails(idForm),
    queryFn: () => fetchToolDetails(idForm),
    enabled: enabled && idForm.trim().length > 0,
  })
}

export function useToolDetailMutations(idForm: string) {
  const qc = useQueryClient()
  const invalidate = () =>
    qc.invalidateQueries({ queryKey: queryKeys.toolDetails(idForm) })

  const add = useMutation({
    mutationFn: (payload: ToolDetailPayload) => addToolDetail(payload),
    onSuccess: invalidate,
  })
  const edit = useMutation({
    mutationFn: (payload: ToolDetailPayload) => editToolDetail(payload),
    onSuccess: invalidate,
  })
  const remove = useMutation({
    mutationFn: (payload: ToolDetailPayload) => deleteToolDetail(payload),
    onSuccess: invalidate,
  })

  return { add, edit, remove }
}
