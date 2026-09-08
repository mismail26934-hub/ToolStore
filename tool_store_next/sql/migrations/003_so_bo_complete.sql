-- BO Complete (YES/NO) on SO / PO rows (`so` table).
-- mysql -u root toolstore < sql/migrations/003_so_bo_complete.sql

ALTER TABLE so
  ADD COLUMN bo_complete VARCHAR(10) NULL DEFAULT 'NO' AFTER note_so;
