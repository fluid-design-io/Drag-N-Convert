/** @type {import('next').NextConfig} */
const nextConfig = {
  transpilePackages: ["@workspace/ui"],
  experimental: {
    dynamicIO: true,
  },
};

export default nextConfig;
