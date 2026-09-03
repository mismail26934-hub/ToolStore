'use server'

import { ApiParam } from '@/api/params'
import {
  dbGetUserById,
  dbListSuperiors,
  dbListUsers,
  dbMutateUser,
  dbSaveFcmToken,
  type SaveUserInput,
  type SuperiorListFilters,
  type UserListFilters,
} from '@/db/usersRepo'
import type { PaginatedList, SuperiorRow, UserRow } from '@/types/models'

export type { SaveUserInput, SuperiorListFilters, UserListFilters }

export async function fetchUsers(
  filters: UserListFilters = {},
): Promise<PaginatedList<UserRow>> {
  try {
    return await dbListUsers(filters)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal memuat users')
  }
}

export async function fetchUserById(idUsers: string): Promise<UserRow | null> {
  try {
    return await dbGetUserById(idUsers)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal memuat user')
  }
}

export async function addUser(input: SaveUserInput): Promise<string> {
  try {
    return await dbMutateUser(ApiParam.addUser, input)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal menambah user')
  }
}

export async function editUser(input: SaveUserInput): Promise<string> {
  try {
    return await dbMutateUser(ApiParam.editUser, input)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal mengubah user')
  }
}

export async function deleteUser(input: SaveUserInput): Promise<string> {
  try {
    return await dbMutateUser(ApiParam.deleteUser, input)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal menghapus user')
  }
}

export async function fetchSuperiors(
  filters: SuperiorListFilters = {},
): Promise<PaginatedList<SuperiorRow>> {
  try {
    return await dbListSuperiors(filters)
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal memuat superior')
  }
}

export async function saveFcmToken(input: {
  fcmToken: string
  platform?: string
  userId: string
}): Promise<void> {
  try {
    await dbSaveFcmToken({
      userId: input.userId,
      fcmToken: input.fcmToken,
    })
  } catch (e) {
    throw new Error(e instanceof Error ? e.message : 'Gagal simpan FCM token')
  }
}
