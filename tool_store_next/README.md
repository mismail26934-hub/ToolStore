# Tool Store Next (Next.js + TypeScript + TanStack Query)

Tool Store web app using **Next.js App Router** + **local MySQL/MariaDB** (no PHP API required for app data).

## Stack

- Next.js 16 (App Router) + React 19 + TypeScript
- TanStack Query
- MySQL/MariaDB via `mysql2` + Server Actions (`src/server/*`, `src/db/*`)
- Optional Firebase Messaging (web FCM)

## Quick start

```bash
cd ToolStore/tool_store_next
cp .env.example .env.local
npm install
```

### Database

```bash
mysql -u root < sql/schema.sql
```

`.env.local`:

```env
DATABASE_URL=mysql://root:@127.0.0.1:3306/toolstore
```

Seed login:

- username: `admin`
- password: `admin123`

```bash
npm run dev
```

Open http://localhost:3000

## Data layer

| Area | Implementation |
|---|---|
| Login | `POST /api/auth/login` → `users` |
| Forms / dashboard / export CSV | Server Actions → `forms`, `form_details` |
| Tool items | Server Actions → `form_details` |
| PO / SO / Rcv WH / Rcv Tool | Server Actions → related tables |
| Users / superiors / profile | Server Actions → `users` |
| FCM token | Server Actions → `users.fcm_token` |

Schema: `sql/schema.sql`

## Features

- Dashboard counts + inbox filters
- Forms CRUD, search, date filter, deep link `form_no`
- Approvals + order timeline
- Tool items (BRAND / SPESIFIKASI; Action note dropdown A–D)
- PO / SO / receive cascades
- Export CSV (local)
- Users CRUD + superior picker + My Profile
- Dark mode + ID/EN
- Optional web FCM

---

## Changelog (perubahan terbaru)

Dokumentasi ringkas semua perubahan UI/UX dan perilaku aplikasi di branch Next.js.

### 1. List & navigasi

- Pagination bernomor pada Forms, Users, dan Superiors (bukan “Load more”).
- Desktop: tabel; mobile: card list.
- Superiors: CRUD lengkap + import Excel.
- Users: import Excel dengan preview tabel + checkbox pilih baris (sama untuk Superiors).
- Superior picker/display: tampil **nama + ID TU** (bukan UUID); field form menyimpan `superiorId`, menampilkan nama.
- SuperiorPickField: klik input membuka picker; tombol **×** untuk clear.
- Delete pada edit User / Superior / Form dipindah ke header kanan atas (ikon trash).

### 2. Forms list & tool item block

- Kolom Status + Category pada daftar Forms.
- Detail tool item menampilkan field terkait (price, brand, spesifikasi, explanation, action note, comment, date, dll.).
- **Action note** di detail list ditampilkan dengan label lengkap (bukan hanya kode `A`/`B`/`C`/`D`) via `formatActionNote`.
- Layout tool: tiap item = **block card** (`tool-item-block-card`) dengan grid wrapping (bukan tabel horizontal lebar).
- Field di dalam block punya **border + background** sendiri agar mudah dibaca.
- Data terkait PO / SO / WH / Tool Room digabung ke dalam block (bukan section duplikat besar).

### 3. PO / SO / WH / Tool Room (inline + modal)

- UI inline: label + tombol **+**, nilai + ikon **edit**.
- Add/Edit lewat **modal**; **Delete** hanya di dalam modal (header, kanan judul) agar tidak terklik tidak sengaja.
- Modal actions: **Close** kiri, **Save** kanan.
- **SO / PR** ditampilkan sebagai **mini-tabel** full-width dengan kolom:
  - SO / PR number
  - ETA (`dd/mm/yyyy`)
  - Note SO / PR
  - Edit
- Lock cascade tetap:
  - PO terkunci jika SO sudah ada
  - SO terkunci jika WH sudah ada
  - WH terkunci jika Tool Room sudah ada
- Ikon tombol: CSS `.btn.btn-icon-only` (padding overridden) agar SVG tidak hilang di kotak 28×28.

### 4. Format tanggal

- Standar tampilan & input: **`dd/mm/yyyy`**.
- Helper: `src/lib/dateFormat.ts` (`formatDateDisplay`, `ymdToDmy`, `dmyToYmd`, `maskDmyInput`).
- Komponen `DateInput` dipakai di filter tanggal, form header, export, dan modal ETA / WH / Tool Room.
- Penyimpanan DB tetap `yyyy-MM-dd`.

### 5. Approvals UI

- Tombol Superior / Dept Head: **Approve** (bukan “Act”).
- Tombol Service Admin: **Review**.
- Tanggal Check / Request ditampilkan `dd/mm/yyyy`.

### 6. Order timeline (milestone 1–7)

#### Step 1–4 (approval — otomatis dari UI Approvals)

| Aksi UI | Milestone | Step timeline |
|---------|-----------|---------------|
| **Request Order** (Check / Request) | `CHECK BY TOOL STORE` | 1. Permintaan Order |
| Superior **Approve** | `SUPERIOR APPROVED` | 2. Persetujuan Order 1 |
| Superior **Reject** | `REJECTED BY SUPERIOR` | step 1 + tanda merah |
| Service Admin **Review** → Continue | `REVIEWED BY SERVICE ADMIN` | 3. Review Order |
| Service Admin **Hold** | `HOLD BY SERVICE ADMIN` | step 2 + tanda merah |
| Dept Head **Approve** | `APPROVED BY SERVICE DEPT. HEAD` | 4. Persetujuan Order 2 |
| Dept Head **Reject** | `REJECTED BY SERVICE DEPT. HEAD` | step 3 + tanda merah |

