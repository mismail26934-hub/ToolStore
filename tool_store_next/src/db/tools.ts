import type { ResultSetHeader, RowDataPacket } from 'mysql2'
import { ApiParam } from '@/api/params'
import { emptyToNull, newId, s } from '@/db/helpers'
import { getDbPool } from '@/db/pool'
import type { MutatingResult, ToolDetailRow } from '@/types/models'

export type ToolDetailPayload = {
  idFormDetail?: string
  idForm: string
  formComment?: string
  pnGroup?: string
  pnDesc?: string
  qty?: string
  explan?: string
  actionNote?: string
  valType?: string
  partValue?: string
  formDetailDate?: string
  formDetailUser?: string
  brand?: string
  spesifikasi?: string
}

type ToolPacket = RowDataPacket & Record<string, unknown>

function mapTool(row: ToolPacket): ToolDetailRow {
  return {
    idFormDetail: s(row.id_form_detail),
    idForm: s(row.id_form),
    formComment: s(row.form_comment),
    pnGroup: s(row.pn_group),
    pnDesc: s(row.pn_desc),
    qty: s(row.qty),
    explan: s(row.explan),
    actionNote: s(row.action_note),
    formDetailDate: s(row.form_detail_date),
    formDetailUser: s(row.form_detail_user),
    valType: s(row.val_type),
    partValue: s(row.part_value),
    brand: s(row.brand),
    spesifikasi: s(row.spesifikasi),
  }
}

export async function dbListTools(idForm: string): Promise<ToolDetailRow[]> {
  const pool = getDbPool()
  const [rows] = await pool.query<ToolPacket[]>(
    `SELECT * FROM form_details WHERE id_form = ? ORDER BY created_at ASC`,
    [idForm.trim()],
  )
  return rows.map(mapTool)
}

export async function dbMutateTool(
  param: string,
  payload: ToolDetailPayload,
): Promise<MutatingResult<ToolDetailRow>> {
  const pool = getDbPool()
  const idForm = payload.idForm.trim()
  if (!idForm) throw new Error('id_form wajib diisi')

  if (param === ApiParam.deleteTool) {
    const id = payload.idFormDetail?.trim() ?? ''
    if (!id) throw new Error('id_form_detail wajib diisi')
    await pool.query(`DELETE FROM form_details WHERE id_form_detail = ?`, [id])
  } else if (param === ApiParam.addTool) {
    const id = payload.idFormDetail?.trim() || newId()
    await pool.query(
      `INSERT INTO form_details (
        id_form_detail, id_form, form_comment, pn_group, pn_desc, qty, explan,
        action_note, form_detail_date, form_detail_user, val_type, part_value,
        brand, spesifikasi
      ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      [
        id,
        idForm,
        emptyToNull(payload.formComment),
        emptyToNull(payload.pnGroup),
        emptyToNull(payload.pnDesc),
        emptyToNull(payload.qty),
        emptyToNull(payload.explan),
        emptyToNull(payload.actionNote),
        emptyToNull(payload.formDetailDate),
        emptyToNull(payload.formDetailUser),
        emptyToNull(payload.valType),
        emptyToNull(payload.partValue),
        emptyToNull(payload.brand),
        emptyToNull(payload.spesifikasi),
      ],
    )
  } else if (param === ApiParam.editTool) {
    const id = payload.idFormDetail?.trim() ?? ''
    if (!id) throw new Error('id_form_detail wajib diisi')
    const [result] = await pool.query<ResultSetHeader>(
      `UPDATE form_details SET
        form_comment = ?, pn_group = ?, pn_desc = ?, qty = ?, explan = ?,
        action_note = ?, form_detail_date = ?, form_detail_user = ?,
        val_type = ?, part_value = ?, brand = ?, spesifikasi = ?
       WHERE id_form_detail = ?`,
      [
        emptyToNull(payload.formComment),
        emptyToNull(payload.pnGroup),
        emptyToNull(payload.pnDesc),
        emptyToNull(payload.qty),
        emptyToNull(payload.explan),
        emptyToNull(payload.actionNote),
        emptyToNull(payload.formDetailDate),
        emptyToNull(payload.formDetailUser),
        emptyToNull(payload.valType),
        emptyToNull(payload.partValue),
        emptyToNull(payload.brand),
        emptyToNull(payload.spesifikasi),
        id,
      ],
    )
    if (result.affectedRows === 0) throw new Error('Tool item tidak ditemukan')
  } else if (param !== ApiParam.viewTool) {
    throw new Error(`Param tool tidak dikenal: ${param}`)
  }

  const list = await dbListTools(idForm)
  return {
    list,
    statusValue: '1',
    serverMessage: 'Sukses',
  }
}
