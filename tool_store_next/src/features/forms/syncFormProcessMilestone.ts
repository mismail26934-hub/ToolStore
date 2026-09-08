import { queryKeys } from '@/api/queryKeys'
import { formEditPayload } from '@/features/forms/formEdit'
import { resolveProcessMilestone } from '@/features/forms/formMilestones'
import { fetchFormById, mutateForm } from '@/features/forms/formsApi'
import {
  fetchRcvToolByForm,
  fetchRcvWhByForm,
  fetchSoByForm,
} from '@/features/related/relatedApi'
import { fetchToolDetails } from '@/features/tools/toolsApi'
import type { FormRow } from '@/types/models'
import type { QueryClient } from '@tanstack/react-query'

/** Refetch related rows and sync form process milestone (steps 5–7). */
export async function syncFormProcessMilestone(input: {
  form: FormRow
  userId: string
  queryClient: QueryClient
}): Promise<void> {
  const { form, userId, queryClient } = input
  const idForm = form.idForm

  // Fetch langsung dari server agar delete SO / WH / Tool Room tidak kena cache lama.
  const [freshForm, tools, so, rcvWh, rcvTool] = await Promise.all([
    fetchFormById(idForm).catch(() => form),
    fetchToolDetails(idForm),
    fetchSoByForm(idForm),
    fetchRcvWhByForm(idForm),
    fetchRcvToolByForm(idForm),
  ])

  const current = freshForm ?? form
  if (!current?.idForm) return

  const next = resolveProcessMilestone({
    currentMilestone: current.formMilestone,
    formSheadAprd: current.formSheadAprd,
    toolDetailIds: tools.map((t) => t.idFormDetail),
    soDetailIds: so.map((r) => r.idFormDetail),
    whDetailIds: rcvWh.map((r) => r.idFormDetail),
    toolRcvDetailIds: rcvTool.map((r) => r.idFormDetail),
  })

  if (!next) return

  await mutateForm(formEditPayload(current, { formMilestone: next }, userId))
  await Promise.all([
    queryClient.invalidateQueries({ queryKey: ['forms'] }),
    queryClient.invalidateQueries({ queryKey: queryKeys.form(idForm) }),
    queryClient.invalidateQueries({ queryKey: queryKeys.toolDetails(idForm) }),
    queryClient.invalidateQueries({ queryKey: queryKeys.so(idForm) }),
    queryClient.invalidateQueries({ queryKey: queryKeys.rcvWh(idForm) }),
    queryClient.invalidateQueries({ queryKey: queryKeys.rcvTool(idForm) }),
    queryClient.invalidateQueries({ queryKey: queryKeys.dashboardCounts }),
  ])
}
