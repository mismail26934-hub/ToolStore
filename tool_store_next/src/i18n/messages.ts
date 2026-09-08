export type LocaleCode = 'id' | 'en'

export type MessageKey =
  | 'appName'
  | 'dashboard'
  | 'myProfile'
  | 'forms'
  | 'dataTool'
  | 'completed'
  | 'hold'
  | 'rejectedSuperior'
  | 'rejectedDept'
  | 'users'
  | 'superiors'
  | 'superiorsSubtitle'
  | 'addSuperior'
  | 'editSuperior'
  | 'importExcel'
  | 'downloadTemplate'
  | 'chooseFile'
  | 'importSelected'
  | 'selectAllValid'
  | 'clearSelection'
  | 'previewReady'
  | 'rowOk'
  | 'rowError'
  | 'rowWarn'
  | 'prevPage'
  | 'nextPage'
  | 'showingRange'
  | 'logout'
  | 'logoutConfirm'
  | 'close'
  | 'darkMode'
  | 'darkModeOn'
  | 'darkModeOff'
  | 'language'
  | 'languageEn'
  | 'languageId'
  | 'appearance'
  | 'manage'
  | 'actions'
  | 'search'
  | 'clearSearch'
  | 'dataCount'
  | 'noData'
  | 'loading'
  | 'filterDates'
  | 'changeDates'
  | 'exportExcel'
  | 'addForm'
  | 'appTagline'
  | 'signInContinue'
  | 'loginTagline'
  | 'loginKicker'
  | 'username'
  | 'password'
  | 'show'
  | 'hide'
  | 'login'
  | 'signingIn'
  | 'pushNotifications'
  | 'pushEnabled'
  | 'pushDisabled'
  | 'pushUnsupported'
  | 'pushNotConfigured'
  | 'enablePush'
  | 'timelineCompleted'
  | 'timelineNext'
  | 'timelineStopped'
  | 'timelinePartial'
  | 'step1Title'
  | 'step1Sub'
  | 'step2Title'
  | 'step2Sub'
  | 'step3Title'
  | 'step3Sub'
  | 'step4Title'
  | 'step4Sub'
  | 'step5Title'
  | 'step5Sub'
  | 'step6Title'
  | 'step6Sub'
  | 'step7Title'
  | 'step7Sub'

type Dictionary = Record<MessageKey, string>

const id: Dictionary = {
  appName: 'Tool Monitoring',
  dashboard: 'Dashboard',
  myProfile: 'Profil Saya',
  forms: 'Form',
  dataTool: 'Data Tool',
  completed: 'Selesai',
  hold: 'Hold',
  rejectedSuperior: 'Ditolak (Superior)',
  rejectedDept: 'Ditolak (Dept Head)',
  users: 'Users',
  superiors: 'Superior',
  superiorsSubtitle: 'User berlevel SUPERIOR (SUPERADMIN)',
  addSuperior: 'Tambah superior',
  editSuperior: 'Edit superior',
  importExcel: 'Import Excel',
  downloadTemplate: 'Download template',
  chooseFile: 'Pilih file',
  importSelected: 'Import terpilih',
  selectAllValid: 'Pilih semua valid',
  clearSelection: 'Hapus pilihan',
  previewReady: 'Preview {n} baris — centang data yang akan diimport',
  rowOk: 'OK',
  rowError: 'Error',
  rowWarn: 'Peringatan',
  prevPage: 'Sebelumnya',
  nextPage: 'Berikutnya',
  showingRange: 'Menampilkan {from}–{to} dari {total}',
  logout: 'Keluar',
  logoutConfirm: 'Yakin ingin keluar dari sesi ini?',
  close: 'Tutup',
  darkMode: 'Mode Gelap',
  darkModeOn: 'Tema gelap aktif. Ketuk untuk tema terang.',
  darkModeOff: 'Aktifkan tema gelap untuk tampilan malam.',
  language: 'Bahasa',
  languageEn: 'English',
  languageId: 'Bahasa Indonesia',
  appearance: 'Tampilan',
  manage: 'Kelola',
  actions: 'Aksi',
  search: 'Cari',
  clearSearch: 'Hapus pencarian',
  dataCount: '{n} data',
  noData: 'Tidak ada data',
  loading: 'Memuat…',
  filterDates: 'Filter tanggal',
  changeDates: 'Ubah tanggal',
  exportExcel: 'Export Excel',
  addForm: 'Tambah form',
  appTagline: 'Monitoring tool, approval, dan serah terima gudang',
  signInContinue: 'Masuk untuk melanjutkan',
  loginTagline:
    'Pantau permintaan tool, approval, dan serah terima gudang dalam satu workspace.',
  loginKicker: 'Operasi Service',
  username: 'Username',
  password: 'Password',
  show: 'Tampil',
  hide: 'Sembunyi',
  login: 'Login',
  signingIn: 'Masuk…',
  pushNotifications: 'Notifikasi Push',
  pushEnabled: 'Token FCM tersimpan.',
  pushDisabled: 'Push belum diaktifkan di browser ini.',
  pushUnsupported: 'Browser tidak mendukung notifikasi push.',
  pushNotConfigured: 'Firebase web belum dikonfigurasi (.env).',
  enablePush: 'Aktifkan push',
  timelineCompleted: 'SELESAI',
  timelineNext: 'Berikutnya',
  timelineStopped: 'Berhenti',
  timelinePartial: 'Sebagian',
  step1Title: '1. Permintaan Order',
  step1Sub: 'Request diajukan.',
  step2Title: '2. Persetujuan Order 1',
  step2Sub: 'Persetujuan superior.',
  step3Title: '3. Review Order',
  step3Sub: 'Review service support.',
  step4Title: '4. Persetujuan Order 2',
  step4Sub: 'Persetujuan dept head.',
  step5Title: '5. Proses Order',
  step5Sub: 'Request Order Processing',
  step6Title: '6. WH Received',
  step6Sub: 'Warehouse menerima.',
  step7Title: '7. Tool Received',
  step7Sub: 'Tool room menerima.',
}

