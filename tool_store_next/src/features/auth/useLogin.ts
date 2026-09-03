'use client'

import { useMutation } from '@tanstack/react-query'
import { loginRequest } from './authApi'
import { useAuth } from '../../auth/AuthContext'

export function useLogin() {
  const { setUser } = useAuth()
  return useMutation({
    mutationFn: ({ username, password }: { username: string; password: string }) =>
      loginRequest(username, password),
    onSuccess: (session) => {
      setUser(session)
    },
  })
}
