# Rencana Refactor Bertahap — Tool Store App

Dokumen ini merencanakan perbaikan struktur kode **tanpa mengubah perilaku aplikasi** (UI, alur login, API contract, Redux state shape, dan string parameter PHP tetap sama).

**Prinsip kerja**

1. Satu PR / satu fase = satu jenis perubahan (move/extract/rename), bukan campur fitur baru.
2. Setelah setiap fase: `flutter analyze` bersih + smoke test manual checklist di bawah.
3. Refactor “strangler”: file lama boleh re-export / delegate ke file baru agar diff kecil.
4. **Jangan** mengubah: URL path, nama field FormData, nilai `param*` ke backend, urutan dispatch Redux, atau logika milestone/timeline.

---

## Snapshot kode saat ini (baseline)

| Area | File / pola | Ukuran / cakupan | Masalah utama |
|------|-------------|------------------|---------------|
| God screen | `lib/view/menu/tool/tool_data.dart` | ~5.800 baris | Sulit navigasi, review, parallel work |
| Form besar | `lib/view/menu/user/user_form_input.dart` | ~1.270 baris | Sama |
| API + thunk | `lib/model/post_get_data.dart` (barrel) | ~30 baris export | Thunk di `model/thunks/`, fetch di `model/repositories/` |
| Global state | `lib/view/var/var.dart` | 22 file meng-import | Coupling, sulit test |
| Duplikat UI | `_PinnedSearchHeaderDelegate` | `tool_data` + `user_data` | Drift saat edit satu sisi |
| Infra baik | `api_client.dart`, Redux, `l10n`, `theme` | Sudah modular | Jadikan pola untuk fase lanjut |
| Test | — | 0 file `*_test.dart` | Tidak ada safety net otomatis |

---

## Matriks risiko (legend)

| Level | Arti | Mitigasi wajib |
|-------|------|----------------|
| **Rendah** | Move/rename murni, tidak ubah runtime | `flutter analyze` + 1 smoke path |
| **Sedang** | Extract widget/class; signature public sama | Smoke + bandingkan screenshot/list |
| **Tinggi** | Sentuh global state, form controllers, Redux thunk | Fase kecil, feature flag opsional, checklist panjang |
| **Kritis** | Ubah alur auth / preload / parsing API | Hanya setelah test harness ada; defer jika ragu |

**Estimasi effort** (1 dev familiar codebase): **S** = 0.5–1 hari, **M** = 2–4 hari, **L** = 1–2 minggu.

---

## Fase 0 — Safety net minimal (prioritas tertinggi, fondasi)

**Tujuan:** Memungkinkan refactor berikutnya terdeteksi tanpa mengubah production behavior.

| # | Task | Effort | Risiko | Catatan |
|---|------|--------|--------|---------|
| 0.1 | Tambah `test/api_client_test.dart`: `withAuthFields`, `resolveDioException` (mock Dio tidak wajib di 0.1) | S | Rendah | Tidak sentuh UI |
| 0.2 | Tambah `test/post_list_test.dart` atau golden parse JSON sample (fixture dari response API nyata, disanitize) | M | Rendah | Fixture = dokumentasi + regresi parse |
| 0.3 | Dokumen smoke checklist (lihat akhir dokumen) di `docs/SMOKE_TEST.md` | S | Rendah | Manual, wajib tiap PR refactor |
| 0.4 | CI lokal: script `flutter analyze` + `flutter test` (opsional di pipeline) | S | Rendah | |

**Deliverable:** Test hijau; perilaku app identik.

**Defer:** Widget test penuh untuk `ToolData` (terlalu besar tanpa extract dulu).

---

## Fase 1 — Hygiene & konfigurasi (quick wins)

**Tujuan:** Readability tanpa sentuh logika bisnis.

