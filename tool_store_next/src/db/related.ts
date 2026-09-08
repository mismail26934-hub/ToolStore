import type { ResultSetHeader, RowDataPacket } from 'mysql2'
import { ApiParam } from '@/api/params'
import { canMutateSo } from '@/auth/roles'
import { backupRowBeforeChange } from '@/db/backup'
import { emptyToNull, newId, s } from '@/db/helpers'
import { getDbPool } from '@/db/pool'
import type { PoRow, RcvToolRow, RcvWhRow, SoRow } from '@/types/models'

type Packet = RowDataPacket & Record<string, unknown>

function mapPo(row: Packet): PoRow {
  return {
    idPo: s(row.id_po),
    idFormDetail: s(row.id_form_detail),
    poNo: s(row.po_no),
    dateUpdatePo: s(row.date_update_po),
    userUpdatePo: s(row.user_update_po),
  }
}

function mapSo(row: Packet): SoRow {
  return {
    idSo: s(row.id_so),
    idFormDetail: s(row.id_form_detail),
    so: s(row.so),
    eta: s(row.eta),
    noteSo: s(row.note_so),
    boComplete: s(row.bo_complete) || 'NO',
    dateUpdateSo: s(row.date_update_so),
    idUpdateSo: s(row.id_update_so),
  }
}

function mapRcvWh(row: Packet): RcvWhRow {
  return {
    idRcvWh: s(row.id_rcv_wh),
    idFormDetail: s(row.id_form_detail),
    rcvWhDate: s(row.rcv_wh_date),
    qty: s(row.qty),
    rcvWhIdInput: s(row.rcv_wh_id_input),
    rcvWhDateInput: s(row.rcv_wh_date_input),
  }
}

function mapRcvTool(row: Packet): RcvToolRow {
  return {
    idRcvTool: s(row.id_rcv_tool),
    idFormDetail: s(row.id_form_detail),
    rcvToolDate: s(row.rcv_tool_date),
    qty: s(row.qty),
    rcvToolIdInput: s(row.rcv_tool_id_input),
    rcvToolDateInput: s(row.rcv_tool_date_input),
  }
}

let rcvQtyEnsured = false

async function ensureRcvQtyColumns(): Promise<void> {
  if (rcvQtyEnsured) return
  const pool = getDbPool()
  for (const table of ['rcv_wh', 'rcv_tool'] as const) {
    const [rows] = await pool.query<RowDataPacket[]>(
      `SELECT 1 AS ok FROM information_schema.columns
       WHERE table_schema = DATABASE()
         AND table_name = ?
         AND column_name = 'qty'
       LIMIT 1`,
      [table],
    )
    if (!rows[0]) {
      await pool.query(
        `ALTER TABLE \`${table}\` ADD COLUMN qty VARCHAR(50) NULL AFTER ${
          table === 'rcv_wh' ? 'rcv_wh_date' : 'rcv_tool_date'
        }`,
      )
    }
  }
  rcvQtyEnsured = true
}

let soBoCompleteEnsured = false

async function ensureSoBoCompleteColumn(): Promise<void> {
  if (soBoCompleteEnsured) return
  const pool = getDbPool()
  const [rows] = await pool.query<RowDataPacket[]>(
    `SELECT 1 AS ok FROM information_schema.columns
     WHERE table_schema = DATABASE()
       AND table_name = 'so'
       AND column_name = 'bo_complete'
     LIMIT 1`,
  )
  if (!rows[0]) {
    await pool.query(
      `ALTER TABLE so ADD COLUMN bo_complete VARCHAR(10) NULL DEFAULT 'NO' AFTER note_so`,
    )
  }
  soBoCompleteEnsured = true
}

function normBoComplete(value?: string | null): 'YES' | 'NO' {
  return (value ?? '').trim().toUpperCase() === 'YES' ? 'YES' : 'NO'
}

