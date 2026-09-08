import type {
  DashboardCounts,
  FormRow,
  MutatingResult,
  PaginatedList,
  PoRow,
  RcvToolRow,
  RcvWhRow,
  SoRow,
  SuperiorRow,
  ToolDetailRow,
  UserRow,
} from '../types/models'
import { nameNotId } from '../lib/displayLabel'

function s(value: unknown, fallback = ''): string {
  if (value == null) return fallback
  return String(value)
}

function readInt(v: unknown): number {
  if (v == null) return 0
  if (typeof v === 'number') return v
  const n = Number(v)
  return Number.isFinite(n) ? n : 0
}

export function parseFormRow(json: Record<string, unknown>): FormRow {
  return {
    idForm: s(json.id_form ?? json.id),
    formNo: s(json.form_no),
    formServName: s(json.form_serv_name),
    formServNameLabel: nameNotId(
      s(json.form_serv_name_label || json.formServNameLabel),
    ),
    formServComment: s(json.form_serv_comment),
    formCheckBy: s(json.form_check_by),
    formCheckByLabel: nameNotId(
      s(json.form_check_by_label || json.formCheckByLabel),
    ),
    formDateCheckBy: s(json.form_date_check_by),
    formDateServName: s(json.form_date_serv_name),
    formSuperiorAprd: s(json.form_superior_aprd),
    formSuperiorComment: s(json.form_superior_comment),
    formSadminComment: s(json.form_sadmin_comment),
    formSheadAprd: s(json.form_shead_aprd),
    formSheadComment: s(json.form_shead_comment),
    fromDateUpdate: s(json.from_date_update),
    formUserUpdate: s(json.form_user_update),
    formDateSuperiorAprd: s(json.form_date_superior_aprd),
    formDateSadminComment: s(json.form_date_sadmin_comment),
    formDateSheadAprd: s(json.form_date_shead_aprd),
    formMilestone: s(json.form_milestone),
    formStatusOrder: s(json.form_status_order),
    superiorId: s(json.superior_id),
    servicemanSuperiorId: s(
      json.serviceman_superior_id ?? json.servicemanSuperiorId,
    ),
    toolItemCount: readInt(json.tool_item_count ?? json.toolItemCount),
  }
}

export function parseToolDetailRow(json: Record<string, unknown>): ToolDetailRow {
  return {
    idFormDetail: s(json.id_form_detail),
    idForm: s(json.id_form ?? json.idForm),
    formComment: s(json.form_comment),
    pnGroup: s(json.pn_group),
    pnDesc: s(json.pn_desc),
    qty: s(json.qty),
    explan: s(json.explan),
    actionNote: s(json.action_note),
    formDetailDate: s(json.form_detail_date),
    formDetailUser: s(json.form_detail_user),
    valType: s(json.val_type),
    partValue: s(json.part_value),
    brand: s(json.brand),
    spesifikasi: s(json.spesifikasi ?? json.specification),
  }
}

function decodeBody(data: unknown): unknown {
  if (typeof data === 'string') {
    try {
      return JSON.parse(data)
    } catch {
      throw new FormatError('Respons server tidak valid (JSON)')
    }
  }
  return data
}

export class FormatError extends Error {
  constructor(message: string) {
    super(message)
    this.name = 'FormatError'
  }
}

function readTotalFromMap(m: Record<string, unknown>): number | null {
  const t =
    m.total ??
    m.Total ??
    m.total_users ??
    m.total_count ??
    m.recordsTotal ??
    m.count
  if (t == null) return null
  const n = Number(t)
  return Number.isFinite(n) ? n : null
}

