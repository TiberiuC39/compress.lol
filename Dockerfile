FROM node:20-alpine AS base
WORKDIR /usr/src/app

RUN apk add --no-cache libc6-compat

FROM base AS deps

COPY package.json package-lock.json* ./
RUN npm ci

FROM base AS builder
WORKDIR /usr/src/app
COPY --from=deps /usr/src/app/node_modules ./node_modules
COPY . .

RUN npm run prepare

RUN npm run build

FROM base AS runner
WORKDIR /usr/src/app

ENV NODE_ENV=production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 sveltekit

COPY --from=builder /usr/src/app/build build/
COPY --from=builder /usr/src/app/package.json .
COPY --from=deps /usr/src/app/node_modules ./node_modules

RUN chown -R sveltekit:nodejs /usr/src/app

USER sveltekit

EXPOSE 3000

ENV PORT=3000
ENV HOST=0.0.0.0

CMD ["node", "build"]
