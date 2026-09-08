-- Qty received on WH / Tool Room (can differ from form_details.qty).
-- mysql -u root toolstore < sql/migrations/002_rcv_qty.sql

ALTER TABLE rcv_wh
  ADD COLUMN qty VARCHAR(50) NULL AFTER rcv_wh_date;

ALTER TABLE rcv_tool
  ADD COLUMN qty VARCHAR(50) NULL AFTER rcv_tool_date;
