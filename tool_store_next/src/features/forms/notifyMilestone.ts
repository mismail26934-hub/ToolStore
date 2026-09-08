import type { RowDataPacket } from 'mysql2'
import { s } from '@/db/helpers'
import { getDbPool } from '@/db/pool'
import {
  dbListPoByForm,
  dbListRcvToolByForm,
  dbListRcvWhByForm,
  dbListSoByForm,
} from '@/db/related'
import { dbListTools } from '@/db/tools'
import {
  milestoneRank,
  normFormMilestone,
} from '@/features/forms/formMilestones'
import { buildNotifyMessage } from '@/features/forms/notifyMessage'
import {
  isWhacenterEnabled,
  normalizeWaNumber,
  sendWhacenterMessage,
} from '@/lib/whacenter'

type NotifyRule = {
  step?: number
  kind?: 'blocked'
  banner?: string
  title: string
  action: string
  includeServiceman?: boolean
  includeSuperior?: boolean
  levels?: string[]
}

const RULES: Record<string, NotifyRule> = {
  'CHECK BY TOOL STORE': {
    step: 1,
    title: 'Permintaan Order',
    action: 'Request diajukan. Silakan approval superior.',
    includeSuperior: true,
  },
  'SUPERIOR APPROVED': {
    step: 2,
    title: 'Persetujuan Order 1',
    action: 'Superior sudah approve. Silakan review Service Admin.',
    levels: ['SERVICE_ADMIN'],
  },
  'REVIEWED BY SERVICE ADMIN': {
    step: 3,
    title: 'Review Order',
    action: 'Service Admin sudah review. Silakan approval Dept Head.',
    levels: ['HEAD_SERVICE'],
  },
  'APPROVED BY SERVICE DEPT HEAD': {
    step: 4,
    title: 'Persetujuan Order 2',
    action: 'Dept Head sudah approve. Silakan proses SO / PR (Counter / GA).',
    levels: ['COUNTER', 'GA'],
  },
  'PROCESSING ORDER': {
    step: 5,
    title: 'Proses Order',
    action: 'SO / PR sudah ada. Menunggu penerimaan gudang (WH).',
    includeServiceman: true,
    levels: ['WH'],
  },
  'ORDER PROCESSED': {
    step: 5,
    title: 'Proses Order',
    action: 'SO / PR sudah ada. Menunggu penerimaan gudang (WH).',
    includeServiceman: true,
    levels: ['WH'],
  },
  'PARTIAL RECEIVED BY WH/GA': {
    step: 6,
    title: 'WH Received (sebagian)',
    action: 'Sebagian tool sudah diterima WH. Silakan serah terima tool room.',
    includeServiceman: true,
    levels: ['TOOL_KEEPER'],
  },
  'RECEIVED BY WH/GA': {
    step: 6,
    title: 'WH Received',
    action: 'Semua tool sudah diterima WH. Silakan serah terima tool room.',
    includeServiceman: true,
    levels: ['TOOL_KEEPER'],
  },
  'PARTIAL RECEIVED TOOL STORE': {
    step: 7,
    title: 'Tool Received (sebagian)',
    action: 'Sebagian tool sudah diterima tool room.',
    includeServiceman: true,
    includeSuperior: true,
  },
  'PARTIAL RECEIVED BY TOOL STORE': {
    step: 7,
    title: 'Tool Received (sebagian)',
    action: 'Sebagian tool sudah diterima tool room.',
    includeServiceman: true,
    includeSuperior: true,
  },
  'RECEIVED TOOL STORE': {
    step: 7,
    title: 'Tool Received',
    action: 'Semua tool sudah diterima tool room.',
    includeServiceman: true,
    includeSuperior: true,
  },
  'RECEIVED BY TOOL STORE': {
    step: 7,
    title: 'Tool Received',
    action: 'Semua tool sudah diterima tool room.',
    includeServiceman: true,
    includeSuperior: true,
  },
  'REJECTED BY SUPERIOR': {
    kind: 'blocked',
    banner: '⚠️ Tool Store — Ditolak',
    title: 'Ditolak Superior',
    action: 'Superior menolak order ini. Silakan cek comment dan form.',
    includeServiceman: true,
  },
  'HOLD BY SERVICE ADMIN': {
    kind: 'blocked',
    banner: '⏸️ Tool Store — Ditahan',
    title: 'Ditahan Service Admin',
    action: 'Service Admin menahan order ini. Menunggu review lanjutan.',
    includeServiceman: true,
    includeSuperior: true,
  },
  'REJECTED BY SERVICE DEPT HEAD': {
    kind: 'blocked',
    banner: '⚠️ Tool Store — Ditolak',
    title: 'Ditolak Dept Head',
    action: 'Dept Head menolak order ini. Silakan cek comment dan form.',
    includeServiceman: true,
    includeSuperior: true,
  },
}

