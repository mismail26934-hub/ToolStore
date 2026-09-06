'use server'

import { ApiParam } from '@/api/params'
import {
  dbGetSuperiorById,
  dbImportSuperiors,
  dbListSuperiors,
  dbMutateSuperior,
  type SaveSuperiorInput,
  type SuperiorImportResult,
  type SuperiorImportRow,
  type SuperiorListFilters,
} from '@/db/superiors'
import type { PaginatedList, SuperiorRow } from '@/types/models'

export type {
  SaveSuperiorInput,
  SuperiorImportResult,
  SuperiorImportRow,
  SuperiorListFilters,
}

export async function fetchSuperiors(
  filters: SuperiorListFilters = {},
): Promise<PaginatedList<SuperiorRow>> {
  try {
    return await dbListSuperiors(filters)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal memuat superior')
  }
}

export async function fetchSuperiorById(
  superiorId: string,
): Promise<SuperiorRow | null> {
  try {
    return await dbGetSuperiorById(superiorId)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal memuat superior')
  }
}

export async function addSuperior(input: SaveSuperiorInput): Promise<string> {
  try {
    return await dbMutateSuperior(ApiParam.addSuperior, input)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal menambah superior')
  }
}

export async function editSuperior(input: SaveSuperiorInput): Promise<string> {
  try {
    return await dbMutateSuperior(ApiParam.editSuperior, input)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal mengubah superior')
  }
}

export async function deleteSuperior(
  input: SaveSuperiorInput,
): Promise<string> {
  try {
    return await dbMutateSuperior(ApiParam.deleteSuperior, input)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal menghapus superior')
  }
}

export async function importSuperiors(
  rows: SuperiorImportRow[],
): Promise<SuperiorImportResult> {
  try {
    if (!rows.length) throw new Error('Tidak ada baris untuk diimport')
    return await dbImportSuperiors(rows)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal import superior')
  }
}
