'use server'

import { ApiParam } from '@/api/params'
import { dbListTools, dbMutateTool, type ToolDetailPayload } from '@/db/tools'
import type { MutatingResult, ToolDetailRow } from '@/types/models'

export type { ToolDetailPayload }

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
    return await dbMutateTool(ApiParam.addTool, payload)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal proses tool')
  }
}

export async function editToolDetail(
  payload: ToolDetailPayload,
): Promise<MutatingResult<ToolDetailRow>> {
  try {
    return await dbMutateTool(ApiParam.editTool, payload)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal proses tool')
  }
}

export async function deleteToolDetail(
  payload: ToolDetailPayload,
): Promise<MutatingResult<ToolDetailRow>> {
  try {
    return await dbMutateTool(ApiParam.deleteTool, payload)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal proses tool')
  }
}
