# Tool Store Next (Next.js + TypeScript + TanStack Query)

Tool Store web app using **Next.js App Router** + **local MySQL/MariaDB** (no PHP API required for app data).

## Stack

- Next.js 16 (App Router) + React 19 + TypeScript
- TanStack Query
- MySQL/MariaDB via `mysql2` + Server Actions (`src/server/*`, `src/db/*`)
- Optional Firebase Messaging (web FCM)
- Optional WhatsApp via Whacenter (server-side, milestone 1–7 + reject/hold)

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

# Optional WhatsApp (Whacenter) — jangan commit device id
# WHACENTER_DEVICE_ID=
# WHACENTER_ENABLED=true
# WHACENTER_API_URL=https://app.whacenter.com/api/send
# APP_BASE_URL=http://localhost:3000
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
| WhatsApp Whacenter | Server: milestone change → `src/features/forms/notifyMilestone.ts` |

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
- Optional WhatsApp Whacenter (milestone 1–7)

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
- Label dokumen order (`so` table) mengikuti `val_type`:
  - **CAT** → **SO (Sales Order Internal)**
  - **VENDOR** → **PO (Purchase Order)**
  - Kosong / lain → SO / PR
- **SO / PR** ditampilkan sebagai **mini-tabel** full-width dengan kolom:
  - Number
  - ETA (`dd/mm/yyyy`)
  - Note
  - **BO Complete** (`YES` / `NO`, default `NO`) — SO (CAT) dan PO (VENDOR)
  - Edit
- Isi dokumen itu mengikuti `form_details.val_type`:
  - **CAT** → `COUNTER` (dan SUPERADMIN)
  - **VENDOR** → `GA` (dan SUPERADMIN)
  - Kosong / nilai lain → hanya SUPERADMIN
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
- Setelah **REJECTED BY SUPERIOR**, tombol **Reopen** muncul untuk **SUPERADMIN** atau **superior serviceman** (`users.superior_id` milik `form_serv_name`). Pilih APPROVED → `SUPERIOR APPROVED` (lanjut Service Admin). User SUPERIOR lain tidak bisa reopen.

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
Notifikasi WA: lihat **§11 WhatsApp Whacenter**.

#### Step 5–7 (process — otomatis setelah Dept Head approve)

| Aksi | Milestone | Step |
|------|-----------|------|
| Tambah **SO / PO pada semua item** | `PROCESSING ORDER` | 5. Proses Order |
| WH Received (sebagian tool) | `PARTIAL RECEIVED BY WH/GA` | 6 (partial) |
| WH Received (semua tool) | `RECEIVED BY WH/GA` | 6. WH Received |
| Tool Room (sebagian tool) | `PARTIAL RECEIVED TOOL STORE` | 7 (partial) |
| Tool Room (semua tool) | `RECEIVED TOOL STORE` | 7. Tool Received |
| **SO belum lengkap** atau **semua SO dihapus** (tanpa WH/Tool Room) | `APPROVED BY SERVICE DEPT. HEAD` | tetap / kembali ke step 4 |
| **Semua Tool Room dihapus** | milestone sebelumnya (WH → SO → Dept Head) | mundur dari step 7 |

- Helper: `resolveProcessMilestone` di `src/features/forms/formMilestones.ts`.
- Sync setelah mutate related: `src/features/forms/syncFormProcessMilestone.ts` (fetch server langsung, bukan cache).
- Timeline di detail form memakai `tools` + `so` + `rcvWh` + `rcvTool` (desktop & mobile).
- Milestone process **boleh mundur** jika data related dihapus:
  - semua Tool Room → WH (jika ada) / SO lengkap / Dept Head
  - SO belum di semua item, atau semua SO (tanpa WH/Tool Room) → Dept Head
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
| `src/lib/whacenter.ts` | Client API Whacenter + normalisasi nomor WA |
| `src/features/forms/notifyMilestone.ts` | Mapping step 1–7 + reject/hold → penerima + kirim WA |
| `src/features/forms/notifyMessage.ts` | Template pesan WA (item, qty, link) |
| `src/server/forms.ts` | Hook notify setelah `EDIT DATA FORM` |
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
- Jangan commit `.env` / `.env.local` (termasuk `WHACENTER_DEVICE_ID`).
- Setelah ubah related data, list forms di-invalidate agar chip milestone & timeline refresh.
- Setelah ubah `.env.local`, restart `npm run dev` agar env server terbaca.

### 11. WhatsApp Whacenter (milestone 1–7 + reject/hold)

Notifikasi WhatsApp dikirim **dari server** (bukan browser) setiap kali `forms.form_milestone` **berubah** ke salah satu step 1–7 **atau** reject/hold. Device ID Whacenter hanya di `.env.local`. Gagal kirim WA **tidak** menggagalkan simpan form.

