import { SuperAdminGuard } from '@/components/AuthGuard'

export default function SuperiorsLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return <SuperAdminGuard>{children}</SuperAdminGuard>
}
