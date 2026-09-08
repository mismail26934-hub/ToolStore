import type { ResultSetHeader, RowDataPacket } from 'mysql2'
import { getDbPool } from '@/db/pool'
import { emptyToNull, newId, s } from '@/db/helpers'
import {
  backupFormCascadeDelete,
  backupRowBeforeChange,
} from '@/db/backup'
import type { DashboardCounts, FormRow, PaginatedList } from '@/types/models'
import { FORM_PAGE_SIZE } from '@/api/params'
import { ApiParam } from '@/api/params'
import type { FormListFilters, SaveFormInput } from '@/features/forms/types'
import { nameNotId } from '@/lib/displayLabel'

type FormPacket = RowDataPacket & Record<string, unknown>

const SERV_USER_JOIN = `LEFT JOIN users serv ON TRIM(serv.id_users) = TRIM(forms.form_serv_name)`
const CHECK_USER_JOIN = `LEFT JOIN users chk ON TRIM(chk.id_users) = TRIM(forms.form_check_by)`

const SERV_NAME_LABEL_SQL = `COALESCE(NULLIF(TRIM(serv.nama_user), ''), NULLIF(TRIM(serv.username), ''))`
const CHECK_NAME_LABEL_SQL = `COALESCE(NULLIF(TRIM(chk.nama_user), ''), NULLIF(TRIM(chk.username), ''))`

function servicemanSearchSql(): string {
  return `(
    forms.form_serv_name LIKE ?
    OR EXISTS (
      SELECT 1 FROM users u
      WHERE TRIM(u.id_users) = TRIM(forms.form_serv_name)
        AND (u.nama_user LIKE ? OR u.username LIKE ?)
    )
  )`
}

function servicemanSearchParams(kw: string): string[] {
  const like = `%${kw}%`
  return [like, like, like]
}

function mapForm(row: FormPacket): FormRow {
  const storedServ = s(row.form_serv_name)
  const storedCheck = s(row.form_check_by)
  return {
    idForm: s(row.id_form),
    formNo: s(row.form_no),
    formServName: storedServ,
    formServNameLabel: nameNotId(s(row.form_serv_name_label)),
    formServComment: s(row.form_serv_comment),
    formCheckBy: storedCheck,
    formCheckByLabel: nameNotId(s(row.form_check_by_label)),
    formDateCheckBy: s(row.form_date_check_by),
    formDateServName: s(row.form_date_serv_name),
    formSuperiorAprd: s(row.form_superior_aprd),
    formSuperiorComment: s(row.form_superior_comment),
    formSadminComment: s(row.form_sadmin_comment),
    formSheadAprd: s(row.form_shead_aprd),
    formSheadComment: s(row.form_shead_comment),
    fromDateUpdate: s(row.from_date_update),
    formUserUpdate: s(row.form_user_update),
    formDateSuperiorAprd: s(row.form_date_superior_aprd),
    formDateSadminComment: s(row.form_date_sadmin_comment),
    formDateSheadAprd: s(row.form_date_shead_aprd),
    formMilestone: s(row.form_milestone),
    formStatusOrder: s(row.form_status_order),
    superiorId: s(row.superior_id),
    toolItemCount: Number(row.tool_item_count ?? 0) || 0,
  }
}

