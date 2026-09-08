-- Add data_backups for existing Tool Store DBs
-- Apply: mysql -u root toolstore < sql/migrations/001_data_backups.sql

USE toolstore;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
