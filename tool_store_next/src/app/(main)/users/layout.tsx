import { SuperAdminGuard } from '@/components/AuthGuard'

export default function UsersLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return <SuperAdminGuard>{children}</SuperAdminGuard>
}