export async function dbListForms(
  filters: FormListFilters = {},
): Promise<PaginatedList<FormRow>> {
  const pool = getDbPool()
  const page = Math.max(1, filters.page ?? 1)
  const limit = Math.max(1, filters.limit ?? FORM_PAGE_SIZE)
  const offset = (page - 1) * limit

  const where: string[] = []
  const params: unknown[] = []

  const from = filters.fromDateUpdate?.trim() ?? ''
  if (from) {
    const to = (filters.toDateUpdate?.trim() || from)
    where.push(
      'forms.from_date_update IS NOT NULL AND forms.from_date_update BETWEEN ? AND ?',
    )
    params.push(from, to)
  }

  const kw = filters.keyword?.trim() ?? ''
  if (kw) {
    const field = (filters.searchField ?? 'all').trim()
    if (field === 'formNo') {
      where.push('forms.form_no LIKE ?')
      params.push(`%${kw}%`)
    } else if (field === 'serviceman') {
      where.push(servicemanSearchSql())
      params.push(...servicemanSearchParams(kw))
    } else if (field === 'status') {
      where.push('forms.form_status_order LIKE ?')
      params.push(`%${kw}%`)
    } else if (field === 'idForm') {
      where.push('forms.id_form LIKE ?')
      params.push(`%${kw}%`)
    } else if (field === 'pnGroup' || field === 'pnDesc') {
      const col = field === 'pnGroup' ? 'pn_group' : 'pn_desc'
      where.push(
        `EXISTS (SELECT 1 FROM form_details d WHERE d.id_form = forms.id_form AND d.${col} LIKE ?)`,
      )
      params.push(`%${kw}%`)
    } else {
      where.push(
        `(forms.form_no LIKE ? OR ${servicemanSearchSql()} OR forms.form_status_order LIKE ? OR forms.id_form LIKE ? OR forms.form_milestone LIKE ?)`,
      )
      params.push(
        `%${kw}%`,
        ...servicemanSearchParams(kw),
        `%${kw}%`,
        `%${kw}%`,
        `%${kw}%`,
      )
    }
  }

  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : ''

  const [countRows] = await pool.query<RowDataPacket[]>(
    `SELECT COUNT(*) AS total FROM forms ${whereSql}`,
    params,
  )
  const total = Number(countRows[0]?.total ?? 0)

  const [rows] = await pool.query<FormPacket[]>(
    `SELECT forms.*,
      (SELECT COUNT(*) FROM form_details d WHERE d.id_form = forms.id_form) AS tool_item_count,
      ${SERV_NAME_LABEL_SQL} AS form_serv_name_label,
      ${CHECK_NAME_LABEL_SQL} AS form_check_by_label
     FROM forms
     ${SERV_USER_JOIN}
     ${CHECK_USER_JOIN}
     ${whereSql}
     ORDER BY COALESCE(forms.from_date_update, forms.created_at) DESC, forms.created_at DESC
     LIMIT ? OFFSET ?`,
    [...params, limit, offset],
  )

  return { items: rows.map(mapForm), total }
}

export async function dbGetFormById(idForm: string): Promise<FormRow | null> {
  const pool = getDbPool()
  const [rows] = await pool.query<FormPacket[]>(
    `SELECT forms.*,
      (SELECT COUNT(*) FROM form_details d WHERE d.id_form = forms.id_form) AS tool_item_count,
      ${SERV_NAME_LABEL_SQL} AS form_serv_name_label,
      ${CHECK_NAME_LABEL_SQL} AS form_check_by_label
     FROM forms
     ${SERV_USER_JOIN}
     ${CHECK_USER_JOIN}
     WHERE forms.id_form = ?
     LIMIT 1`,
    [idForm.trim()],
  )
  return rows[0] ? mapForm(rows[0]) : null
}

export async function dbDashboardCounts(): Promise<DashboardCounts> {
  const pool = getDbPool()
  const [rows] = await pool.query<RowDataPacket[]>(
    `SELECT
      SUM(CASE WHEN form_milestone IS NULL OR TRIM(form_milestone) = '' OR UPPER(TRIM(form_milestone)) = 'DRAFT' THEN 1 ELSE 0 END) AS draft,
      SUM(CASE WHEN UPPER(REPLACE(form_milestone, '.', '')) = 'CHECK BY TOOL STORE' THEN 1 ELSE 0 END) AS superior_approval,
      SUM(CASE WHEN UPPER(REPLACE(form_milestone, '.', '')) = 'SUPERIOR APPROVED' THEN 1 ELSE 0 END) AS service_admin,
      SUM(CASE WHEN UPPER(REPLACE(form_milestone, '.', '')) = 'REVIEWED BY SERVICE ADMIN' THEN 1 ELSE 0 END) AS dept_head,
      SUM(CASE WHEN UPPER(REPLACE(form_milestone, '.', '')) IN ('APPROVED BY SERVICE DEPT HEAD', 'APPROVED BY SERVICE DEPT. HEAD') THEN 1 ELSE 0 END) AS counter_ga,
      SUM(CASE WHEN UPPER(REPLACE(form_milestone, '.', '')) IN (
        'RECEIVED BY WH/GA',
        'PARTIAL RECEIVED BY WH/GA',
        'PARTIAL RECEIVED TOOL STORE',
        'PARTIAL RECEIVED BY TOOL STORE'
      ) THEN 1 ELSE 0 END) AS tool_received_wh_ga,
      SUM(CASE WHEN UPPER(REPLACE(form_milestone, '.', '')) = 'HOLD BY SERVICE ADMIN' THEN 1 ELSE 0 END) AS hold_count,
      SUM(CASE WHEN UPPER(REPLACE(form_milestone, '.', '')) = 'REJECTED BY SUPERIOR' THEN 1 ELSE 0 END) AS rejected_superior,
      SUM(CASE WHEN UPPER(REPLACE(form_milestone, '.', '')) = 'REJECTED BY SERVICE DEPT HEAD' THEN 1 ELSE 0 END) AS rejected_dept
     FROM forms`,
  )
  const r = rows[0] ?? {}
  const draft = Number(r.draft ?? 0)
  const superiorApproval = Number(r.superior_approval ?? 0)
  const serviceAdmin = Number(r.service_admin ?? 0)
  const deptHead = Number(r.dept_head ?? 0)
  const counterGa = Number(r.counter_ga ?? 0)
  const toolReceivedWhGa = Number(r.tool_received_wh_ga ?? 0)
  const hold = Number(r.hold_count ?? 0)
  const rejectedSuperior = Number(r.rejected_superior ?? 0)
  const rejectedDept = Number(r.rejected_dept ?? 0)
  return {
    draft,
    superiorApproval,
    serviceAdmin,
    deptHead,
    counterGa,
    toolReceivedWhGa,
    hold,
    rejectedSuperior,
    rejectedDept,
    notificationTotal:
      draft +
      superiorApproval +
      serviceAdmin +
      deptHead +
      counterGa +
      toolReceivedWhGa,
  }
}

