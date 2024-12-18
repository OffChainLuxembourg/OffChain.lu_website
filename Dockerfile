FROM node:18.20.5-alpine3.21@sha256:6eb9c3d9bd191bd2cc6ce7ec3d5ec4c2127616140c8586af96a6bec8f28689d1 AS base

# Update dependencies
RUN apk update && apk upgrade

WORKDIR /app
COPY package.json package-lock.json ./

FROM base AS builder
# Install all dependencies (including dev) for the build process
RUN npm ci --silent && npm cache clean --force

# Copy the rest of the application code
COPY . .

ENV NEXT_PUBLIC_TELEMETRY_DISABLED=1
RUN npm run build

# Remove dev dependencies after build to reduce final size
RUN npm prune --production && npm cache clean --force

FROM base
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_PUBLIC_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system -g nodejs --uid 1001 nextjs

COPY --from=builder /app/public public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000
ENV PORT=3000
CMD ["node", "server.js"]
