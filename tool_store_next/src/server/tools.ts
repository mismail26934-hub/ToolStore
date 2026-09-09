'use server'

import { ApiParam } from '@/api/params'
import { formContentDeniedMessage } from '@/auth/roles'
import { dbGetFormById } from '@/db/forms'
import { dbListTools, dbMutateTool, type ToolDetailPayload } from '@/db/tools'
import { dbGetUserById } from '@/db/usersRepo'
import type { MutatingResult, ToolDetailRow } from '@/types/models'

export type { ToolDetailPayload }

async function assertCanMutateTool(payload: ToolDetailPayload) {
  const form = await dbGetFormById(payload.idForm)
  if (!form) throw new Error('Form tidak ditemukan')
  const actorId = (payload.formDetailUser ?? '').trim()
  const actor = actorId ? await dbGetUserById(actorId) : null
  const denied = formContentDeniedMessage(
    actor ? { level: actor.level } : null,
    form.formMilestone,
  )
  if (denied) throw new Error(denied)
}

export async function fetchToolDetails(idForm: string): Promise<ToolDetailRow[]> {
  try {
    return await dbListTools(idForm)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal memuat tool items')
  }
}

export async function addToolDetail(
  payload: ToolDetailPayload,
): Promise<MutatingResult<ToolDetailRow>> {
  try {
    await assertCanMutateTool(payload)
    return await dbMutateTool(ApiParam.addTool, payload)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal proses tool')
  }
}

export async function editToolDetail(
  payload: ToolDetailPayload,
): Promise<MutatingResult<ToolDetailRow>> {
  try {
    await assertCanMutateTool(payload)
    return await dbMutateTool(ApiParam.editTool, payload)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal proses tool')
  }
}

export async function deleteToolDetail(
  payload: ToolDetailPayload,
): Promise<MutatingResult<ToolDetailRow>> {
  try {
    await assertCanMutateTool(payload)
    return await dbMutateTool(ApiParam.deleteTool, payload)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal proses tool')
  }
}