export async function dbMutateForm(input: SaveFormInput): Promise<string> {
  const pool = getDbPool()
  const param = input.param

  if (param === ApiParam.deleteForm) {
    const id = input.idForm?.trim() ?? ''
    if (!id) throw new Error('id_form wajib diisi')
    const conn = await pool.getConnection()
    try {
      await conn.beginTransaction()
      await backupFormCascadeDelete({
        idForm: id,
        userId: input.formUserUpdate,
        conn,
      })
      await conn.query(`DELETE FROM forms WHERE id_form = ?`, [id])
      await conn.commit()
    } catch (err) {
      await conn.rollback()
      throw err
    } finally {
      conn.release()
    }
    return 'Form dihapus'
  }

  const fields = {
    form_no: emptyToNull(input.formNo),
    form_serv_name: await resolveStoredUserId(emptyToNull(input.formServName)),
    form_check_by: await resolveStoredUserId(emptyToNull(input.formCheckBy)),
    form_date_check_by: emptyToNull(input.formDateCheckBy),
    form_date_serv_name: emptyToNull(input.formDateServName),
    form_serv_comment: emptyToNull(input.formServComment),
    form_superior_aprd: emptyToNull(input.formSuperiorAprd),
    form_superior_comment: emptyToNull(input.formSuperiorComment),
    form_sadmin_comment: emptyToNull(input.formSadminComment),
    form_milestone: emptyToNull(input.formMilestone),
    form_status_order: emptyToNull(input.formStatusOrder),
    form_shead_aprd: emptyToNull(input.formSheadAprd),
    form_shead_comment: emptyToNull(input.formSheadComment),
    from_date_update: emptyToNull(input.fromDateUpdate),
    form_user_update: emptyToNull(input.formUserUpdate),
  }

  if (param === ApiParam.addForm) {
    const id = input.idForm?.trim() || newId()
    await pool.query(
      `INSERT INTO forms (
        id_form, form_no, form_serv_name, form_check_by, form_date_check_by,
        form_date_serv_name, form_serv_comment, form_superior_aprd, form_superior_comment,
        form_sadmin_comment, form_milestone, form_status_order, form_shead_aprd,
        form_shead_comment, from_date_update, form_user_update
      ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      [
        id,
        fields.form_no,
        fields.form_serv_name,
        fields.form_check_by,
        fields.form_date_check_by,
        fields.form_date_serv_name,
        fields.form_serv_comment,
        fields.form_superior_aprd,
        fields.form_superior_comment,
        fields.form_sadmin_comment,
        fields.form_milestone,
        fields.form_status_order,
        fields.form_shead_aprd,
        fields.form_shead_comment,
        fields.from_date_update,
        fields.form_user_update,
      ],
    )
    return 'Form ditambahkan'
  }

  if (param === ApiParam.editForm) {
    const id = input.idForm?.trim() ?? ''
    if (!id) throw new Error('id_form wajib diisi')
    await backupRowBeforeChange({
      tableName: 'forms',
      recordId: id,
      action: 'UPDATE',
      userId: input.formUserUpdate,
    })
    const [result] = await pool.query<ResultSetHeader>(
      `UPDATE forms SET
        form_no = ?, form_serv_name = ?, form_check_by = ?, form_date_check_by = ?,
        form_date_serv_name = ?, form_serv_comment = ?, form_superior_aprd = ?,
        form_superior_comment = ?, form_sadmin_comment = ?, form_milestone = ?,
        form_status_order = ?, form_shead_aprd = ?, form_shead_comment = ?,
        from_date_update = ?, form_user_update = ?,
        form_date_superior_aprd = IF(? IS NOT NULL AND form_date_superior_aprd IS NULL, CURDATE(), form_date_superior_aprd),
        form_date_sadmin_comment = IF(? IS NOT NULL AND form_date_sadmin_comment IS NULL, CURDATE(), form_date_sadmin_comment),
        form_date_shead_aprd = IF(? IS NOT NULL AND form_date_shead_aprd IS NULL, CURDATE(), form_date_shead_aprd)
      WHERE id_form = ?`,
      [
        fields.form_no,
        fields.form_serv_name,
        fields.form_check_by,
        fields.form_date_check_by,
        fields.form_date_serv_name,
        fields.form_serv_comment,
        fields.form_superior_aprd,
        fields.form_superior_comment,
        fields.form_sadmin_comment,
        fields.form_milestone,
        fields.form_status_order,
        fields.form_shead_aprd,
        fields.form_shead_comment,
        fields.from_date_update,
        fields.form_user_update,
        fields.form_superior_aprd,
        fields.form_sadmin_comment,
        fields.form_shead_aprd,
        id,
      ],
    )
    if (result.affectedRows === 0) throw new Error('Form tidak ditemukan')
    return 'Form diperbarui'
  }

  throw new Error(`Param form tidak dikenal: ${param}`)
}

async function resolveStoredUserId(
  value: string | null,
): Promise<string | null> {
  if (value == null) return null
  const pool = getDbPool()
  const [rows] = await pool.query<RowDataPacket[]>(
    `SELECT id_users FROM users
     WHERE id_users = ? OR nama_user = ? OR username = ?
     ORDER BY CASE
       WHEN id_users = ? THEN 0
       WHEN nama_user = ? THEN 1
       ELSE 2
     END
     LIMIT 1`,
    [value, value, value, value, value],
  )
  return s(rows[0]?.id_users) || value
}

export async function dbExportFormDetails(input: {
  idForm?: string
  fromDateUpdate?: string
  toDateUpdate?: string
}): Promise<
  Array<Record<string, string>>
> {
  const pool = getDbPool()
  const where: string[] = []
  const params: unknown[] = []

  if (input.idForm?.trim()) {
    where.push('f.id_form = ?')
    params.push(input.idForm.trim())
  }
  const from = input.fromDateUpdate?.trim() ?? ''
  if (from) {
    const to = input.toDateUpdate?.trim() || from
    where.push('f.from_date_update BETWEEN ? AND ?')
    params.push(from, to)
  }

  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : ''
  const [rows] = await pool.query<RowDataPacket[]>(
    `SELECT
      f.form_no,
      COALESCE(NULLIF(TRIM(serv.nama_user), ''), NULLIF(TRIM(serv.username), ''), f.form_serv_name) AS form_serv_name,
      f.form_milestone, f.form_status_order,
      f.from_date_update, d.pn_group, d.pn_desc, d.qty, d.brand, d.spesifikasi,
      d.explan, d.action_note, d.val_type, d.part_value
     FROM forms f
     LEFT JOIN users serv ON TRIM(serv.id_users) = TRIM(f.form_serv_name)
     LEFT JOIN form_details d ON d.id_form = f.id_form
     ${whereSql}
     ORDER BY f.form_no, d.pn_group`,
    params,
  )

  return rows.map((r) => ({
    form_no: s(r.form_no),
    form_serv_name: s(r.form_serv_name),
    form_milestone: s(r.form_milestone),
    form_status_order: s(r.form_status_order),
    from_date_update: s(r.from_date_update),
    pn_group: s(r.pn_group),
    pn_desc: s(r.pn_desc),
    qty: s(r.qty),
    brand: s(r.brand),
    spesifikasi: s(r.spesifikasi),
    explan: s(r.explan),
    action_note: s(r.action_note),
    val_type: s(r.val_type),
    part_value: s(r.part_value),
  }))
}