| # | Task | Effort | Risiko | Verifikasi |
|---|------|--------|--------|------------|
| 1.1 | `ApiUrl`: pisah `baseUrl` + `--dart-define=API_BASE` (default = nilai sekarang) | S | Rendah | Login + 1 list load |
| 1.2 | Rename folder/file typo **tanpa** ubah import path publik sekaligus: buat alias `export` dulu (`funct.dart` → tetap export dari `navigation_helpers.dart` mis.) | M | Sedang | Full smoke |
| 1.3 | Konsolidasi typo nama: `contSuperrior` → tambah getter alias `contSuperior` (deprecate comment) | S | Rendah | Compile only |
| 1.4 | Pisah `var.dart` menjadi file re-export: `session_vars.dart`, `form_controllers.dart`, `api_params.dart` — isi **identik**, `var.dart` hanya `export` | M | Sedang | 22 import tetap ke `var.dart` |

**Urutan:** 1.1 → 1.4 → 1.2 → 1.3

**Behavior:** URL efektif sama jika define tidak di-set; semua symbol global tetap ada.

---

## Fase 2 — Extract UI duplikat & widget kecil

**Tujuan:** Kurangi ukuran file tanpa mengubah tree widget (struktur visual sama).

| # | Task | Effort | Risiko | Verifikasi |
|---|------|--------|--------|------------|
| 2.1 | Extract `_PinnedSearchHeaderDelegate` → `lib/view/custom/navbar/pinned_search_header.dart` | S | Rendah | User list + Tool list search pin |
| 2.2 | Extract `_OrderTimelineViewModel` + widget timeline → `tool_order_timeline.dart` | M | Sedang | Expand card, milestone warna |
| 2.3 | Extract skeleton builders yang inline di `tool_data` ke file di `shimmer/` (sudah ada `skeletons.dart`) | S | Rendah | Loading state |
| 2.4 | Extract dialog picker duplikat pola (`_SuperiorPickerDialog`, `_ToolUserPickerDialog`) ke base generic | M | Sedang | Pilih superior / user di form |

**Target ukuran setelah fase 2:** `tool_data.dart` turun ~15–25% (estimasi 800–1200 baris pindah).

**Risiko utama:** `shouldRebuild` / key sliver — bandingkan scroll + sticky header.

---

## Fase 3 — Pecah `tool_data.dart` (prioritas readability)

**Tujuan:** Satu file = satu concern; **public API** class `ToolData` tidak berubah.

Struktur target (contoh):

```
lib/view/menu/tool/
  tool_data.dart              # StatefulWidget + orchestration (~400–800 baris)
  tool_data_list.dart         # Sliver list + pagination
  tool_data_search.dart       # filter / search field
  tool_data_form_card.dart    # expandable card per form
  tool_data_detail_sections/  # PO, SO, WH, Tool receive sections
  tool_order_timeline.dart    # dari fase 2
```

| # | Task | Effort | Risiko | Verifikasi |
|---|------|--------|--------|------------|
| 3.1 | Extract **private** methods + widgets ke part files (`part 'tool_data_list.dart';`) dulu | M | Sedang | Minim diff git |
| 3.2 | Pindah ke file terpisah penuh (hapus `part`) | L | Sedang | Sama |
| 3.3 | Extract logic murni (filter milestone, hitung timeline) ke fungsi top-level **pure** di `tool_data_logic.dart` | M | Sedang | Unit test logic tanpa widget |
| 3.4 | Ulangi pola untuk `user_data.dart` (~700 baris) | M | Sedang | User CRUD list |

**Behavior:** Parameter constructor `ToolData` (filter milestone, `initialExpandedFormId`, dll.) tidak berubah.

**Risiko tinggi jika:** Mengubah `StoreConnector` `distinct` / equality ViewModel — test timeline dan lazy load.

---

## Fase 4 — Pecah `post_get_data.dart` & perkuat model layer

**Tujuan:** API layer ter-test; Redux thunk tipis.

| # | Task | Effort | Risiko | Verifikasi |
|---|------|--------|--------|------------|
| 4.1 | Extract parser: `ParsedFormListResult`, dll. → `lib/model/parsers/form_list_parser.dart` | M | Sedang | Test fixture fase 0 |
| 4.2 | Extract `preloadAuthenticatedData` → `lib/model/app_preload.dart` | S | Sedang | Cold start setelah login |
| 4.3 | Satu file per domain thunk: `user_repository.dart`, `form_repository.dart`, … — thunk panggil repository | L | Tinggi | Semua list + load more |
| 4.4 | `createApiDio()` singleton (opsional) — hindari `new Dio()` per request jika behavior timing sama | S | Sedang | Tidak ubah timeout |

