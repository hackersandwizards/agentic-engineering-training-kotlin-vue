# 8. Server-Side Rendering with Fastify

## Status

Accepted

## Context

The Finden product listing needs to be:
- SEO-friendly for search engines
- Fast initial page load
- Interactive after hydration
- Integrated with platform authentication
- Monitored and observable

Vue 3 applications are typically client-side rendered (CSR), which has SEO limitations. We need a solution that:
- Renders initial HTML on the server
- Hydrates to interactive Vue app on client
- Handles routing on both server and client
- Integrates with existing platform infrastructure

Options:
- **Nuxt.js**: Full-featured Vue SSR framework, opinionated
- **Custom SSR**: More control, requires more setup
- **Pre-rendering**: Simple but not dynamic
- **CSR only**: Simplest but poor SEO

## Decision

We implement custom Server-Side Rendering using Fastify as the SSR server.

**Architecture:**
- Fastify TypeScript server (`src/main/frontend/ssrServer/`)
- Vue Server Renderer for SSR
- Separate builds for client and server bundles
- Static file serving via @fastify/static
- Metrics via fastify-metrics
- Integration with backend API via axios

**Build process:**
1. Build client bundle: `vue-cli-service build --mode=production`
2. Build server bundle: `SSR=true vue-cli-service build`
3. Compile SSR server: TypeScript → `dist/ssrServer/`
4. Run: `NODE_ENV=production node dist/ssrServer/server.js`

## Consequences

### Positive

- **SEO optimization**: Search engines receive fully rendered HTML
- **Fast initial load**: HTML rendered on server, no JavaScript required for first paint
- **Progressive enhancement**: Works without JavaScript, enhanced with it
- **Performance control**: Custom SSR allows optimization for specific needs
- **Fastify speed**: Fast HTTP server with low overhead
- **Monitoring**: Built-in metrics and OpenTelemetry integration
- **Platform integration**: Basic Auth and backend proxying

### Negative

- **Build complexity**: Three separate builds (client, server, SSR server)
- **Maintenance burden**: Custom SSR requires ongoing maintenance
- **Development workflow**: Separate dev processes for client and SSR
- **Memory usage**: Node.js SSR server adds runtime overhead
- **Debugging complexity**: Bugs can occur in server render or client hydration
- **State synchronization**: Must carefully manage state between server and client

### Neutral

- **TypeScript**: SSR server written in TypeScript 4.7.3
- **Fastify version**: 4.2.0 with dedicated plugins
- **Controllers**: `produktlisteController`, `toolController`, `healthController`
- **Metrics exporter**: Google Cloud Monitoring integration
- **Environment config**: `.env.fastify` for SSR server configuration
- **Development mode**: Separate `npm run serverDev` with nodemon
- **Static files**: Served from dist directory via @fastify/static
- **Error handling**: Custom error handler for SSR failures
