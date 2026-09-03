export const queryKeys = {
  dashboardCounts: ['dashboard-counts'] as const,
  forms: (filters: Record<string, unknown>) => ['forms', filters] as const,
  form: (idForm: string) => ['form', idForm] as const,
  toolDetails: (idForm: string) => ['tool-details', idForm] as const,
  po: (idForm: string) => ['po', idForm] as const,
  so: (idForm: string) => ['so', idForm] as const,
  rcvWh: (idForm: string) => ['rcv-wh', idForm] as const,
  rcvTool: (idForm: string) => ['rcv-tool', idForm] as const,
  users: (filters: Record<string, unknown>) => ['users', filters] as const,
  superiors: (filters: Record<string, unknown>) =>
    ['superiors', filters] as const,
  session: ['session'] as const,
}
