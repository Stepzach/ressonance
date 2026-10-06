# Deploy Ressonance from GitHub to Cloudflare

The source lives in Stepzach/ressonance. Cloudflare Workers serves both the app and API at one origin; GitHub Pages currently serves the repository README and is not the application backend.

## 1. Import the repository

In Cloudflare: Workers & Pages → Create application → import/connect an existing Git repository. Connect GitHub and limit installation to Stepzach/ressonance. Select that repository and the main branch.

Use:

| Setting | Value |
| --- | --- |
| Worker name | `ressonance` |
| Root directory | repository root (leave blank) |
| Build command | `npm run build` |
| Deploy command | `npm run deploy` |

The checked-in Wrangler configuration points at `dist/server/index.js`, binds `DB` to `ressonance-db` with database ID `a9b7010a-2fd6-4e3e-b7af-81f795546650`, and disables preview URLs. The deploy command applies the versioned SQL migrations to this database before publishing the Worker. Do not attach an existing database belonging to another app. Node 24 is recommended for the automated tests; the build itself uses standard Node filesystem APIs.

Deploy to obtain the exact workers.dev URL. Until sign-in configuration is complete, API requests fail closed and no caller can create/read a profile through spoofed identity headers.

## 2. Protect the Worker with Cloudflare Access

In the Worker: Settings → Domains & Routes → workers.dev → Enable Cloudflare Access. Select Manage Cloudflare Access to edit the generated application.

Allow your email and the specific friends you want to test with. Cloudflare Access's email one-time PIN can be used when enabled as a login method; do not use Bypass or a service-token-only policy for this app. An app invitation grants room membership, but does not grant permission through Access.

From the Access application, copy its Application Audience (AUD) tag. From your Zero Trust team configuration, copy the team domain, such as `your-team.cloudflareaccess.com`.

## 3. Set runtime variables

In the Worker: Settings → Variables and Secrets. Set these text variables:

| Name | Value |
| --- | --- |
| `APP_ORIGIN` | exact Worker origin, e.g. `https://ressonance.your-subdomain.workers.dev` (no trailing slash) |
| `CF_ACCESS_TEAM_DOMAIN` | team hostname only, e.g. `your-team.cloudflareaccess.com` |
| `CF_ACCESS_AUD` | this Access application's AUD tag |

`AUTH_MODE=cloudflare-access` and the provided public Spotify Client ID are already in `wrangler.jsonc`. Keep AUTH_MODE set to cloudflare-access on Cloudflare. `sites` mode is only for the trusted Sites dispatcher, never an ordinary public Worker.

Add `TOKEN_ENCRYPTION_KEY` as a Secret: generate a fresh 32-byte key encoded as 64 hexadecimal characters, for example using `openssl rand -hex 32` on your own computer. Enter it directly into Cloudflare; do not put it in GitHub or chat. Save securely for recovery. Rotating it requires reconnecting accounts unless a key migration is implemented. This new Cloudflare deployment has its own empty database; existing private Sites data and tokens are not migrated.

Save/deploy the updated variables as prompted. Open the Worker URL, sign in, choose your profile name and create a room. The app uses verified JWT identity and stores no login passwords or email addresses in D1.

## 4. Register Spotify's redirect

In the owner's Spotify Developer Dashboard, add:

`<APP_ORIGIN>/api/oauth/spotify/callback`

Replace `<APP_ORIGIN>` with the real Worker origin. This is a different redirect from the old Sites URL. Save it, then open Ressonance → Connections → Spotify. No Spotify Client Secret is used. Development-mode users must meet Spotify's current access requirements and be registered as allowed users as required.

Connecting defaults to sharing recent listening, with an opt-out checkbox. Enabled listening syncs on app load, after connection and periodically while visible. Existing opt-outs are preserved.

## 5. Apple Music and Deezer

Apple Music requires the owner's MusicKit setup. Add APPLE_TEAM_ID and APPLE_KEY_ID as text, and APPLE_PRIVATE_KEY (the complete .p8 PEM) as a Secret. Use the actual app origin for the MusicKit configuration. Keep the private key out of GitHub and chat. The app signs short-lived origin-bound developer tokens and uses MusicKit for user authorization. Test with a real eligible Apple Music account.

Deezer shared links work. Deezer account connection/history/library writes are not enabled until approved API access and its current contract are available.

## Acceptance

Test two allowed Access users on separate devices: create/invite/join a room, share songs, refresh both devices and verify private favourites. Complete real provider authorization, recent-history sync, opt-out/disconnect and native-library saves. Automated tests use mocked music providers and do not substitute for these checks.

## References

- https://developers.cloudflare.com/workers/ci-cd/builds/
- https://developers.cloudflare.com/changelog/post/2025-10-03-one-click-access-for-workers/
- https://developers.cloudflare.com/cloudflare-one/access-controls/applications/http-apps/authorization-cookie/validating-json/
- https://developers.cloudflare.com/d1/reference/migrations/
