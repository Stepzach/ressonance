# Ressonance

**different platforms, same frequency**

A music-sharing app with a plain HTML/CSS/JavaScript frontend and a JavaScript Cloudflare Worker backend. Font Awesome Free 6.7.2, DM Sans and Manrope are bundled locally; there is no third-party icon or font CDN dependency.

## Ressonance 0.3.0 — pre-launch source

Implemented and tested locally:
- ChatGPT/Sites sign-in using trusted dispatcher identity headers. Anonymous API requests are rejected.
- Persistent D1 profiles, private shared rooms (up to 20 people), shared songs/notes and private favourites.
- Owner-only room management and hashed, expiring, revocable, one-use invitations.
- Server-side membership checks, prepared SQL, origin/CSRF protection, input limits, rate limits and security headers.
- Recent listening sharing enabled by default for new profiles/connections, with a visible opt-out, profile controls, disconnect, export, deletion and recoverable failures.
- Spotify Authorization Code + PKCE, user-bound state, encrypted server-side token storage, refresh, recent listening, track search and current library-save API.
- Apple MusicKit authorization, encrypted user tokens, region-aware search, recent tracks and library-add requests. Optional automatic short-lived ES256 developer-token signing from server-side secrets.
- Explicit recording selection before saving a song across providers; no guessed cross-provider library writes.
- Deezer song links and native navigation. Deezer OAuth/history/library APIs are **not implemented** pending verified developer access and current API documentation.

The source repository is `Stepzach/ressonance`. The existing `Stepzach/zarala` musician website is a separate project. The `.github/workflows/ci.yml` workflow runs tests and builds on push. It does not claim to deploy the backend.

The provider adapters are gated when configuration is absent. They have been tested using mocked provider responses, not live streaming accounts. This is not a claim that the full three-provider product is ready for public launch.

## Files and commands

- `public/index.html`, `public/styles.css`, `public/app.js`: browser app.
- `public/vendor/fontawesome`: self-hosted icons and licence.
- `server/index.js`: Worker API and static-asset serving.
- `db/schema.ts`, `drizzle/`: D1 schema and generated migrations.
- `tests/`: Node/SQLite integration tests and jsdom interaction tests.
- `.env.example`: supported runtime configuration names, without secrets.
- `LAUNCH.md`: setup requirements and remaining release gates.

Use Node 24+ for tests (built-in SQLite). Run `npm ci --ignore-scripts`, `npm test`, and `npm run build`.
The build emits a dependency-free Worker at `dist/server/index.js`, embeds the public assets, and copies Sites metadata/migrations. Sites supplies the actual D1 binding and runs the generated migrations on publication. `npm run db:generate` generates migrations for schema changes. Do not rewrite applied migrations.

## Data behaviour

Each signed-in user can belong to one room at a time. Only a room's members can read its shared songs and listening. Shared songs refresh every 30 seconds while the app is visible. Imported listening syncs on load, after connecting Apple Music, after returning from Spotify authorization, and every five minutes while sharing is enabled and the app is visible. It can also be refreshed on demand. Existing users who opted out stay private on load. This version does not run background imports when the app is closed.

Recent listening is shown for seven days. Expired imported records and temporary authorization/rate-limit records are removed in bounded batches during app activity. Stopping history sharing or disconnecting immediately removes relevant imported history. Apple supplies recent tracks without exact play timestamps; the UI labels them “Recently”. Favourites are personal to each user and persist across devices. Hearts save in Ressonance; saving to a streaming library is a separate explicit action. Apple library-add requests may be accepted before appearing in the user's library.

Invitations expire after seven days, are single-use, and replace the previous invitation for that room. They grant room membership only; the recipient must also have permission to open the Site. Account deletion removes owned rooms for all members, which the UI warns about before confirmation. No passwords or emails are stored in D1. The signed-in display name may be used to initialise the editable profile.

Old device-local prototype data is not silently uploaded or deleted. The released app does not import the old `side-a-v1` localStorage data.

## Validation

19 passing automated checks cover authentication, CSRF, cross-room isolation, private favourites, invite lifecycle, ownership, URL/input validation, consent, fail-closed provider setup, Spotify PKCE/token refresh/library writes, Apple token signing/library writes, quotas, deletion, headers, real-room UI creation, escaped song sharing and failed-submission recovery, default sharing, sync on load and preserved opt-outs.

A real-browser cross-device run and real-provider end-to-end tests remain required once provider setup and visitor access are available. jsdom tests are not browser/device compatibility certification.
