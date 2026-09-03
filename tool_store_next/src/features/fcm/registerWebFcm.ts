import { saveFcmToken } from '@/features/fcm/fcmApi'

export type FcmStatus =
  | 'unsupported'
  | 'not_configured'
  | 'denied'
  | 'ready'
  | 'saved'
  | 'error'

function firebaseConfigFromEnv() {
  const apiKey = process.env.NEXT_PUBLIC_FIREBASE_API_KEY?.trim()
  const authDomain = process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN?.trim()
  const projectId = process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID?.trim()
  const messagingSenderId =
    process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID?.trim()
  const appId = process.env.NEXT_PUBLIC_FIREBASE_APP_ID?.trim()
  const vapidKey = process.env.NEXT_PUBLIC_FIREBASE_VAPID_KEY?.trim()

  if (!apiKey || !projectId || !messagingSenderId || !appId || !vapidKey) {
    return null
  }

  return {
    apiKey,
    authDomain: authDomain || `${projectId}.firebaseapp.com`,
    projectId,
    messagingSenderId,
    appId,
    vapidKey,
  }
}

export function isFcmConfigured() {
  return firebaseConfigFromEnv() != null
}

export function isFcmSupported() {
  return (
    typeof window !== 'undefined' &&
    'Notification' in window &&
    'serviceWorker' in navigator
  )
}

/**
 * Register web push via Firebase Messaging when env is configured.
 * Mirrors Flutter SAVE FCM TOKEN flow with platform=web.
 * No-ops gracefully when Firebase web is not set up.
 */
export async function registerWebFcm(): Promise<{
  status: FcmStatus
  token?: string
  message?: string
}> {
  if (!isFcmSupported()) {
    return { status: 'unsupported' }
  }

  const cfg = firebaseConfigFromEnv()
  if (!cfg) {
    return { status: 'not_configured' }
  }

  try {
    const { initializeApp, getApps } = await import('firebase/app')
    const { getMessaging, getToken, isSupported } = await import(
      'firebase/messaging'
    )

    if (!(await isSupported())) {
      return { status: 'unsupported' }
    }

    const permission = await Notification.requestPermission()
    if (permission !== 'granted') {
      return { status: 'denied' }
    }

    const app =
      getApps()[0] ??
      initializeApp({
        apiKey: cfg.apiKey,
        authDomain: cfg.authDomain,
        projectId: cfg.projectId,
        messagingSenderId: cfg.messagingSenderId,
        appId: cfg.appId,
      })

    await navigator.serviceWorker.register('/api/firebase-messaging-sw', {
      scope: '/',
    })
    const messaging = getMessaging(app)
    const token = await getToken(messaging, {
      vapidKey: cfg.vapidKey,
      serviceWorkerRegistration: await navigator.serviceWorker.ready,
    })
    if (!token) {
      return { status: 'error', message: 'Empty FCM token' }
    }

    await saveFcmToken({ fcmToken: token, platform: 'web' })
    localStorage.setItem('toolstore:fcm_token', token)
    return { status: 'saved', token }
  } catch (e) {
    return {
      status: 'error',
      message: e instanceof Error ? e.message : String(e),
    }
  }
}
