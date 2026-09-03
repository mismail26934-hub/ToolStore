import type { NextConfig } from 'next'

const apiBase = (process.env.NEXT_PUBLIC_API_BASE || 'http://10.101.164.69:8080/').replace(
  /\/?$/,
  '/',
)

const nextConfig: NextConfig = {
  async rewrites() {
    return [
      {
        source: '/api_tool/:path*',
        destination: `${apiBase}api_tool/:path*`,
      },
    ]
  },
}

export default nextConfig
