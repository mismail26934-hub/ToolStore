import { NextResponse } from 'next/server'

function swScript(config: Record<string, string>) {
  return `/* generated firebase messaging SW */
importScripts('https://www.gstatic.com/firebasejs/11.0.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/11.0.2/firebase-messaging-compat.js');
firebase.initializeApp(${JSON.stringify(config)});
try { firebase.messaging(); } catch (e) { console.debug('[fcm-sw]', e); }
`
}

export function GET() {
  const apiKey = process.env.NEXT_PUBLIC_FIREBASE_API_KEY?.trim() || ''
  const authDomain = process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN?.trim() || ''
  const projectId = process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID?.trim() || ''
  const messagingSenderId =
    process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID?.trim() || ''
  const appId = process.env.NEXT_PUBLIC_FIREBASE_APP_ID?.trim() || ''

  const body = swScript({
    apiKey,
    authDomain: authDomain || (projectId ? `${projectId}.firebaseapp.com` : ''),
    projectId,
    messagingSenderId,
    appId,
  })

  return new NextResponse(body, {
    headers: {
      'Content-Type': 'application/javascript; charset=utf-8',
      'Cache-Control': 'no-cache',
      'Service-Worker-Allowed': '/',
    },
  })
}