type UserPhone = {
  idUsers: string
  namaUser: string
  noTelp: string
}

function activeStatusSql() {
  return `UPPER(TRIM(COALESCE(NULLIF(status, ''), 'ACTIVE'))) = 'ACTIVE'`
}

async function findUserByRef(
  ref: string,
): Promise<(UserPhone & { superiorId: string }) | null> {
  const value = ref.trim()
  if (!value) return null
  const pool = getDbPool()
  const [rows] = await pool.query<RowDataPacket[]>(
    `SELECT id_users, nama_user, no_telp, superior_id
     FROM users
     WHERE TRIM(id_users) = ? OR TRIM(nama_user) = ? OR TRIM(username) = ?
     ORDER BY CASE
       WHEN TRIM(id_users) = ? THEN 0
       WHEN TRIM(nama_user) = ? THEN 1
       ELSE 2
     END
     LIMIT 1`,
    [value, value, value, value, value],
  )
  const row = rows[0]
  if (!row) return null
  return {
    idUsers: s(row.id_users),
    namaUser: s(row.nama_user),
    noTelp: s(row.no_telp),
    superiorId: s(row.superior_id),
  }
}

async function findUserById(idUsers: string): Promise<UserPhone | null> {
  const id = idUsers.trim()
  if (!id) return null
  const pool = getDbPool()
  const [rows] = await pool.query<RowDataPacket[]>(
    `SELECT id_users, nama_user, no_telp
     FROM users
     WHERE TRIM(id_users) = ?
     LIMIT 1`,
    [id],
  )
  const row = rows[0]
  if (!row) return null
  return {
    idUsers: s(row.id_users),
    namaUser: s(row.nama_user),
    noTelp: s(row.no_telp),
  }
}

async function findUsersByLevels(levels: string[]): Promise<UserPhone[]> {
  if (!levels.length) return []
  const pool = getDbPool()
  const placeholders = levels.map(() => '?').join(', ')
  const [rows] = await pool.query<RowDataPacket[]>(
    `SELECT id_users, nama_user, no_telp
     FROM users
     WHERE UPPER(TRIM(level)) IN (${placeholders})
       AND ${activeStatusSql()}
       AND no_telp IS NOT NULL AND TRIM(no_telp) <> ''`,
    levels.map((lv) => lv.toUpperCase()),
  )
  return rows.map((row) => ({
    idUsers: s(row.id_users),
    namaUser: s(row.nama_user),
    noTelp: s(row.no_telp),
  }))
}

async function loadFormNotifyFields(idForm: string): Promise<{
  formNo: string
  formServName: string
  formStatusOrder: string
  formCategory: string
  superiorComment: string
  sadminComment: string
  sheadComment: string
} | null> {
  const id = idForm.trim()
  if (!id) return null
  const pool = getDbPool()
  const [rows] = await pool.query<RowDataPacket[]>(
    `SELECT form_no, form_serv_name, form_status_order, form_serv_comment,
            form_superior_comment, form_sadmin_comment, form_shead_comment
     FROM forms WHERE id_form = ? LIMIT 1`,
    [id],
  )
  const row = rows[0]
  if (!row) return null
  return {
    formNo: s(row.form_no),
    formServName: s(row.form_serv_name),
    formStatusOrder: s(row.form_status_order),
    formCategory: s(row.form_serv_comment),
    superiorComment: s(row.form_superior_comment),
    sadminComment: s(row.form_sadmin_comment),
    sheadComment: s(row.form_shead_comment),
  }
}

