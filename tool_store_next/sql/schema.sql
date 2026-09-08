-- Tool Store — local MySQL schema (Next.js direct DB, no PHP API)
-- Apply:
--   mysql -u root -p < sql/schema.sql
--   or run in MySQL Workbench / phpMyAdmin

CREATE DATABASE IF NOT EXISTS toolstore
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE toolstore;

CREATE TABLE IF NOT EXISTS users (
  id_users        VARCHAR(36)  NOT NULL PRIMARY KEY,
  username        VARCHAR(100) NOT NULL UNIQUE,
  password        VARCHAR(255) NOT NULL,
  nama_user       VARCHAR(150) NOT NULL,
  foto            VARCHAR(255) NULL,
  id_tu           VARCHAR(50)  NULL,
  no_telp         VARCHAR(50)  NULL,
  token           VARCHAR(255) NULL,
  fcm_token       VARCHAR(512) NULL,
  level           VARCHAR(50)  NOT NULL DEFAULT 'USER',
  status          VARCHAR(50)  NULL DEFAULT 'ACTIVE',
  superior_id     VARCHAR(36)  NULL COMMENT 'users.id_users of a SUPERIOR user',
  created_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_users_level (level),
  INDEX idx_users_superior (superior_id)
);

CREATE TABLE IF NOT EXISTS forms (
  id_form                  VARCHAR(36)  NOT NULL PRIMARY KEY,
  form_no                  VARCHAR(100) NULL,
  form_serv_name           VARCHAR(150) NULL,
  form_serv_comment        TEXT NULL,
  form_check_by            VARCHAR(150) NULL,
  form_date_check_by       DATE NULL,
  form_date_serv_name      DATE NULL,
  form_superior_aprd       VARCHAR(50)  NULL,
  form_superior_comment    TEXT NULL,
  form_sadmin_comment      TEXT NULL,
  form_shead_aprd          VARCHAR(50)  NULL,
  form_shead_comment       TEXT NULL,
  from_date_update         DATE NULL,
  form_user_update         VARCHAR(36)  NULL,
  form_date_superior_aprd  DATE NULL,
  form_date_sadmin_comment DATE NULL,
  form_date_shead_aprd     DATE NULL,
  form_milestone           VARCHAR(100) NULL,
  form_status_order        VARCHAR(100) NULL,
  superior_id              VARCHAR(36)  NULL,
  created_at               TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at               TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_forms_milestone (form_milestone),
  INDEX idx_forms_date_update (from_date_update),
  INDEX idx_forms_no (form_no)
);

CREATE TABLE IF NOT EXISTS form_details (
  id_form_detail   VARCHAR(36)  NOT NULL PRIMARY KEY,
  id_form          VARCHAR(36)  NOT NULL,
  form_comment     TEXT NULL,
  pn_group         VARCHAR(100) NULL,
  pn_desc          VARCHAR(255) NULL,
  qty              VARCHAR(50)  NULL,
  explan           TEXT NULL,
  action_note      TEXT NULL,
  form_detail_date DATE NULL,
  form_detail_user VARCHAR(36)  NULL,
  val_type         VARCHAR(50)  NULL,
  part_value       VARCHAR(100) NULL,
  brand            VARCHAR(100) NULL,
  spesifikasi      TEXT NULL,
  created_at       TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_detail_form
    FOREIGN KEY (id_form) REFERENCES forms (id_form)
    ON DELETE CASCADE,
  INDEX idx_detail_form (id_form)
);

CREATE TABLE IF NOT EXISTS po (
  id_po          VARCHAR(36)  NOT NULL PRIMARY KEY,
  id_form_detail VARCHAR(36)  NOT NULL,
  po_no          VARCHAR(100) NULL,
  date_update_po DATE NULL,
  user_update_po VARCHAR(36)  NULL,
  CONSTRAINT fk_po_detail
    FOREIGN KEY (id_form_detail) REFERENCES form_details (id_form_detail)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS so (
  id_so          VARCHAR(36)  NOT NULL PRIMARY KEY,
  id_form_detail VARCHAR(36)  NOT NULL,
  so             VARCHAR(100) NULL,
  eta            DATE NULL,
  note_so        TEXT NULL,
  date_update_so DATE NULL,
  id_update_so   VARCHAR(36)  NULL,
  CONSTRAINT fk_so_detail
    FOREIGN KEY (id_form_detail) REFERENCES form_details (id_form_detail)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS rcv_wh (
  id_rcv_wh         VARCHAR(36) NOT NULL PRIMARY KEY,
  id_form_detail    VARCHAR(36) NOT NULL,
  rcv_wh_date       DATE NULL,
  rcv_wh_id_input   VARCHAR(36) NULL,
  rcv_wh_date_input DATE NULL,
  CONSTRAINT fk_rcv_wh_detail
    FOREIGN KEY (id_form_detail) REFERENCES form_details (id_form_detail)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS rcv_tool (
  id_rcv_tool         VARCHAR(36) NOT NULL PRIMARY KEY,
  id_form_detail      VARCHAR(36) NOT NULL,
  rcv_tool_date       DATE NULL,
  rcv_tool_id_input   VARCHAR(36) NULL,
  rcv_tool_date_input DATE NULL,
  CONSTRAINT fk_rcv_tool_detail
    FOREIGN KEY (id_form_detail) REFERENCES form_details (id_form_detail)
    ON DELETE CASCADE
);

-- Snapshot before UPDATE / DELETE (restore / audit)
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
);

-- Local seed: username=admin / password=admin123 (plain text — local only)
INSERT INTO users (
  id_users, username, password, nama_user, foto, id_tu, no_telp,
  token, level, status, superior_id
)
SELECT
  UUID(), 'admin', 'admin123', 'Super Admin', NULL, 'TU-001', '0800000000',
  NULL, 'SUPERADMIN', 'ACTIVE', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM users WHERE username = 'admin'
);