**Jangan ubah:** Nama action Redux, field `PostList`, parameter `getDataTool(...)`.

**Risiko kritis:** Salah urutan `preloadAuthenticatedData` dispatch → dashboard kosong.

---

## Fase 5 — Form state (global controllers → lokal)

**Tujuan:** Reusability & testability; **fase paling berisiko** — lakukan belakangan.

Strategi **strangler** (tanpa big-bang):

| # | Task | Effort | Risiko | Verifikasi |
|---|------|--------|--------|------------|
| 5.1 | Introduce `ToolFormDraft` / `UserFormDraft` class (data holder) — isi dari controllers saat buka form, tulang balik masih global | M | Sedang | Add/edit satu record |
| 5.2 | `navigation_helpers.dart`: `postContUser` hanya terima `UserFormDraft` + navigate (controllers diisi di satu tempat) | M | Tinggi | Edit user prefilled |
| 5.3 | Pindah controllers ke `State` masing-masing `UserFormInput` / `ToolFormInput` — global hanya read session | L | Tinggi | Multi-step tool detail rows |
| 5.4 | Hapus duplikat list `TextEditingController` untuk multi tool — ganti `List<ToolDetailRow>` model | L | Kritis | Add multiple tools |

**Behavior:** Teks di field, validasi, dan payload POST harus byte-identik.

**Mitigasi:** Snapshot test payload map sebelum/sesudah fase 5.3.

---

## Fase 6 — Redux & arsitektur (opsional, jangka panjang)

Hanya jika fase 0–5 stabil.

| # | Task | Effort | Risiko |
|---|------|--------|--------|
| 6.1 | Normalisasi naming action (`FetchDataPO` vs `FetchUsersAction`) — alias deprecated | M | Sedang |
| 6.2 | Pertimbangkan Riverpod/Bloc untuk form-only (Redux tetap untuk list) | L | Tinggi |
| 6.3 | Feature module boundaries (`features/tool/`, `features/user/`) | L | Sedang |

**Tidak wajib** untuk app yang hanya dipelihara internal.

---

## Prioritas eksekusi (roadmap disarankan)

```
Fase 0 ──► Fase 1 ──► Fase 2 ──► Fase 3 ──► Fase 4 ──► Fase 5 ──► Fase 6
  │          │           │           │           │           │
  │          │           │           │           │           └── risiko kritis (defer sampai test ada)
  │          │           │           │           └── risiko tinggi (API/preload)
  │          │           │           └── ROI terbesar readability
  │          │           └── risiko sedang, ukuran file turun
  │          └── risiko rendah
  └── wajib sebelum fase 4–5
```

| Prioritas | Fase | Alasan |
|-----------|------|--------|
| P0 | 0 | Safety net |
| P1 | 1.1, 1.4, 2.1 | Rendah risiko, langsung terasa |
| P2 | 2.2–2.4, 3.1–3.3 | `tool_data` manageable |
| P3 | 3.4, 4.1–4.2 | User list + parser |
| P4 | 4.3 | Butuh test fixture kuat |
| P5 | 5.x | Hanya setelah 0–4 stabil |
| P6 | 6 | Nice-to-have |

---

## Checklist smoke test manual (tiap PR refactor)

Centang setelah build debug:

- [ ] Splash → auto-login jika session ada
- [ ] Login gagal / sukses (pesan error sama)
- [ ] Dashboard: angka card load
- [ ] Tool list: search, pagination/load more, expand/collapse card
- [ ] Tool list: filter milestone (drawer menu) jika dipakai
- [ ] Timeline milestone (orange / red / partial) pada 1 form contoh
- [ ] Add / edit form tool (header)
- [ ] Add / edit tool detail (single + multiple row)
- [ ] User list (SUPERADMIN): search, edit, add
- [ ] Logout → login lagi
- [ ] Push notification init tidak crash (post-frame)

---

## Definisi “selesai” per fase

1. `flutter analyze` tanpa error baru.
2. `flutter test` lulus (setelah fase 0).
3. Smoke checklist 100% untuk area yang disentuh.
4. Tidak ada perubahan string `param*` atau key FormData tanpa koordinasi backend.
5. PR description menyebut fase # dan file yang dipindah.

