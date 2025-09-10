# Étape de base
FROM node:20-alpine AS base
WORKDIR /usr/src/app

RUN apk add --no-cache libc6-compat \
  && npm install -g pnpm

FROM base AS deps
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install

FROM base AS builder
COPY --from=deps /usr/src/app/node_modules ./node_modules
COPY . .
RUN pnpm run build

FROM node:20-alpine AS runner
WORKDIR /usr/src/app

RUN addgroup -g 1001 -S nodejs \
  && adduser -u 1001 -S sveltekit -G nodejs

ENV NODE_ENV=production
ENV PORT=3000
ENV HOST=0.0.0.0

COPY --from=builder --chown=sveltekit:nodejs /usr/src/app/build ./build
COPY --from=builder --chown=sveltekit:nodejs /usr/src/app/package.json ./
COPY --from=deps --chown=sveltekit:nodejs /usr/src/app/node_modules ./node_modules

USER sveltekit

EXPOSE 3000

CMD ["node", "build"]