export async function dbListPoByForm(idForm: string): Promise<PoRow[]> {
  const pool = getDbPool()
  const [rows] = await pool.query<Packet[]>(
    `SELECT p.* FROM po p
     INNER JOIN form_details d ON d.id_form_detail = p.id_form_detail
     WHERE d.id_form = ?`,
    [idForm.trim()],
  )
  return rows.map(mapPo)
}

export async function dbMutatePo(input: {
  param: string
  idPo?: string
  idFormDetail: string
  poNo?: string
  dateUpdatePo?: string
  userUpdatePo?: string
}): Promise<string> {
  const pool = getDbPool()
  if (input.param === ApiParam.deletePo) {
    const id = input.idPo?.trim() ?? ''
    await backupRowBeforeChange({
      tableName: 'po',
      recordId: id,
      action: 'DELETE',
      userId: input.userUpdatePo,
    })
    await pool.query(`DELETE FROM po WHERE id_po = ?`, [id])
    return 'PO dihapus'
  }
  if (input.param === ApiParam.addPo) {
    await pool.query(
      `INSERT INTO po (id_po, id_form_detail, po_no, date_update_po, user_update_po)
       VALUES (?,?,?,?,?)`,
      [
        input.idPo?.trim() || newId(),
        input.idFormDetail,
        emptyToNull(input.poNo),
        emptyToNull(input.dateUpdatePo),
        emptyToNull(input.userUpdatePo),
      ],
    )
    return 'PO ditambahkan'
  }
  if (input.param === ApiParam.editPo) {
    const id = input.idPo?.trim() ?? ''
    await backupRowBeforeChange({
      tableName: 'po',
      recordId: id,
      action: 'UPDATE',
      userId: input.userUpdatePo,
    })
    const [r] = await pool.query<ResultSetHeader>(
      `UPDATE po SET po_no = ?, date_update_po = ?, user_update_po = ?
       WHERE id_po = ?`,
      [
        emptyToNull(input.poNo),
        emptyToNull(input.dateUpdatePo),
        emptyToNull(input.userUpdatePo),
        id,
      ],
    )
    if (r.affectedRows === 0) throw new Error('PO tidak ditemukan')
    return 'PO diperbarui'
  }
  throw new Error(`Param PO tidak dikenal: ${input.param}`)
}

export async function dbListSoByForm(idForm: string): Promise<SoRow[]> {
  await ensureSoBoCompleteColumn()
  const pool = getDbPool()
  const [rows] = await pool.query<Packet[]>(
    `SELECT s.* FROM so s
     INNER JOIN form_details d ON d.id_form_detail = s.id_form_detail
     WHERE d.id_form = ?`,
    [idForm.trim()],
  )
  return rows.map(mapSo)
}

async function assertCanMutateSo(idFormDetail: string, userId?: string) {
  const pool = getDbPool()
  const id = idFormDetail.trim()
  if (!id) throw new Error('id_form_detail wajib diisi')

  const [toolRows] = await pool.query<RowDataPacket[]>(
    `SELECT val_type FROM form_details WHERE id_form_detail = ? LIMIT 1`,
    [id],
  )
  const valType = s(toolRows[0]?.val_type)

  const uid = userId?.trim() ?? ''
  let level = ''
  if (uid) {
    const [userRows] = await pool.query<RowDataPacket[]>(
      `SELECT level FROM users WHERE TRIM(id_users) = ? LIMIT 1`,
      [uid],
    )
    level = s(userRows[0]?.level)
  }

  if (!canMutateSo({ level }, valType)) {
    throw new Error(
      'SO / PR: CAT hanya Counter, VENDOR hanya GA. Super Admin boleh keduanya.',
    )
  }
}

