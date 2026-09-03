import { readSession } from '@/auth/session'
import { saveFcmToken as saveFcmTokenServer } from '@/server/users'

export async function saveFcmToken(input: {
  fcmToken: string
  platform?: 'web' | 'android' | 'ios' | 'macos'
}): Promise<void> {
  const session = readSession()
  if (!session?.idUsersApp) {
    throw new Error('Session tidak ditemukan untuk menyimpan FCM token')
  }
  await saveFcmTokenServer({
    fcmToken: input.fcmToken,
    platform: input.platform,
    userId: session.idUsersApp,
  })
}
