# Backend integration notes

## Filter detail tool / PO / SO / Rcv by `id_form`

Flutter memuat detail **per form** saat card di-expand (`loadFormRelatedDetails`).

| Endpoint | POST field | Keterangan |
|----------|------------|------------|
| `v1/form/detail` | `id_form` | VIEW DATA TOOL — hanya baris tool form tersebut |
| `v1/po`, `v1/so`, `v1/receive/wh`, `v1/receive/tool` | `id_form` | VIEW — child rows milik form tersebut |

Helper PHP: [`cont_form_detail_filter.php`](./cont_form_detail_filter.php).

Tanpa `id_form` (kosong), VIEW tetap mengembalikan semua baris (perilaku lama).

## Filter rentang `from_date_update`

Filter sudah diintegrasikan di:

- `api_toolstore/model/form_repository.php` — `form_date_filter_sql()` + `form_list_view()`
- `api_toolstore/model/m_proses.php` — wrapper `form_list_view()`
- `api_toolstore/controller/cont_form.php` — baca POST `to_date_update`, pass ke VIEW

Flutter app (Data Tool) mengirim filter hanya saat **VIEW DATA FORM**:

| Field POST | Format | Keterangan |
|------------|--------|------------|
| `from_date_update` | `YYYY-MM-DD` | Wajib jika filter aktif |
| `to_date_update` | `YYYY-MM-DD` | Opsional; default = `from_date_update` |

Tanpa kedua field (atau `from_date_update` kosong), list tampil seperti biasa.

## Langkah integrasi

1. Salin helper dari [`cont_form_date_filter.php`](./cont_form_date_filter.php) ke project PHP backend (mis. `helpers/form_date_filter.php`).
2. Di handler **`VIEW DATA FORM`** pada endpoint `api_tool/api_toolstore/v1/form`:
   - Baca `$_POST['from_date_update']` dan `$_POST['to_date_update']`.
   - Panggil `toolstore_form_date_filter_clause(...)`.
   - Tambahkan `$dateSql` ke query **SELECT list** dan **COUNT total** (pagination).
   - Gabungkan `$dateBinds` ke parameter prepared statement (urutan sama dengan placeholder `?`).
3. Deploy backend, lalu uji dari app: icon filter di header Data Tool (sebelah kiri icon +).

## Contoh SQL

```sql
-- List
SELECT * FROM data_form
WHERE 1=1
  /* + keyword filter existing */
  AND DATE(from_date_update) >= ?
  AND DATE(from_date_update) <= ?
ORDER BY from_date_update DESC
LIMIT ? OFFSET ?;

-- Total (pagination)
SELECT COUNT(*) FROM data_form
WHERE 1=1
  /* + keyword filter existing */
  AND DATE(from_date_update) >= ?
  AND DATE(from_date_update) <= ?;
```

Ganti `data_form` dengan nama tabel form di environment Anda.

## Verifikasi cepat (Postman / curl)

```bash
curl -X POST "http://HOST/api_tool/api_toolstore/v1/form" \
  -d "param=VIEW DATA FORM" \
  -d "page=1" \
  -d "limit=20" \
  -d "from_date_update=2025-01-01" \
  -d "to_date_update=2025-06-07"
```

Respons harus hanya berisi form dengan `from_date_update` dalam rentang tersebut; field `total` (jika ada) ikut terfilter.

## Catatan

- ADD/EDIT form tetap mengirim `from_date_update` sebagai **nilai field record**, bukan filter — helper hanya dipakai pada branch `VIEW DATA FORM`.
- Format tanggal harus `YYYY-MM-DD` (sama dengan Flutter `DateFormat('yyyy-MM-dd')`).
