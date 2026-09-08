-- Rename leftover purchase-requisition table: po → pr.
-- Does not touch `so` (CAT SO / VENDOR PO documents).
-- mysql -u root toolstore < sql/migrations/004_po_to_pr.sql

SET FOREIGN_KEY_CHECKS = 0;

-- Already migrated
SET @pr_exists := (
  SELECT COUNT(*) FROM information_schema.tables
  WHERE table_schema = DATABASE() AND table_name = 'pr'
);
SET @po_exists := (
  SELECT COUNT(*) FROM information_schema.tables
  WHERE table_schema = DATABASE() AND table_name = 'po'
);

SET @sql := IF(
  @pr_exists = 0 AND @po_exists = 1,
  'RENAME TABLE po TO pr',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @id_po := (
  SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'pr' AND column_name = 'id_po'
);
SET @sql := IF(
  @id_po = 1,
  'ALTER TABLE pr CHANGE COLUMN id_po id_pr VARCHAR(36) NOT NULL',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @po_no := (
  SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'pr' AND column_name = 'po_no'
);
SET @sql := IF(
  @po_no = 1,
  'ALTER TABLE pr CHANGE COLUMN po_no pr_no VARCHAR(100) NULL',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @date_po := (
  SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'pr' AND column_name = 'date_update_po'
);
SET @sql := IF(
  @date_po = 1,
  'ALTER TABLE pr CHANGE COLUMN date_update_po date_update_pr DATE NULL',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @user_po := (
  SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'pr' AND column_name = 'user_update_po'
);
SET @sql := IF(
  @user_po = 1,
  'ALTER TABLE pr CHANGE COLUMN user_update_po user_update_pr VARCHAR(36) NULL',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @fk := (
  SELECT CONSTRAINT_NAME FROM information_schema.TABLE_CONSTRAINTS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'pr'
    AND CONSTRAINT_TYPE = 'FOREIGN KEY'
    AND CONSTRAINT_NAME = 'fk_po_detail'
  LIMIT 1
);
SET @sql := IF(
  @fk IS NOT NULL,
  'ALTER TABLE pr DROP FOREIGN KEY fk_po_detail',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @fk_pr := (
  SELECT CONSTRAINT_NAME FROM information_schema.TABLE_CONSTRAINTS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'pr'
    AND CONSTRAINT_TYPE = 'FOREIGN KEY'
    AND CONSTRAINT_NAME = 'fk_pr_detail'
  LIMIT 1
);
SET @sql := IF(
  @fk_pr IS NULL,
  'ALTER TABLE pr ADD CONSTRAINT fk_pr_detail FOREIGN KEY (id_form_detail) REFERENCES form_details (id_form_detail) ON DELETE CASCADE',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET FOREIGN_KEY_CHECKS = 1;