Implementasi: `src/components/FormApprovalSection.tsx` + konstanta `Milestone` di `formMilestones.ts`.

#### Step 5–7 (process — otomatis setelah Dept Head approve)

| Aksi | Milestone | Step |
|------|-----------|------|
| Tambah **SO / PR** | `PROCESSING ORDER` | 5. Proses Order |
| WH Received (sebagian tool) | `PARTIAL RECEIVED BY WH/GA` | 6 (partial) |
| WH Received (semua tool) | `RECEIVED BY WH/GA` | 6. WH Received |
| Tool Room (sebagian tool) | `PARTIAL RECEIVED TOOL STORE` | 7 (partial) |
| Tool Room (semua tool) | `RECEIVED TOOL STORE` | 7. Tool Received |
| **Semua SO dihapus** (tanpa WH/Tool Room) | `APPROVED BY SERVICE DEPT. HEAD` | kembali ke step 4 |
| **Semua Tool Room dihapus** | milestone sebelumnya (WH → SO → Dept Head) | mundur dari step 7 |

- Helper: `resolveProcessMilestone` di `src/features/forms/formMilestones.ts`.
- Sync setelah mutate related: `src/features/forms/syncFormProcessMilestone.ts` (fetch server langsung, bukan cache).
- Timeline di detail form memakai `tools` + `so` + `rcvWh` + `rcvTool` (desktop & mobile).
- Milestone process **boleh mundur** jika data related dihapus:
  - semua Tool Room → WH (jika ada) / SO / Dept Head
  - semua SO (tanpa WH/Tool Room) → Dept Head
  - tidak turun di bawah Dept Head.

#### Ringkasan label timeline (ID)

| Step | Judul | Sub |
|------|-------|-----|
| 1 | Permintaan Order | Request diajukan. |
| 2 | Persetujuan Order 1 | Persetujuan superior. |
| 3 | Review Order | Review service support. |
| 4 | Persetujuan Order 2 | Persetujuan dept head. |
| 5 | Proses Order | Baris tool / pembelian berjalan. |
| 6 | WH Received | Warehouse menerima. |
| 7 | Tool Received | Tool room menerima. |

### 7. Action note (tool item)

- Opsi standar (disimpan di DB sebagai kode `A` / `B` / `C` / `D`):

| Kode | Label |
|------|--------|
| A | Order Small Tool Account |
| B | Order Rep & Maint Account |
| C | Charge Personal Account |
| D | Charge to ... |

- Form **Tambah** (`/tools/new`) dan **Edit** (`/tools/[id]`): field **ACTION NOTE** berupa **dropdown** dengan label lengkap di atas.
- Komponen: `src/components/ActionNoteField.tsx`.
- Helper: `src/lib/actionNotes.ts` (`ACTION_NOTE_OPTIONS`, `normalizeActionNoteCode`, `formatActionNote`).
- Tampilan di detail Forms memakai `formatActionNote` (mis. `A = Order Small Tool Account`).

### 8. File utama yang disentuh

| File | Peran |
|------|--------|
| `src/views/FormsPage.tsx` | List forms, tool blocks, timeline props |
| `src/views/ToolDetailPage.tsx` | Form tambah/edit tool item + Action note dropdown |
| `src/components/ActionNoteField.tsx` | Dropdown Action note (A–D) |
| `src/lib/actionNotes.ts` | Opsi + normalize/format Action note |
| `src/components/ToolRelatedSections.tsx` | Inline PO/SO/WH/Tool Room + modal + sync milestone |
| `src/components/FormApprovalSection.tsx` | Label Approve / Review + tanggal |
| `src/components/DateInput.tsx` | Input tanggal dd/mm/yyyy |
| `src/lib/dateFormat.ts` | Format/parse tanggal |
| `src/features/forms/formMilestones.ts` | Konstanta + resolve process milestone |
| `src/features/forms/orderTimeline.ts` | Hitung step timeline |
| `src/features/forms/syncFormProcessMilestone.ts` | Update milestone setelah related mutate |
| `src/db/backup.ts` | Snapshot row sebelum UPDATE/DELETE → `data_backups` |
| `src/app/globals.css` | Card border, icon buttons, related table, dll. |

### 9. Data backup (UPDATE / DELETE)

- Setiap **update** dan **delete** menyimpan snapshot baris **sebelum** berubah ke tabel `data_backups`.
- Kolom: `table_name`, `record_id`, `action` (`UPDATE`|`DELETE`), `payload` (JSON), `user_id`, `created_at`.
- Helper: `src/db/backup.ts` (`backupRowBeforeChange`, `backupFormCascadeDelete`, `backupFormDetailCascadeDelete`).
- Tabel dibuat otomatis saat backup pertama (`CREATE TABLE IF NOT EXISTS`), atau:
  - fresh install: sudah ada di `sql/schema.sql`
  - DB lama: `mysql -u root toolstore < sql/migrations/001_data_backups.sql`
- Cakupan: forms (+ cascade detail/PO/SO/WH/Tool Room), form_details (+ related), po, so, rcv_wh, rcv_tool, users (termasuk update via import Excel).
- Bukan UI restore — snapshot untuk audit / restore manual dari JSON.

### 10. Catatan teknis

- Branch kerja Next biasanya: `feat/tool-store-next` (repo nested `ToolStore/`).
- Jangan commit `.env` / `.env.local`.
- Setelah ubah related data, list forms di-invalidate agar chip milestone & timeline refresh.