#### Kapan dikirim

Hook: `mutateForm` di `src/server/forms.ts` (setelah `EDIT DATA FORM` sukses).

Termasuk:

- Step 1–4: tombol Approvals (`FormApprovalSection`)
- Step 5–7: sync setelah SO / WH / Tool Room (`syncFormProcessMilestone` → `mutateForm`)
- Reject / Hold: tombol Approvals (Superior REJECT, Service Admin HOLD, Dept Head REJECT)

**Tidak dikirim** jika:

- `WHACENTER_DEVICE_ID` kosong, atau `WHACENTER_ENABLED=false`
- Milestone tidak berubah
- Milestone **mundur** di jalur proses (contoh: semua SO dihapus → kembali ke Dept Head). Reject/hold **tetap** dikirim.
- Milestone bukan step 1–7 dan bukan reject/hold (contoh: DRAFT)
- Tidak ada nomor valid untuk penerima

#### Mapping penerima

Step 1–7 memakai **dua teks**: instruksi (penerima aksi) dan info (serviceman). Nomor yang sama dikirim **sekali**, memakai versi **instruksi** jika orang itu juga penerima aksi.

| Step | Milestone (disimpan) | Instruksi (penerima aksi) | Info (serviceman) |
|------|----------------------|---------------------------|-------------------|
| 1 | `CHECK BY TOOL STORE` | Superior: Mohon Approval | Request Anda sudah diajukan ke superior |
| 2 | `SUPERIOR APPROVED` | Service Admin: Mohon review | Superior sudah approve. Menunggu Review Service Admin |
| 3 | `REVIEWED BY SERVICE ADMIN` | Dept Head: Mohon approval | Service Admin sudah review. Menunggu Approval Dept Head |
| 4 | `APPROVED BY SERVICE DEPT. HEAD` | CAT → Counter; VENDOR → GA; campuran / kosong → Counter/GA: Silahkan Diproses Order. | Dept Head sudah approve. Menunggu proses order tool |
| 5 | `ORDER PROCESSED` | WH: Counter / GA / Counter/GA sudah melakukan proses order. | teks yang sama |
| 6 | `RECEIVED BY WH/GA` / partial | Tool Keeper: Tool sudah diterima WH (semua/sebagian) | teks yang sama |
| 7 | `RECEIVED TOOL STORE` / partial | — (info saja) | Serviceman + superior: Tool sudah diterima tool room (semua/sebagian) |
| — | `REJECTED BY SUPERIOR` | — | Serviceman (satu teks tolak) |
| — | `HOLD BY SERVICE ADMIN` | — | Serviceman + superior |
| — | `REJECTED BY SERVICE DEPT. HEAD` | — | Serviceman + superior |

Step 4–5: `val_type` dihitung dari **semua item** form (`formValTypeMix`). Semua CAT → Counter; semua VENDOR → GA; selain itu Counter **dan** GA.

Nomor duplikat dikirim **sekali**.

#### Lookup Superior dan Serviceman

**Bukan** `forms.superior_id` (kolom itu ada di schema tapi UI save form **tidak mengisinya**, sering kosong).

Rantai yang dipakai:

```
forms.form_serv_name  =  users.id_users (serviceman)
        │
        ▼
users.superior_id     =  users.id_users (user level SUPERIOR)
        │
        ▼
users.no_telp         →  nomor WhatsApp
```

- **Serviceman:** `form_serv_name` dicocokkan ke `users.id_users`, lalu fallback `nama_user` / `username`. Nomor: `users.no_telp`.
- **Superior:** `superior_id` milik serviceman itu → `users.no_telp` atasan.
- **Role** (`SERVICE_ADMIN`, `HEAD_SERVICE`, `COUNTER`, `GA`, `WH`, `TOOL_KEEPER`): semua user dengan `level` itu, `status = ACTIVE` (kosong dianggap ACTIVE), dan `no_telp` terisi.

User tanpa `no_telp` / nomor tidak valid dilewati.

#### Normalisasi nomor

`src/lib/whacenter.ts` → `normalizeWaNumber`:

| Input | Hasil |
|-------|--------|
| `0812…` | `62812…` |
| `812…` | `62812…` |
| `+62812…` | `62812…` |
| `62812…` | `62812…` |

Panjang setelah normalisasi harus 11–15 digit dan diawali `62`. Selain itu skip.

#### Isi pesan WA

Judul memakai ikon tool (emoji 🔧) untuk step 1–7. Reject memakai ⚠️ *Ditolak*; hold memakai ⏸️ *Ditahan*. Baris instruksi (`rule.action`) langsung di bawah banner, lalu data form. Pesan mencakup header form + blok per tool item (maks. 6 item, sisanya “+N item lain”). Comment Superior / Service Admin / Dept Head ikut jika terisi.