const en: Dictionary = {
  appName: 'Tool Monitoring',
  dashboard: 'Dashboard',
  myProfile: 'My Profile',
  forms: 'Forms',
  dataTool: 'Data Tool',
  completed: 'Completed',
  hold: 'Hold',
  rejectedSuperior: 'Rejected (Superior)',
  rejectedDept: 'Rejected (Dept Head)',
  users: 'Users',
  superiors: 'Superiors',
  superiorsSubtitle: 'Users with SUPERIOR level (SUPERADMIN)',
  addSuperior: 'Add superior',
  editSuperior: 'Edit superior',
  importExcel: 'Import Excel',
  downloadTemplate: 'Download template',
  chooseFile: 'Choose file',
  importSelected: 'Import selected',
  selectAllValid: 'Select all valid',
  clearSelection: 'Clear selection',
  previewReady: 'Preview {n} rows — check rows to import',
  rowOk: 'OK',
  rowError: 'Error',
  rowWarn: 'Warning',
  prevPage: 'Previous',
  nextPage: 'Next',
  showingRange: 'Showing {from}–{to} of {total}',
  logout: 'Logout',
  logoutConfirm: 'Are you sure you want to sign out?',
  close: 'Close',
  darkMode: 'Dark Mode',
  darkModeOn: 'Dark theme is on. Tap for light theme.',
  darkModeOff: 'Enable dark theme for comfortable night viewing.',
  language: 'Language',
  languageEn: 'English',
  languageId: 'Bahasa Indonesia',
  appearance: 'Appearance',
  manage: 'Manage',
  actions: 'Actions',
  search: 'Search',
  clearSearch: 'Clear search',
  dataCount: '{n} results',
  noData: 'No data',
  loading: 'Loading…',
  filterDates: 'Filter dates',
  changeDates: 'Change dates',
  exportExcel: 'Export Excel',
  addForm: 'Add form',
  appTagline: 'Tool requests, approvals, and warehouse handoff',
  signInContinue: 'Sign in to continue',
  loginTagline:
    'Monitor tool requests, approvals, and warehouse handoff in one workspace.',
  loginKicker: 'Service Operations',
  username: 'Username',
  password: 'Password',
  show: 'Show',
  hide: 'Hide',
  login: 'Login',
  signingIn: 'Signing in…',
  pushNotifications: 'Push Notifications',
  pushEnabled: 'FCM token saved.',
  pushDisabled: 'Push is not enabled in this browser.',
  pushUnsupported: 'This browser does not support push notifications.',
  pushNotConfigured: 'Firebase web is not configured (.env).',
  enablePush: 'Enable push',
  timelineCompleted: 'COMPLETED',
  timelineNext: 'Next',
  timelineStopped: 'Stopped',
  timelinePartial: 'Partial',
  step1Title: '1. Order Request',
  step1Sub: 'Request submitted.',
  step2Title: '2. Order Approval 1',
  step2Sub: 'Superior approval.',
  step3Title: '3. Order Review',
  step3Sub: 'Service support review.',
  step4Title: '4. Order Approval 2',
  step4Sub: 'Dept. head approval.',
  step5Title: '5. Order Processing',
  step5Sub: 'Request Order Processing',
  step6Title: '6. WH Received',
  step6Sub: 'Warehouse received.',
  step7Title: '7. Tool Received',
  step7Sub: 'Tool room received.',
}

export const messages: Record<LocaleCode, Dictionary> = { id, en }

export const WORKFLOW_STEP_KEYS: {
  title: MessageKey
  sub: MessageKey
}[] = [
  { title: 'step1Title', sub: 'step1Sub' },
  { title: 'step2Title', sub: 'step2Sub' },
  { title: 'step3Title', sub: 'step3Sub' },
  { title: 'step4Title', sub: 'step4Sub' },
  { title: 'step5Title', sub: 'step5Sub' },
  { title: 'step6Title', sub: 'step6Sub' },
  { title: 'step7Title', sub: 'step7Sub' },
]
