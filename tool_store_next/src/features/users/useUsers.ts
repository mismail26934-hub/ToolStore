'use client'

import {
  useInfiniteQuery,
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

export function useUsersInfinite(filters: Omit<UserListFilters, 'page'>) {
  return useInfiniteQuery({
    queryKey: queryKeys.users(filters),
    initialPageParam: 1,
    queryFn: ({ pageParam }) =>
      fetchUsers({
        ...filters,
        page: pageParam,
        limit: filters.limit ?? USER_PAGE_SIZE,
      }),
    getNextPageParam: (lastPage, allPages) => {
      const loaded = allPages.reduce((n, p) => n + p.items.length, 0)
      const limit = filters.limit ?? USER_PAGE_SIZE
      if (lastPage.items.length < limit) return undefined
      if (lastPage.total != null && loaded >= lastPage.total) return undefined
      return allPages.length + 1
    },
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
