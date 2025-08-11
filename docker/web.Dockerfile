# ================================
# STAGE 1: DEPENDENCIES
# ================================
# Neden Alpine: %95 küçük image (5MB vs 200MB)
FROM node:18-alpine AS deps
WORKDIR /app

# ================================
# DEPENDENCY INSTALLATION
# ================================
# Package files önce - Docker caching için
COPY src/web/package*.json ./

# npm ci: Production dependencies, lockfile'dan
# Neden ci: npm install'dan daha hızlı ve güvenilir
RUN npm ci --only=production && npm cache clean --force

# ================================
# STAGE 2: BUILD ENVIRONMENT
# ================================
FROM node:18-alpine AS builder
WORKDIR /app

# Dependencies'i önceki stage'den al
COPY --from=deps /app/node_modules ./node_modules

# Source code'u kopyala
COPY src/web/ ./

# ================================
# NEXT.JS OPTIMIZATIONS
# ================================
# Next.js build optimizasyonları
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

# Build application
RUN npm run build && ls -la .next/

# ================================
# STAGE 3: RUNTIME ENVIRONMENT
# ================================
FROM node:18-alpine AS runner
WORKDIR /app

# ================================
# ENVIRONMENT SETUP
# ================================
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000

# ================================
# SECURITY: NON-ROOT USER
# ================================
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# ================================
# COPY OPTIMIZED FILES
# ================================
# Public assets
COPY --from=builder /app/public ./public

# Next.js build output
COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# ================================
# SECURITY & PERMISSIONS
# ================================
USER nextjs

# ================================
# HEALTH CHECK
# ================================
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

# ================================
# EXPOSE PORT & START
# ================================
EXPOSE 3000
CMD ["npx", "next", "start"] 