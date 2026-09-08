'use server'

import {
  dbListPoByForm,
  dbListRcvToolByForm,
  dbListRcvWhByForm,
  dbListSoByForm,
  dbMutatePo,
  dbMutateRcvTool,
  dbMutateRcvWh,
  dbMutateSo,
} from '@/db/related'
import type { PoRow, RcvToolRow, RcvWhRow, SoRow } from '@/types/models'

export async function fetchPoByForm(idForm: string): Promise<PoRow[]> {
  try {
    return await dbListPoByForm(idForm)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal memuat PO')
  }
}

export async function mutatePo(input: {
  param: string
  idPo?: string
  idFormDetail: string
  poNo?: string
  dateUpdatePo?: string
  userUpdatePo?: string
}): Promise<string> {
  try {
    return await dbMutatePo(input)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal proses PO')
  }
}

export async function fetchSoByForm(idForm: string): Promise<SoRow[]> {
  try {
    return await dbListSoByForm(idForm)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal memuat SO')
  }
}

export async function mutateSo(input: {
  param: string
  idSo?: string
  idFormDetail: string
  so?: string
  eta?: string
  noteSo?: string
  dateUpdateSo?: string
  idUpdateSo?: string
}): Promise<string> {
  try {
    return await dbMutateSo(input)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal proses SO')
  }
}

export async function fetchRcvWhByForm(idForm: string): Promise<RcvWhRow[]> {
  try {
    return await dbListRcvWhByForm(idForm)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal memuat Rcv WH')
  }
}

export async function mutateRcvWh(input: {
  param: string
  idRcvWh?: string
  idFormDetail: string
  rcvWhDate?: string
  qty?: string
  rcvWhIdInput?: string
  rcvWhDateInput?: string
}): Promise<string> {
  try {
    return await dbMutateRcvWh(input)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal proses Rcv WH')
  }
}

export async function fetchRcvToolByForm(idForm: string): Promise<RcvToolRow[]> {
  try {
    return await dbListRcvToolByForm(idForm)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal memuat Rcv Tool')
  }
}

export async function mutateRcvTool(input: {
  param: string
  idRcvTool?: string
  idFormDetail: string
  rcvToolDate?: string
  qty?: string
  rcvToolIdInput?: string
  rcvToolDateInput?: string
}): Promise<string> {
  try {
    return await dbMutateRcvTool(input)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal proses Rcv Tool')
  }
}
