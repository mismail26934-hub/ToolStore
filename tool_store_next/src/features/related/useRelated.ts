'use client'

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { queryKeys } from '../../api/queryKeys'
import {
  fetchPoByForm,
  fetchRcvToolByForm,
  fetchRcvWhByForm,
  fetchSoByForm,
  mutatePo,
  mutateRcvTool,
  mutateRcvWh,
  mutateSo,
} from './relatedApi'

export function useFormRelated(idForm: string, enabled = true) {
  const on = enabled && idForm.trim().length > 0
  const po = useQuery({
    queryKey: queryKeys.po(idForm),
    queryFn: () => fetchPoByForm(idForm),
    enabled: on,
  })
  const so = useQuery({
    queryKey: queryKeys.so(idForm),
    queryFn: () => fetchSoByForm(idForm),
    enabled: on,
  })
  const rcvWh = useQuery({
    queryKey: queryKeys.rcvWh(idForm),
    queryFn: () => fetchRcvWhByForm(idForm),
    enabled: on,
  })
  const rcvTool = useQuery({
    queryKey: queryKeys.rcvTool(idForm),
    queryFn: () => fetchRcvToolByForm(idForm),
    enabled: on,
  })

  return { po, so, rcvWh, rcvTool }
}

export function useRelatedMutations(idForm: string) {
  const qc = useQueryClient()
  const invalidate = () => {
    qc.invalidateQueries({ queryKey: queryKeys.po(idForm) })
    qc.invalidateQueries({ queryKey: queryKeys.so(idForm) })
    qc.invalidateQueries({ queryKey: queryKeys.rcvWh(idForm) })
    qc.invalidateQueries({ queryKey: queryKeys.rcvTool(idForm) })
    qc.invalidateQueries({ queryKey: ['forms'] })
  }

  return {
    po: useMutation({ mutationFn: mutatePo, onSuccess: invalidate }),
    so: useMutation({ mutationFn: mutateSo, onSuccess: invalidate }),
    rcvWh: useMutation({ mutationFn: mutateRcvWh, onSuccess: invalidate }),
    rcvTool: useMutation({ mutationFn: mutateRcvTool, onSuccess: invalidate }),
  }
}