Contoh struktur:

```
🔧 Tool Store — Step 4/7
Counter: Silahkan Diproses Order.

Form *0002*  ·  HOLDER / DAMAGE
Serviceman: Mekanik1
Items: *2*
Status: APPROVED BY SERVICE DEPT. HEAD
Qty Order: 22
```

Buka di browser:
https://host/forms?form_no=0002
Dept Head: Lanjut proses
Qty WH Received: 11 (Partial Received)

────────────────
*Item 1 — PN 11*
Qty Order: 11
Description: DESC 11
Price: 1.100.000
…
```

Field kosong (`—`, brand/spec/PO belum ada, qty received 0, comment approval belum diisi) **tidak ditampilkan**.

Comment approval (hanya jika terisi), di bawah Qty Order / tautan:

- Superior → `form_superior_comment`
- Service Admin → `form_sadmin_comment`
- Dept Head → `form_shead_comment`

**Qty / Partial Received**

- Qty Order = jumlah `form_details.qty`
- Qty WH Received = jumlah `rcv_wh.qty`
- Qty Tool Room Received = jumlah `rcv_tool.qty`
- Label `(Partial Received)` hanya jika **Qty Received < Qty Order** dan received > 0
- Received 0 / belum ada → baris dihilangkan

**Link browser:** diletakkan **langsung di bawah Qty Order**, URL di baris sendiri (tanpa markdown). `APP_BASE_URL` harus `https://` + domain agar WhatsApp menjadikannya tautan (bukan `localhost`). `AuthGuard` menyimpan query di `login?from=` agar setelah login tetap expand.

Teks aksi per step (baris di bawah banner):

| Step | Instruksi | Info serviceman |
|------|-----------|-----------------|
| 1 | Superior: Mohon Approval | Request Anda sudah diajukan ke superior |
| 2 | Service Admin: Mohon review | Superior sudah approve. Menunggu Review Service Admin |
| 3 | Dept Head: Mohon approval | Service Admin sudah review. Menunggu Approval Dept Head |
| 4 | Counter / GA / Counter/GA: Silahkan Diproses Order. | Dept Head sudah approve. Menunggu proses order tool |
| 5 | Counter / GA / Counter/GA sudah melakukan proses order. | sama |
| 6 | Tool sudah diterima WH (sebagian/semua) | sama |
| 7 | — | Tool sudah diterima tool room (sebagian/semua) |

#### Konfigurasi env

Di `.env.local` (lihat `.env.example`):

| Variabel | Wajib | Keterangan |
|----------|-------|------------|
| `WHACENTER_DEVICE_ID` | Ya (agar aktif) | Device ID dari dashboard Whacenter. **Jangan commit.** |
| `WHACENTER_ENABLED` | Tidak | Default aktif jika device id ada. Set `false` / `0` / `no` untuk mematikan. |
| `WHACENTER_API_URL` | Tidak | Default `https://app.whacenter.com/api/send` |
| `APP_BASE_URL` | Untuk link WA | URL yang bisa dibuka HP, mis. `http://192.168.1.29:3000`. Wajib `http://` atau `https://`. `localhost` tidak bisa diklik dari HP. |

API: `POST` `application/x-www-form-urlencoded` dengan `device_id`, `number`, `message`. Timeout 15 detik. Device harus **connected** di dashboard Whacenter.

Setelah mengubah env, **restart** `npm run dev`.

#### File

| File | Peran |
|------|--------|
| `src/lib/whacenter.ts` | Enable flag, normalisasi nomor, `POST` ke Whacenter |
| `src/features/forms/notifyMilestone.ts` | Aturan step, lookup penerima, kirim |
| `src/features/forms/notifyMessage.ts` | Template pesan (item, qty, Partial Received, link) |
| `src/lib/safeInternalPath.ts` | Path `login?from=` aman (tetap bawa query form_no) |
| `src/features/forms/formMilestones.ts` | `normFormMilestone`, `milestoneRank` (cek maju/mundur) |
| `src/server/forms.ts` | Baca milestone lama → simpan form → panggil notify |
| `.env.example` | Template variabel Whacenter |
| `.env.local` | Device ID lokal (gitignored) |

#### Log server

| Log | Artinya |
|-----|---------|
| `[whacenter] step N form {id} → X nomor` | Berhasil kirim ke X nomor |
| `[whacenter] skip form …: tidak ada nomor` | Tidak ada `no_telp` valid |
| `[whacenter] send failed` | API Whacenter menolak / device disconnect |
| `[whacenter] notify failed` | Exception di hook; form tetap tersimpan |
