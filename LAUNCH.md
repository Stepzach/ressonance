# Ressonance launch handoff

Status: private pre-launch build. Core shared-room persistence is implemented. Streaming credentials and live acceptance tests are outstanding. Keep the Site private until the intended audience and release gates below are confirmed.

## 1. Configure Spotify

Register a Spotify developer app under the owner's account. Supply its public Client ID as the runtime value `SPOTIFY_CLIENT_ID`. No Spotify Client Secret is used by this PKCE implementation.

Register this exact redirect URI:

https://side-a-music-room.ps4zachstep.chatgpt.site/api/oauth/spotify/callback

Requested permissions are `user-read-recently-played` and `user-library-modify`. In development mode, configure eligible test users in Spotify's dashboard. Confirm current quota/access eligibility before a broader release; do not assume development credentials authorize a public consumer launch.

References:
- https://developer.spotify.com/documentation/web-api/tutorials/code-pkce-flow
- https://developer.spotify.com/documentation/web-api/reference/get-recently-played
- https://developer.spotify.com/documentation/web-api/reference/save-library-items
- https://developer.spotify.com/documentation/web-api/concepts/quota-modes
- https://developer.spotify.com/blog/2026-07-23-web-api-quota-updates

## 2. Configure Apple Music

Set up a MusicKit identifier and key in the Apple Developer account. Configure these server-side runtime secrets/values:

- `APPLE_TEAM_ID`: Apple developer team identifier.
- `APPLE_KEY_ID`: MusicKit signing key identifier.
- `APPLE_PRIVATE_KEY`: complete PKCS#8 `.p8` PEM text, including actual newlines; secret.

The server creates origin-bound one-hour ES256 developer tokens. The signing private key never reaches the browser. Alternatively, `APPLE_MUSIC_DEVELOPER_TOKEN` accepts an already signed, unexpired developer token; the owner must renew it before expiry. Signing-key configuration takes precedence over a pre-signed token.

Register/allow the production origin as required by the Apple MusicKit setup. Test with an active Apple Music subscriber. Authorize via MusicKit, enable history sharing, import recent tracks, find a matching recording and add it to the library. Apple returns acceptance, so allow time for library propagation.

References:
- https://developer.apple.com/musickit/
- https://developer.apple.com/documentation/applemusicapi/generating-developer-tokens
- https://developer.apple.com/documentation/applemusicapi/user-authentication-for-musickit
- https://developer.apple.com/documentation/applemusicapi/get-v1-me-recent-played-tracks
- https://developer.apple.com/documentation/applemusicapi/add-a-resource-to-a-library

## 3. Resolve Deezer scope

Deezer currently supports shared song links in Ressonance. Do not advertise connected Deezer listening or direct library saving. A Deezer community manager stated that new API access for private individuals was disabled. No reopening was verified in this review. Existing approved access may differ; obtain a confirmed app and its current OAuth/history/library API contract before enabling that provider. Source: https://en.deezercommunity.com/features-feedback-44/api-auth-impossible-80857 If access is unavailable, explicitly launch with Deezer link support only.

## 4. Runtime and access

For the new Cloudflare deployment, follow `CLOUDFLARE.md`. It uses a separate empty D1 database, verified Cloudflare Access JWTs, and new runtime secrets. The following original Sites configuration remains specific to the private legacy deployment.

`APP_ORIGIN` is set to the current Site origin and `TOKEN_ENCRYPTION_KEY` is a securely generated 32-byte hex secret. Do not casually rotate or remove this key: existing provider tokens use it. Reconnect affected accounts after a planned key rotation, or implement a versioned key migration before changing it.

Configure values through the hosting secret/runtime settings, not source code, chat messages, browser localStorage or `.openai/hosting.json`. Deploy a new saved version after runtime changes so they apply.

The current Site is owner-private. Give named testers Site access before sending them room invite links. The legacy Site uses ChatGPT sign-in; the new Cloudflare deployment uses Cloudflare Access. If the target audience needs a different consumer identity system, confirm the hosting/authentication route before launch; an invite is not a substitute for Site access.

## 5. Release acceptance

- Use two real accounts/devices: create room, invite/join, share song, refresh both devices, verify favourites stay private.
- Verify expired/revoked invitations and access from a non-member account.
- Complete real Spotify and Apple consent flows, cancellation, refresh, history sharing off/on, disconnect and library-save checks.
- Check Safari/iOS and Chrome/Android including MusicKit's authorization popup, keyboard navigation and 200% text zoom.
- Review the actual privacy notice, operator/support contact and provider-required product terms/branding for the intended public launch. The app contains factual privacy controls, not jurisdiction-specific legal advice.
- Confirm operational ownership for provider key renewal/revocation, backups/restore, request-error monitoring and support. No recovery or uptime claim has been made.
- Choose the public audience only after the preceding gates pass. Public deployment is not performed by this update.

## Test evidence and limits

The automated suite passes 23 integration/UI checks with actual SQLite migrations, synthetic DOM interactions and mocked music-provider responses. It does not prove that Spotify/Apple will authorize an unregistered app, that Deezer developer access is available, or that all browsers work. A Spotify Client ID is configured on the current hosted version; real account authorization and live end-to-end validation are still pending. Apple signing credentials have not been provided.

## GitHub repository and hosting handoff

Source repository: `Stepzach/ressonance`. The owner’s existing `Stepzach/zarala` repository hosts an unrelated musician website and is preserved.

The app cannot run in full on GitHub Pages: Pages serves static files, while `/api/*`, D1 data and provider token operations require a server runtime. The current authentication uses Sites-dispatch identity headers. A deployment outside Sites must replace or verify that authentication boundary; never trust caller-supplied `oai-authenticated-user-id` headers on an ordinary public Worker.

The prepared CI workflow runs Node 24 tests and builds. Before setting up automatic deployment from GitHub, choose/configure a backend host, its database and its verified sign-in route. Do not publish only `public/` as if it were the working application. A Pages frontend would additionally require a deliberate backend origin/authentication/CORS configuration.

Source publication and application deployment are separate. The CI workflow validates the code; it does not deploy a server. No GitHub Pages app deployment is configured.

## Sharing defaults in 0.4.0

New profiles start with sharing enabled by application registration code. No existing user's saved preference is overwritten. Connecting a provider shows an enabled-by-default sharing checkbox; unchecking it keeps history private. The chosen value is bound to the OAuth request and applied with the connection. A persisted opt-out prevents automatic sync on load.