export async function dbMutateSo(input: {
  param: string
  idSo?: string
  idFormDetail: string
  so?: string
  eta?: string
  noteSo?: string
  boComplete?: string
  dateUpdateSo?: string
  idUpdateSo?: string
}): Promise<string> {
  const pool = getDbPool()
  await ensureSoBoCompleteColumn()
  await assertCanMutateSo(input.idFormDetail, input.idUpdateSo)

  if (input.param === ApiParam.deleteSo) {
    const id = input.idSo?.trim() ?? ''
    await backupRowBeforeChange({
      tableName: 'so',
      recordId: id,
      action: 'DELETE',
      userId: input.idUpdateSo,
    })
    await pool.query(`DELETE FROM so WHERE id_so = ?`, [id])
    return 'SO dihapus'
  }
  if (input.param === ApiParam.addSo) {
    await pool.query(
      `INSERT INTO so (id_so, id_form_detail, so, eta, note_so, bo_complete, date_update_so, id_update_so)
       VALUES (?,?,?,?,?,?,?,?)`,
      [
        input.idSo?.trim() || newId(),
        input.idFormDetail,
        emptyToNull(input.so),
        emptyToNull(input.eta),
        emptyToNull(input.noteSo),
        normBoComplete(input.boComplete),
        emptyToNull(input.dateUpdateSo),
        emptyToNull(input.idUpdateSo),
      ],
    )
    return 'SO ditambahkan'
  }
  if (input.param === ApiParam.editSo) {
    const id = input.idSo?.trim() ?? ''
    await backupRowBeforeChange({
      tableName: 'so',
      recordId: id,
      action: 'UPDATE',
      userId: input.idUpdateSo,
    })
    const [r] = await pool.query<ResultSetHeader>(
      `UPDATE so SET so = ?, eta = ?, note_so = ?, bo_complete = ?, date_update_so = ?, id_update_so = ?
       WHERE id_so = ?`,
      [
        emptyToNull(input.so),
        emptyToNull(input.eta),
        emptyToNull(input.noteSo),
        normBoComplete(input.boComplete),
        emptyToNull(input.dateUpdateSo),
        emptyToNull(input.idUpdateSo),
        id,
      ],
    )
    if (r.affectedRows === 0) throw new Error('SO tidak ditemukan')
    return 'SO diperbarui'
  }
  throw new Error(`Param SO tidak dikenal: ${input.param}`)
}

export async function dbListRcvWhByForm(idForm: string): Promise<RcvWhRow[]> {
  await ensureRcvQtyColumns()
  const pool = getDbPool()
  const [rows] = await pool.query<Packet[]>(
    `SELECT r.* FROM rcv_wh r
     INNER JOIN form_details d ON d.id_form_detail = r.id_form_detail
     WHERE d.id_form = ?`,
    [idForm.trim()],
  )
  return rows.map(mapRcvWh)
}

export async function dbMutateRcvWh(input: {
  param: string
  idRcvWh?: string
  idFormDetail: string
  rcvWhDate?: string
  qty?: string
  rcvWhIdInput?: string
  rcvWhDateInput?: string
}): Promise<string> {
  await ensureRcvQtyColumns()
  const pool = getDbPool()
  if (input.param === ApiParam.deleteRcvWh) {
    const id = input.idRcvWh?.trim() ?? ''
    await backupRowBeforeChange({
      tableName: 'rcv_wh',
      recordId: id,
      action: 'DELETE',
      userId: input.rcvWhIdInput,
    })
    await pool.query(`DELETE FROM rcv_wh WHERE id_rcv_wh = ?`, [id])
    return 'Rcv WH dihapus'
  }
  if (input.param === ApiParam.addRcvWh) {
    await pool.query(
      `INSERT INTO rcv_wh (id_rcv_wh, id_form_detail, rcv_wh_date, qty, rcv_wh_id_input, rcv_wh_date_input)
       VALUES (?,?,?,?,?,?)`,
      [
        input.idRcvWh?.trim() || newId(),
        input.idFormDetail,
        emptyToNull(input.rcvWhDate),
        emptyToNull(input.qty),
        emptyToNull(input.rcvWhIdInput),
        emptyToNull(input.rcvWhDateInput),
      ],
    )
    return 'Rcv WH ditambahkan'
  }
  if (input.param === ApiParam.editRcvWh) {
    const id = input.idRcvWh?.trim() ?? ''
    await backupRowBeforeChange({
      tableName: 'rcv_wh',
      recordId: id,
      action: 'UPDATE',
      userId: input.rcvWhIdInput,
    })
    const [r] = await pool.query<ResultSetHeader>(
      `UPDATE rcv_wh SET rcv_wh_date = ?, qty = ?, rcv_wh_id_input = ?, rcv_wh_date_input = ?
       WHERE id_rcv_wh = ?`,
      [
        emptyToNull(input.rcvWhDate),
        emptyToNull(input.qty),
        emptyToNull(input.rcvWhIdInput),
        emptyToNull(input.rcvWhDateInput),
        id,
      ],
    )
    if (r.affectedRows === 0) throw new Error('Rcv WH tidak ditemukan')
    return 'Rcv WH diperbarui'
  }
  throw new Error(`Param Rcv WH tidak dikenal: ${input.param}`)
}

