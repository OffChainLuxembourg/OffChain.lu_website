FROM node:18.17.1-alpine3.18@sha256:3482a20c97e401b56ac50ba8920cc7b5b2022bfc6aa7d4e4c231755770cf892f as base

# Update dependencies
RUN apk update && apk upgrade

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --only=production --silent && npm cache clean --force

FROM base as builder
RUN npm ci --only=production --silent && npm cache clean --force
COPY . .
ENV NEXT_PUBLIC_TELEMETRY_DISABLED 1
RUN npm run build

FROM base
WORKDIR /app
ENV NODE_ENV production
ENV NEXT_PUBLIC_TELEMETRY_DISABLED 1
RUN addgroup --system --gid 1001 nodejs && \
  adduser --system -g nodejs --uid 1001 nextjs
COPY --from=builder /app/public public
# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
USER nextjs
EXPOSE 3000
ENV PORT 3000
CMD ["npm", "start"]
