# Smoke Test Manual — Tool Store App

Gunakan checklist ini setelah **setiap PR refactor** (atau sebelum release) untuk memastikan perilaku tidak berubah.

**Environment:** build debug, device/emulator yang sama, backend dev (`ApiUrl.serv` atau `--dart-define` jika sudah fase 1.1).

**Akun uji:** sediakan minimal SUPERADMIN + 1 user level non-admin.

---

## 1. Autentikasi & session

| # | Langkah | Expected |
|---|---------|----------|
| 1.1 | Fresh install / clear app data → buka app | Splash tampil, lanjut login jika belum session |
| 1.2 | Login kredensial salah | Pesan error sama seperti sebelumnya |
| 1.3 | Login sukses | Masuk home/dashboard, token tersimpan |
| 1.4 | Kill app → buka lagi | Auto-login ke home (session masih ada) |
| 1.5 | Logout dari drawer | Kembali ke login, list tidak bocor data user lain |

---

## 2. Dashboard

| # | Langkah | Expected |
|---|---------|----------|
| 2.1 | Buka dashboard dari menu | Card count load (tidak stuck shimmer selamanya) |
| 2.2 | Tap shortcut ke tool list (jika ada) | Filter milestone sesuai menu |

---

## 3. Data Tool (`ToolData`)

| # | Langkah | Expected |
|---|---------|----------|
| 3.1 | Buka list tool default | Data tampil, shimmer lalu konten |
| 3.2 | Ketik di search + ganti field search | Hasil filter benar |
| 3.2b | Tap icon filter → pilih rentang tanggal | List terfilter by `from_date_update`, total pagination benar |
| 3.2c | Tap filter lagi → Hapus filter tanggal | List kembali normal |
| 3.3 | Scroll ke bawah (load more jika ada) | Baris tambahan append, tidak duplikat aneh |
| 3.4 | Expand satu form card | Detail section (PO/SO/WH/Tool) load |
| 3.5 | Collapse / expand lain | State expand independen |
| 3.6 | Buka dari notifikasi/deep link dengan `initialExpandedFormId` (jika dipakai) | Card yang benar terbuka |
| 3.7 | Form dengan milestone ditolak / partial receive | Timeline warna (orange/red/partial) benar |
| 3.8 | Menu drawer: filter milestone berbeda | List sesuai filter |

---

## 4. CRUD Form Tool

| # | Langkah | Expected |
|---|---------|----------|
| 4.1 | Add form baru | Simpan sukses, muncul di list |
| 4.2 | Edit form existing | Field ter-prefill, simpan update |
| 4.3 | Add tool detail (satu baris) | Parent form id benar |
| 4.4 | Add multiple tool detail | Semua baris terkirim |
| 4.5 | Edit / hapus tool detail (jika fitur ada) | Sesuai role |

---

## 5. Data User (SUPERADMIN)

| # | Langkah | Expected |
|---|---------|----------|
| 5.1 | Login non-superadmin → buka user menu | Snackbar access denied |
| 5.2 | Login superadmin → user list | List + search pin header |
| 5.3 | Add user | Validasi password, simpan |
| 5.4 | Edit user | Level read-only jika aturan berlaku |

---

## 6. Infrastruktur

| # | Langkah | Expected |
|---|---------|----------|
| 6.1 | Matikan WiFi → action API | Pesan cek internet |
| 6.2 | Server mati / 500 | Pesan server down |
| 6.3 | Toggle dark mode (jika ada) | Tema berubah, tidak crash |
| 6.4 | Ganti bahasa ID/EN (jika ada) | String UI berubah |
| 6.5 | Cold start setelah login | Preload tidak error (dashboard/tool tidak kosong permanen) |

---

## 7. Regresi khusus per area refactor

| Area disentuh | Extra check |
|---------------|-------------|
| `tool_data.dart` / timeline | 3.7, 3.4, 3.8 |
| `user_data.dart` / search header | 5.2, search pin saat scroll |
| `post_get_data.dart` / preload | 6.5, 2.1, 3.1 |
| `var.dart` / form controllers | 4.x, 5.3, 5.4 |
| `api_client.dart` / `ApiUrl` | 1.2–1.5, 6.1–6.2 |
| `navigation_helpers.dart` / navigasi form | 4.2, 5.4 |

---

## Catatan insiden

| Tanggal | PR / fase | Tester | Fail # | Catatan |
|---------|-----------|--------|--------|---------|
| | | | | |

---

Lihat juga: [REFACTOR_PLAN.md](./REFACTOR_PLAN.md)