export function parseFormListResponse(data: unknown): PaginatedList<FormRow> {
  const decoded = decodeBody(data)
  if (Array.isArray(decoded)) {
    return {
      items: decoded
        .filter((e): e is Record<string, unknown> => !!e && typeof e === 'object')
        .map(parseFormRow),
      total: null,
    }
  }
  if (decoded && typeof decoded === 'object') {
    const m = decoded as Record<string, unknown>
    const total = readTotalFromMap(m)
    for (const key of ['data', 'rows', 'forms', 'records']) {
      const v = m[key]
      if (Array.isArray(v)) {
        return {
          items: v
            .filter((e): e is Record<string, unknown> => !!e && typeof e === 'object')
            .map(parseFormRow),
          total,
        }
      }
    }
    return { items: [], total }
  }
  throw new FormatError(`Unexpected form list response: ${typeof decoded}`)
}

export function parseDashboardCounts(data: unknown): DashboardCounts {
  const decoded = decodeBody(data)
  if (!decoded || typeof decoded !== 'object') {
    throw new FormatError('Unexpected dashboard counts response')
  }
  const json = decoded as Record<string, unknown>
  return {
    draft: readInt(json.draft),
    superiorApproval: readInt(json.superior_approval ?? json.superiorApproval),
    serviceAdmin: readInt(json.service_admin ?? json.serviceAdmin),
    deptHead: readInt(json.dept_head ?? json.deptHead),
    counterGa: readInt(json.counter_ga ?? json.counterGa),
    toolReceivedWhGa: readInt(
      json.tool_received_wh_ga ?? json.toolReceivedWhGa,
    ),
    hold: readInt(json.hold ?? json.hold_count),
    rejectedSuperior: readInt(
      json.rejected_superior ?? json.rejectedSuperior,
    ),
    rejectedDept: readInt(json.rejected_dept ?? json.rejectedDept),
    notificationTotal: readInt(
      json.notification_total ?? json.notificationTotal,
    ),
  }
}

export function parsePoRow(json: Record<string, unknown>): PoRow {
  return {
    idPo: s(json.id_po),
    idFormDetail: s(json.id_form_detail),
    poNo: s(json.po_no),
    dateUpdatePo: s(json.date_update_po),
    userUpdatePo: s(json.user_update_po),
  }
}

export function parseSoRow(json: Record<string, unknown>): SoRow {
  return {
    idSo: s(json.id_so),
    idFormDetail: s(json.id_form_detail),
    so: s(json.so),
    eta: s(json.eta),
    noteSo: s(json.note_so),
    boComplete: s(json.bo_complete ?? json.boComplete),
    dateUpdateSo: s(json.date_update_so ?? json['date_update_so\t']),
    idUpdateSo: s(json.id_update_so),
  }
}

export function parseRcvWhRow(json: Record<string, unknown>): RcvWhRow {
  return {
    idRcvWh: s(json.id_rcv_wh),
    idFormDetail: s(json.id_form_detail),
    rcvWhDate: s(json.rcv_wh_date),
    qty: s(json.qty),
    rcvWhIdInput: s(json.rcv_wh_id_input),
    rcvWhDateInput: s(json.rcv_wh_date_input),
  }
}

export function parseRcvToolRow(json: Record<string, unknown>): RcvToolRow {
  return {
    idRcvTool: s(json.id_rcv_tool),
    idFormDetail: s(json.id_form_detail),
    rcvToolDate: s(json.rcv_tool_date),
    qty: s(json.qty),
    rcvToolIdInput: s(json.rcv_tool_id_input),
    rcvToolDateInput: s(json.rcv_tool_date_input),
  }
}

function isEnvelope(map: Record<string, unknown>, idKey: string): boolean {
  if (!('value' in map) || !('message' in map)) return false
  return !(idKey in map)
}

