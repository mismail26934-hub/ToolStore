import type { Pool, PoolConnection, RowDataPacket } from 'mysql2/promise'
import { getDbPool } from '@/db/pool'

export type BackupAction = 'UPDATE' | 'DELETE'

export type Queryable = Pool | PoolConnection

/** Whitelist: table → primary key column (prevents SQL injection via identifiers). */
export const BACKUP_TABLE_PK = {
  forms: 'id_form',
  form_details: 'id_form_detail',
  pr: 'id_pr',
  so: 'id_so',
  rcv_wh: 'id_rcv_wh',
  rcv_tool: 'id_rcv_tool',
  users: 'id_users',
} as const

export type BackupTableName = keyof typeof BACKUP_TABLE_PK

let tableEnsured = false

const CREATE_DATA_BACKUPS_SQL = `
CREATE TABLE IF NOT EXISTS data_backups (
  id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  table_name  VARCHAR(64)  NOT NULL,
  record_id   VARCHAR(64)  NOT NULL,
  action      ENUM('UPDATE','DELETE') NOT NULL,
  payload     JSON         NOT NULL,
  user_id     VARCHAR(64)  NULL,
  created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_data_backups_table_record (table_name, record_id),
  INDEX idx_data_backups_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
`

export async function ensureDataBackupsTable(
  conn?: Queryable,
): Promise<void> {
  if (tableEnsured) return
  const db = conn ?? getDbPool()
  await db.query(CREATE_DATA_BACKUPS_SQL)
  tableEnsured = true
}

function serializeRow(row: Record<string, unknown>): Record<string, unknown> {
  const out: Record<string, unknown> = {}
  for (const [k, v] of Object.entries(row)) {
    if (v instanceof Date) {
      out[k] = v.toISOString()
    } else if (Buffer.isBuffer(v)) {
      out[k] = v.toString('base64')
    } else {
      out[k] = v as unknown
    }
  }
  return out
}

export async function insertDataBackup(input: {
  tableName: BackupTableName | string
  recordId: string
  action: BackupAction
  payload: Record<string, unknown>
  userId?: string | null
  conn?: Queryable
}): Promise<void> {
  await ensureDataBackupsTable(input.conn)
  const db = input.conn ?? getDbPool()
  await db.query(
    `INSERT INTO data_backups (table_name, record_id, action, payload, user_id)
     VALUES (?, ?, ?, ?, ?)`,
    [
      input.tableName,
      input.recordId,
      input.action,
      JSON.stringify(input.payload),
      (input.userId ?? '').trim() || null,
    ],
  )
}

/** Snapshot one row before UPDATE or DELETE. Returns false if row missing. */
export async function backupRowBeforeChange(input: {
  tableName: BackupTableName
  recordId: string
  action: BackupAction
  userId?: string | null
  conn?: Queryable
}): Promise<boolean> {
  const id = input.recordId.trim()
  if (!id) return false

  const pk = BACKUP_TABLE_PK[input.tableName]
  const db = input.conn ?? getDbPool()
  const [rows] = await db.query<RowDataPacket[]>(
    `SELECT * FROM \`${input.tableName}\` WHERE \`${pk}\` = ? LIMIT 1`,
    [id],
  )
  const row = rows[0]
  if (!row) return false

  await insertDataBackup({
    tableName: input.tableName,
    recordId: id,
    action: input.action,
    payload: serializeRow(row as Record<string, unknown>),
    userId: input.userId,
    conn: input.conn,
  })
  return true
}

/** Before deleting a form: backup form + details + PR/SO/WH/Tool Room (CASCADE). */
export async function backupFormCascadeDelete(input: {
  idForm: string
  userId?: string | null
  conn?: Queryable
}): Promise<void> {
  const idForm = input.idForm.trim()
  if (!idForm) return

  const db = input.conn ?? getDbPool()
  const userId = input.userId

  await backupRowBeforeChange({
    tableName: 'forms',
    recordId: idForm,
    action: 'DELETE',
    userId,
    conn: db,
  })

  const [details] = await db.query<RowDataPacket[]>(
    `SELECT * FROM form_details WHERE id_form = ?`,
    [idForm],
  )

  for (const detail of details) {
    const detailId = String(detail.id_form_detail ?? '').trim()
    if (!detailId) continue

    await insertDataBackup({
      tableName: 'form_details',
      recordId: detailId,
      action: 'DELETE',
      payload: serializeRow(detail as Record<string, unknown>),
      userId,
      conn: db,
    })

    await backupRelatedForDetail({
      idFormDetail: detailId,
      userId,
      conn: db,
    })
  }
}

async function backupRelatedForDetail(input: {
  idFormDetail: string
  userId?: string | null
  conn: Queryable
}): Promise<void> {
  const { idFormDetail, userId, conn: db } = input
  const related: Array<{
    table: BackupTableName
    sql: string
    idKey: string
  }> = [
    { table: 'pr', sql: `SELECT * FROM pr WHERE id_form_detail = ?`, idKey: 'id_pr' },
    { table: 'so', sql: `SELECT * FROM so WHERE id_form_detail = ?`, idKey: 'id_so' },
    {
      table: 'rcv_wh',
      sql: `SELECT * FROM rcv_wh WHERE id_form_detail = ?`,
      idKey: 'id_rcv_wh',
    },
    {
      table: 'rcv_tool',
      sql: `SELECT * FROM rcv_tool WHERE id_form_detail = ?`,
      idKey: 'id_rcv_tool',
    },
  ]

  for (const rel of related) {
    const [rows] = await db.query<RowDataPacket[]>(rel.sql, [idFormDetail])
    for (const row of rows) {
      const rid = String(row[rel.idKey] ?? '').trim()
      if (!rid) continue
      await insertDataBackup({
        tableName: rel.table,
        recordId: rid,
        action: 'DELETE',
        payload: serializeRow(row as Record<string, unknown>),
        userId,
        conn: db,
      })
    }
  }
}

/** Before deleting a tool item: backup detail + related rows (CASCADE). */
export async function backupFormDetailCascadeDelete(input: {
  idFormDetail: string
  userId?: string | null
  conn?: Queryable
}): Promise<void> {
  const id = input.idFormDetail.trim()
  if (!id) return
  const db = input.conn ?? getDbPool()

  await backupRowBeforeChange({
    tableName: 'form_details',
    recordId: id,
    action: 'DELETE',
    userId: input.userId,
    conn: db,
  })
  await backupRelatedForDetail({
    idFormDetail: id,
    userId: input.userId,
    conn: db,
  })
}