function addPhone(target: Map<string, string>, raw: string, label: string) {
  const number = normalizeWaNumber(raw)
  if (!number) return
  if (!target.has(number)) target.set(number, label)
}

/**
 * Kirim WA Whacenter saat milestone form maju ke step 1–7, atau reject/hold.
 * Gagal kirim tidak boleh menggagalkan simpan form.
 */
export async function notifyFormMilestoneChange(input: {
  idForm: string
  prevMilestone: string
  nextMilestone: string
  formNo?: string
  formServName?: string
}): Promise<void> {
  if (!isWhacenterEnabled()) return

  const prev = normFormMilestone(input.prevMilestone)
  const next = normFormMilestone(input.nextMilestone)
  if (!next || prev === next) return

  const rule = RULES[next]
  if (!rule) return

  const isBlocked = rule.kind === 'blocked'
  if (
    !isBlocked &&
    milestoneRank(input.nextMilestone) < milestoneRank(input.prevMilestone)
  ) {
    return
  }

  const form = await loadFormNotifyFields(input.idForm)
  const formNo = form?.formNo || input.formNo || ''
  const formServName = form?.formServName || input.formServName || ''

  const [tools, pos, sos, whs, rooms] = await Promise.all([
    dbListTools(input.idForm),
    dbListPoByForm(input.idForm),
    dbListSoByForm(input.idForm),
    dbListRcvWhByForm(input.idForm),
    dbListRcvToolByForm(input.idForm),
  ])

  const serviceman = await findUserByRef(formServName)
  const superior = serviceman?.superiorId
    ? await findUserById(serviceman.superiorId)
    : null

  const phones = new Map<string, string>()
  if (rule.includeServiceman && serviceman) {
    addPhone(phones, serviceman.noTelp, 'serviceman')
  }
  if (rule.includeSuperior && superior) {
    addPhone(phones, superior.noTelp, 'superior')
  }
  if (rule.levels?.length) {
    const roleUsers = await findUsersByLevels(rule.levels)
    for (const u of roleUsers) addPhone(phones, u.noTelp, u.namaUser || u.idUsers)
  }

  if (phones.size === 0) {
    console.warn(
      `[whacenter] skip form ${input.idForm}: tidak ada nomor untuk ${next}`,
    )
    return
  }

  const message = buildNotifyMessage({
    rule,
    formNo,
    formStatusOrder: form?.formStatusOrder || '',
    formCategory: form?.formCategory || '',
    servicemanName: serviceman?.namaUser || formServName,
    milestone: input.nextMilestone.trim() || next,
    superiorComment: form?.superiorComment || '',
    sadminComment: form?.sadminComment || '',
    sheadComment: form?.sheadComment || '',
    tools,
    pos,
    sos,
    whs,
    rooms,
  })

  const results = await Promise.allSettled(
    [...phones.keys()].map((number) => sendWhacenterMessage({ number, message })),
  )
  let sent = 0
  for (const [i, result] of results.entries()) {
    if (result.status === 'rejected') {
      console.error('[whacenter] send error', result.reason)
      continue
    }
    if (!result.value.ok) {
      const number = [...phones.keys()][i]
      console.error('[whacenter] send failed', number, result.value.error)
      continue
    }
    sent += 1
  }
  if (sent > 0) {
    const label = isBlocked ? next : `step ${rule.step}`
    console.info(`[whacenter] ${label} form ${input.idForm} → ${sent} nomor`)
  }
}
