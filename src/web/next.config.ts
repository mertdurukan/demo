import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // ================================
  // DOCKER OPTIMIZATION
  // ================================
  // Standalone: Tek dosyada tüm dependencies
  // Neden: Docker container'da minimum footprint
  output: 'standalone',
  
  // ================================
  // STATIC OPTIMIZATION
  // ================================
  // Trailing slash: Static export uyumluluğu
  trailingSlash: false,
  
  // ================================
  // IMAGE OPTIMIZATION
  // ================================
  // Unoptimized images: External image service yok
  images: {
    unoptimized: true,
  },
  
  // ================================
  // ENVIRONMENT VARIABLES
  // ================================
  env: {
    // API URL'i environment'a göre ayarla
    API_URL: process.env.NODE_ENV === 'production' 
      ? process.env.API_URL || 'http://api:80'
      : 'http://localhost:5102',
  },
  
  // ================================
  // PERFORMANCE OPTIMIZATIONS
  // ================================
  compress: true,
  poweredByHeader: false, // Security: X-Powered-By header'ını gizle
  
  // ================================
  // EXPERIMENTAL FEATURES
  // ================================
  experimental: {
    // App router optimizations
    optimizePackageImports: ['@/lib', '@/components'],
  },
};

export default nextConfig;