export function parseMutatingListResponse<T>(
  data: unknown,
  isMutating: boolean,
  idKey: string,
  mapRow: (json: Record<string, unknown>) => T,
): MutatingResult<T> {
  const decoded = decodeBody(data)
  const raw = Array.isArray(decoded)
    ? decoded
    : (() => {
        throw new FormatError('Expected a JSON array from server')
      })()

  let statusValue: string | null = null
  let statusMessage: string | null = null
  const dataRows: Record<string, unknown>[] = []

  for (const item of raw) {
    if (!item || typeof item !== 'object') continue
    const m = item as Record<string, unknown>
    if (isEnvelope(m, idKey)) {
      statusValue = m.value != null ? String(m.value) : null
      statusMessage = m.message != null ? String(m.message) : null
    } else {
      dataRows.push(m)
    }
  }

  if (isMutating && statusValue == null) {
    throw new Error('Invalid server response (missing status)')
  }

  return {
    list: dataRows.map(mapRow),
    statusValue: isMutating ? statusValue : null,
    serverMessage: isMutating ? statusMessage?.trim() ?? null : null,
  }
}

export function parseUserRow(json: Record<string, unknown>): UserRow {
  return {
    idUsers: s(json.id_users),
    username: s(json.username),
    password: s(json.password),
    namaUser: s(json.nama_user),
    foto: s(json.foto),
    idTu: s(json.id_tu),
    noTelp: s(json.no_telp),
    token: s(json.token),
    level: s(json.level),
    status: s(json.status),
    superiorId: s(json.superior_id),
    namaSuperior: s(json.nama_superior),
    valueResponse: s(json.value),
    messageResponse: s(json.message),
  }
}

export function parseSuperiorRow(json: Record<string, unknown>): SuperiorRow {
  return {
    superiorId: s(json.superior_id),
    namaSuperior: s(json.nama_superior),
    statusSuperior: s(json.status_superior),
    username: s(json.username),
    namaUser: s(json.nama_user),
    idTu: s(json.id_tu),
  }
}

function parsePagedRows<T>(
  data: unknown,
  arrayKeys: string[],
  mapRow: (json: Record<string, unknown>) => T,
  label: string,
): PaginatedList<T> {
  const decoded = decodeBody(data)
  if (Array.isArray(decoded)) {
    return {
      items: decoded
        .filter((e): e is Record<string, unknown> => !!e && typeof e === 'object')
        .map(mapRow),
      total: null,
    }
  }
  if (decoded && typeof decoded === 'object') {
    const m = decoded as Record<string, unknown>
    const total = readTotalFromMap(m)
    for (const key of arrayKeys) {
      const v = m[key]
      if (Array.isArray(v)) {
        return {
          items: v
            .filter((e): e is Record<string, unknown> => !!e && typeof e === 'object')
            .map(mapRow),
          total,
        }
      }
    }
    return { items: [], total }
  }
  throw new FormatError(`Unexpected ${label} response: ${typeof decoded}`)
}

export function parseUserListResponse(data: unknown): PaginatedList<UserRow> {
  return parsePagedRows(
    data,
    ['data', 'rows', 'users', 'records'],
    parseUserRow,
    'user list',
  )
}

export function parseSuperiorListResponse(
  data: unknown,
): PaginatedList<SuperiorRow> {
  return parsePagedRows(
    data,
    ['data', 'rows', 'superiors', 'users', 'records'],
    parseSuperiorRow,
    'superior list',
  )
}

/** Detect mutate status from user API (array with value/message envelope or row). */
export function parseUserMutateResponse(data: unknown): {
  ok: boolean
  message: string
} {
  const decoded = decodeBody(data)
  const rows = Array.isArray(decoded)
    ? decoded
    : decoded && typeof decoded === 'object'
      ? [decoded]
      : []

  for (const item of rows) {
    if (!item || typeof item !== 'object') continue
    const m = item as Record<string, unknown>
    if ('value' in m) {
      const value = s(m.value)
      const message = s(m.message) || (value === '1' ? 'Sukses' : 'Gagal')
      return { ok: value === '1', message }
    }
  }

  // Some PHP endpoints return list after mutate without explicit status
  return { ok: true, message: 'Sukses' }
}

export function parseMutatingToolDetailResponse(
  data: unknown,
  _param: string,
  isMutating: boolean,
): MutatingResult<ToolDetailRow> {
  return parseMutatingListResponse(
    data,
    isMutating,
    'id_form_detail',
    parseToolDetailRow,
  )
}
