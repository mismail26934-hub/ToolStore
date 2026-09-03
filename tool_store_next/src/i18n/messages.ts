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
  | 'logout'
  | 'darkMode'
  | 'darkModeOn'
  | 'darkModeOff'
  | 'language'
  | 'languageEn'
  | 'languageId'
  | 'appearance'
  | 'manage'
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
  logout: 'Keluar',
  darkMode: 'Mode Gelap',
  darkModeOn: 'Tema gelap aktif. Ketuk untuk tema terang.',
  darkModeOff: 'Aktifkan tema gelap untuk tampilan malam.',
  language: 'Bahasa',
  languageEn: 'English',
  languageId: 'Bahasa Indonesia',
  appearance: 'Tampilan',
  manage: 'Kelola',
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
  step5Sub: 'Baris tool / pembelian berjalan.',
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
  logout: 'Logout',
  darkMode: 'Dark Mode',
  darkModeOn: 'Dark theme is on. Tap for light theme.',
  darkModeOff: 'Enable dark theme for comfortable night viewing.',
  language: 'Language',
  languageEn: 'English',
  languageId: 'Bahasa Indonesia',
  appearance: 'Appearance',
  manage: 'Manage',
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
  step5Sub: 'Tool lines / purchasing in progress.',
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
