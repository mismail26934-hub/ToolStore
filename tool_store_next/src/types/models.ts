export type SessionUser = {
  idUsersApp: string
  name: string
  username: string
  password: string
  level: string
  token: string
  status: string
  idTu: string
  foto: string
  superiorId: string
  namaSuperior: string
  noTelp: string
  value: string
}

export type FormRow = {
  idForm: string
  formNo: string
  /** Stored serviceman value: `users.id_users` (legacy rows may still be a name). */
  formServName: string
  /** Display name resolved from `users` when `formServName` is an id. */
  formServNameLabel: string
  formServComment: string
  /** Stored check-by value: `users.id_users` (legacy rows may still be a name). */
  formCheckBy: string
  /** Display name resolved from `users` when `formCheckBy` is an id. */
  formCheckByLabel: string
  formDateCheckBy: string
  formDateServName: string
  formSuperiorAprd: string
  formSuperiorComment: string
  formSadminComment: string
  formSheadAprd: string
  formSheadComment: string
  fromDateUpdate: string
  formUserUpdate: string
  formDateSuperiorAprd: string
  formDateSadminComment: string
  formDateSheadAprd: string
  formMilestone: string
  formStatusOrder: string
  superiorId: string
  /** `users.superior_id` of the form serviceman (for Superior reopen). */
  servicemanSuperiorId: string
  /** Jumlah baris tool item (form_details) pada form ini */
  toolItemCount: number
}

export type ToolDetailRow = {
  idFormDetail: string
  idForm: string
  formComment: string
  pnGroup: string
  pnDesc: string
  qty: string
  explan: string
  actionNote: string
  formDetailDate: string
  formDetailUser: string
  valType: string
  partValue: string
  brand?: string
  spesifikasi?: string
}

export type DashboardCounts = {
  draft: number
  superiorApproval: number
  serviceAdmin: number
  deptHead: number
  counterGa: number
  toolReceivedWhGa: number
  hold: number
  rejectedSuperior: number
  rejectedDept: number
  notificationTotal: number
}

export type PaginatedList<T> = {
  items: T[]
  total: number | null
}

export type MutatingResult<T> = {
  list: T[]
  statusValue: string | null
  serverMessage: string | null
}

export type LoginResponse = {
  value: string
  message?: string
  user?: Record<string, unknown>
  [key: string]: unknown
}

export type UserRow = {
  idUsers: string
  username: string
  password: string
  namaUser: string
  foto: string
  idTu: string
  noTelp: string
  token: string
  level: string
  status: string
  superiorId: string
  namaSuperior: string
  valueResponse: string
  messageResponse: string
}

export type SuperiorRow = {
  superiorId: string
  namaSuperior: string
  statusSuperior: string
  username: string
  namaUser: string
  idTu: string
}

export type PrRow = {
  idPr: string
  idFormDetail: string
  prNo: string
  dateUpdatePr: string
  userUpdatePr: string
}

export type SoRow = {
  idSo: string
  idFormDetail: string
  so: string
  eta: string
  noteSo: string
  boComplete: string
  dateUpdateSo: string
  idUpdateSo: string
}

export type RcvWhRow = {
  idRcvWh: string
  idFormDetail: string
  rcvWhDate: string
  qty: string
  rcvWhIdInput: string
  rcvWhDateInput: string
}

export type RcvToolRow = {
  idRcvTool: string
  idFormDetail: string
  rcvToolDate: string
  qty: string
  rcvToolIdInput: string
  rcvToolDateInput: string
}

export const USER_LEVELS = [
  'USER',
  'SUPERADMIN',
  'MECHANIC',
  'SERVICE_ADMIN',
  'SUPERIOR',
  'HEAD_SERVICE',
  'TOOL_KEEPER',
  'COUNTER',
  'GA',
  'WH',
] as const

export const USER_PAGE_SIZE = 20