export async function dbListRcvToolByForm(idForm: string): Promise<RcvToolRow[]> {
  await ensureRcvQtyColumns()
  const pool = getDbPool()
  const [rows] = await pool.query<Packet[]>(
    `SELECT r.* FROM rcv_tool r
     INNER JOIN form_details d ON d.id_form_detail = r.id_form_detail
     WHERE d.id_form = ?`,
    [idForm.trim()],
  )
  return rows.map(mapRcvTool)
}

export async function dbMutateRcvTool(input: {
  param: string
  idRcvTool?: string
  idFormDetail: string
  rcvToolDate?: string
  qty?: string
  rcvToolIdInput?: string
  rcvToolDateInput?: string
}): Promise<string> {
  await ensureRcvQtyColumns()
  const pool = getDbPool()
  if (input.param === ApiParam.deleteRcvTool) {
    const id = input.idRcvTool?.trim() ?? ''
    await backupRowBeforeChange({
      tableName: 'rcv_tool',
      recordId: id,
      action: 'DELETE',
      userId: input.rcvToolIdInput,
    })
    await pool.query(`DELETE FROM rcv_tool WHERE id_rcv_tool = ?`, [id])
    return 'Rcv Tool dihapus'
  }
  if (input.param === ApiParam.addRcvTool) {
    await pool.query(
      `INSERT INTO rcv_tool (id_rcv_tool, id_form_detail, rcv_tool_date, qty, rcv_tool_id_input, rcv_tool_date_input)
       VALUES (?,?,?,?,?,?)`,
      [
        input.idRcvTool?.trim() || newId(),
        input.idFormDetail,
        emptyToNull(input.rcvToolDate),
        emptyToNull(input.qty),
        emptyToNull(input.rcvToolIdInput),
        emptyToNull(input.rcvToolDateInput),
      ],
    )
    return 'Rcv Tool ditambahkan'
  }
  if (input.param === ApiParam.editRcvTool) {
    const id = input.idRcvTool?.trim() ?? ''
    await backupRowBeforeChange({
      tableName: 'rcv_tool',
      recordId: id,
      action: 'UPDATE',
      userId: input.rcvToolIdInput,
    })
    const [r] = await pool.query<ResultSetHeader>(
      `UPDATE rcv_tool SET rcv_tool_date = ?, qty = ?, rcv_tool_id_input = ?, rcv_tool_date_input = ?
       WHERE id_rcv_tool = ?`,
      [
        emptyToNull(input.rcvToolDate),
        emptyToNull(input.qty),
        emptyToNull(input.rcvToolIdInput),
        emptyToNull(input.rcvToolDateInput),
        id,
      ],
    )
    if (r.affectedRows === 0) throw new Error('Rcv Tool tidak ditemukan')
    return 'Rcv Tool diperbarui'
  }
  throw new Error(`Param Rcv Tool tidak dikenal: ${input.param}`)
}
