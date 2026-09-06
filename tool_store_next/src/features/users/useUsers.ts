'use client'

import {
  useMutation,
  useQuery,
  useQueryClient,
} from '@tanstack/react-query'
import { queryKeys } from '../../api/queryKeys'
import { USER_PAGE_SIZE } from '../../types/models'
import { fetchSuperiors, type SuperiorListFilters } from './superiorApi'
import {
  addUser,
  deleteUser,
  editUser,
  fetchUserById,
  fetchUsers,
  type SaveUserInput,
  type UserListFilters,
} from './usersApi'

export function useUsersList(filters: UserListFilters) {
  return useQuery({
    queryKey: queryKeys.users(filters),
    queryFn: () =>
      fetchUsers({
        ...filters,
        page: filters.page ?? 1,
        limit: filters.limit ?? USER_PAGE_SIZE,
      }),
  })
}

export function useUser(idUsers: string | undefined, enabled = true) {
  return useQuery({
    queryKey: ['users', 'by-id', idUsers ?? ''],
    queryFn: () => fetchUserById(idUsers!),
    enabled: enabled && !!idUsers?.trim(),
  })
}

export function useUsersPicker(
  filters: Omit<UserListFilters, 'page'>,
  enabled = true,
) {
  return useQuery({
    queryKey: queryKeys.users({ ...filters, picker: true }),
    queryFn: () =>
      fetchUsers({
        ...filters,
        page: 1,
        limit: filters.limit ?? USER_PAGE_SIZE,
      }),
    enabled,
  })
}

export function useSuperiors(filters: SuperiorListFilters, enabled = true) {
  return useQuery({
    queryKey: queryKeys.superiors(filters),
    queryFn: () => fetchSuperiors(filters),
    enabled,
  })
}

export function useUserMutations() {
  const qc = useQueryClient()
  const invalidate = () =>
    qc.invalidateQueries({ queryKey: ['users'] })

  const add = useMutation({
    mutationFn: (input: SaveUserInput) => addUser(input),
    onSuccess: invalidate,
  })
  const edit = useMutation({
    mutationFn: (input: SaveUserInput) => editUser(input),
    onSuccess: invalidate,
  })
  const remove = useMutation({
    mutationFn: (input: SaveUserInput) => deleteUser(input),
    onSuccess: invalidate,
  })

  return { add, edit, remove }
}