---

## Yang sengaja tidak dilakukan dalam rencana ini

- Mengubah backend PHP atau contract API.
- Redesign UI/UX.
- Mengganti Redux sepenuhnya dalam satu sprint.
- Optimasi performa yang mengubah timing preload (kecuali diukur dan disetujui).

---

## Estimasi kalender kasar (1 developer)

| Fase | Durasi kumulatif |
|------|------------------|
| 0 | 1–2 hari |
| 1 | 2–3 hari |
| 2 | 3–5 hari |
| 3 | 1–2 minggu |
| 4 | 1 minggu |
| 5 | 2–3 minggu |
| 6 | opsional |

Total realistis untuk P0–P3: **~3–4 minggu**; full termasuk fase 5: **~2 bulan** dengan smoke test disiplin.

---

## Referensi file kunci

| File | Peran dalam refactor |
|------|----------------------|
| `lib/view/var/var.dart` | Pusat coupling — pecah di fase 1.4, kurangi di fase 5 |
| `lib/view/menu/tool/tool_data.dart` | Target utama fase 2–3 |
| `lib/model/post_get_data.dart` | Target fase 4 |
| `lib/controller/function/navigation_helpers.dart` | Navigasi + preload form — fase 5 |
| `lib/model/api_client.dart` | Pola acuan untuk repository |
| `lib/controller/cont_crud/redux/*` | Jangan ubah shape state tanpa migrasi |

---

*Terakhir diperbarui: 2026-05-26 — baseline ~50 file Dart, 22 importer `var.dart`.*

---

## Progress log

| Fase | Status | Catatan |
|------|--------|---------|
| 0.1–0.3 | Done | `test/api_client_test.dart`, `test/api_url_test.dart`, `docs/SMOKE_TEST.md` |
| 1.1 | Done | `ApiUrl.serv` + `--dart-define=API_BASE=...`, URL sebagai getter |
| 1.3 | Done | `ApiUrl.contSuperior` alias |
| 1.4 | Done | `var.dart` barrel → `theme_constants`, `session_globals`, `api_params`, `form_controllers` |
| 2.1 | Done | `pinned_search_header.dart`, dipakai `user_data` + `tool_data` |
| 2.2 | Done | `tool_order_timeline.dart` — ViewModel, logic, widget; ~737 baris keluar dari `tool_data` |
| 2.3 | Done | `tool_detail_shimmers.dart` — `DetailSectionBody`, `ToolListSectionBody`, `FormCardListLoadingSliver` |
| 2.4 | Done | `view/custom/picker/` — `PostListPickerDialog`, presets superior/user, ~600 baris keluar dari form files |
| 3.1 | Done | Pecahan UI ke part (sebelum 3.2) |
| 3.2 | Done | Hapus `part`: file terpisah + mixin; `tool_data.dart` (~35 baris widget), `tool_data_state_base.dart`, `tool_data_state.dart`, `tool_data_dialogs.dart`, dll. |
| 3.3 | Done | `tool_data_logic.dart` + `test/tool_data_logic_test.dart` (filter milestone, approval gates, fetch limit) |
| 3.4 | Done | `user_data.dart` (~10 baris widget) + `user_data_logic`, search, card helpers, user card, list mixin, state base/state |
| 1.2 | Done | Rename folder `tooll/` → `tool/`; migrasi import ke `navigation_helpers.dart`, `responsive_layout.dart`, `desktop_layout.dart`; alias `funct` / `resposive` / `dekstop` dihapus |
| 4.1 | Done | `lib/model/parsers/` — form/user/dashboard/legacy parsers + `list_total_utils`; `test/*_parser_test.dart` (13 tests baru) |
| 4.2 | Done | `lib/model/app_preload.dart` — urutan dispatch sama; `login.dart` / `splash.dart` import langsung |
| 4.3 | Done | `model/repositories/*` (API+parse), `model/thunks/*` (Redux); `post_get_data.dart` barrel (~30 baris) |
| 4.4 | Done | `createApiDio()` singleton + `resetSharedApiDio()` untuk test |
