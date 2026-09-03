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
- Tool items (BRAND / SPESIFIKASI)
- PO / SO / receive cascades
- Export CSV (local)
- Users CRUD + superior picker + My Profile
- Dark mode + ID/EN
- Optional web FCM
