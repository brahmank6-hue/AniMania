# AniMania — Random Anime TV

A retro CRT-TV-themed random anime recommender. Press the dial, tune in to a
random anime pulled from AniList, save favorites, track what you've seen, and
optionally connect a real MyAnimeList account to import your list.

**Live:** https://animania123.netlify.app/
**Repo:** https://github.com/brahmank6-hue/AniMania

---

## 1. Is the code on GitHub already?

Yes — this repo is already connected and pushed (`origin` →
`https://github.com/brahmank6-hue/AniMania.git`, branch `main`). You don't
need to redo the steps below for this project. They're kept here as a
reusable checklist for the next time you start a project from scratch and
want to get it onto GitHub.

### Getting a fresh project onto GitHub, step by step

1. **Create the GitHub repo first** (empty, no README/license) at
   github.com → New repository. Copy the URL it gives you, e.g.
   `https://github.com/<you>/<repo>.git`.
2. **Set your git identity once per machine**, if not already set:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "you@example.com"
   ```
3. **Turn your project folder into a git repo** (skip if it already has a
   `.git` folder):
   ```bash
   git init
   git branch -M main
   ```
4. **Add a `.gitignore`** before your first commit, so secrets and local
   junk never get tracked (see [Secrets](#secrets--environment-variables)
   below for what belongs here).
5. **Stage and commit everything:**
   ```bash
   git add .
   git commit -m "Initial commit"
   ```
6. **Point it at GitHub and push:**
   ```bash
   git remote add origin https://github.com/<you>/<repo>.git
   git push -u origin main
   ```
   The first push will prompt for GitHub auth in the browser (or a personal
   access token if using HTTPS without the credential manager).
7. **Every change after that** is just:
   ```bash
   git add <files>
   git commit -m "Describe the change"
   git push
   ```

That's the whole loop this project has been using — see `git log` for real
examples of commit message style.

### Getting this repo back into Claude on a new device

Claude itself doesn't sync project files or conversation history across
devices — only what's in GitHub travels. To resume working on AniMania with
Claude on a different computer:

1. **Install Git** (and Claude Code) on the new device, if not already there.
2. **Clone the repo:**
   ```bash
   git clone https://github.com/brahmank6-hue/AniMania.git
   ```
3. **Open Claude Code in that folder** (`cd AniMania`, then start Claude
   Code there). This will be a brand-new conversation with no memory of past
   sessions.
4. **Point Claude at this README** to rebuild context fast — it covers the
   stack, file map, secrets, localStorage schema, and the API/CSS gotchas
   discovered so far, so you shouldn't need to re-explain the project from
   scratch.
5. **Netlify deploys keep working automatically** — the deploy hook is tied
   to the GitHub repo, not to the device that pushes, so you don't need to
   reconnect anything on the new machine for `git push` to go live.

### Transferring a repo to a different GitHub account

Two different scenarios, depending on whether you want to *move* the repo
(same repo, new owner, old location stops working) or *copy* it (a fresh,
independent repo under the new account, original untouched).

**Option A — Move it (GitHub's built-in transfer, recommended if you own both accounts or the receiving account agrees):**

1. On GitHub, go to the repo → **Settings** → scroll to the **Danger Zone**
   → **Transfer ownership**.
2. Type the new owner's GitHub username (or organization name) and confirm
   with the repo name when prompted.
3. GitHub emails/notifies the new owner, who must **accept the transfer**
   before it completes.
4. Once accepted, the repo lives at `https://github.com/<new-owner>/<repo>`.
   Stars, issues, wiki, and full commit history all move with it — nothing
   is lost.
5. **Update your local clone's remote** so pushes go to the new URL:
   ```bash
   git remote set-url origin https://github.com/<new-owner>/<repo>.git
   ```
6. **Reconnect Netlify** (or whatever host) to the repo's new location if it
   was linked by URL — check Netlify's Site settings → Build & deploy →
   Link to a different repository, since the deploy hook may still point at
   the old owner/URL.
7. The old URL (`github.com/<old-owner>/<repo>`) auto-redirects to the new
   one for a while, but don't rely on that long-term.

**Option B — Copy it (new independent repo, e.g. duplicating into a personal account without touching the original):**

1. **Create a new empty repo** under the target account (no README/license,
   same as [step 1 above](#getting-a-fresh-project-onto-github-step-by-step)).
2. **Clone the original repo with full history:**
   ```bash
   git clone https://github.com/<old-owner>/<repo>.git
   cd <repo>
   ```
3. **Point it at the new repo instead:**
   ```bash
   git remote set-url origin https://github.com/<new-owner>/<repo>.git
   ```
4. **Push everything** — all branches and tags, not just `main`:
   ```bash
   git push -u origin --all
   git push origin --tags
   ```
5. The new account now has an independent copy with full commit history.
   Issues, PRs, and stars do **not** carry over with this method (GitHub
   doesn't expose those over `git`) — only Option A preserves those.
6. If you also want to redeploy from the new repo, connect Netlify to it the
   same way as Option A step 6.

---

## 2. Restarting this project — what you need to know

### Stack

- **No build step.** The entire app is one static file, [`index.html`](index.html)
  (HTML + CSS + JS inline). Open it, edit it, save it — that's the dev loop.
- **Data source:** [AniList's GraphQL API](https://graphql.anilist.co) — public,
  no API key needed.
- **Optional MAL login:** OAuth2 (PKCE) against MyAnimeList, proxied through
  two Netlify Functions (see below) because MAL's endpoints don't send CORS
  headers for direct browser calls.
- **Hosting:** Netlify, auto-deploys on every push to `main` (already
  connected — no action needed to deploy, just `git push`).

### File map

| Path | Purpose |
|---|---|
| `index.html` | The entire app: markup, CSS, and JS |
| `manifest.json` | PWA web app manifest (installable app metadata) |
| `sw.js` | Service worker — caches the app shell, never caches API calls |
| `icons/` | Generated PWA icons (see `.claude/make-icons.ps1` to regenerate) |
| `netlify/functions/mal-token.js` | Proxies MAL's OAuth token exchange/refresh |
| `netlify/functions/mal-list.js` | Proxies fetching a user's MAL anime list |
| `netlify.toml` | Netlify build/publish config + `/api/mal/*` redirects to the functions |
| `.claude/serve.ps1` + `.claude/launch.json` | Local static file server for previewing (`npx`-free, pure PowerShell) |
| `.claude/make-icons.ps1` | Regenerates the PWA icon PNGs from scratch via GDI+ |

### Running it locally

No install needed — it's a static server. Either:
- Open `index.html` directly in a browser (MAL login won't work without a
  server, since OAuth needs a real origin), or
- Run the PowerShell static server:
  ```powershell
  powershell -NoProfile -ExecutionPolicy Bypass -File .claude/serve.ps1 -Port 5500
  ```
  then visit `http://localhost:5500`.

### Secrets / environment variables

- `MAL_CLIENT_ID` and `MAL_CLIENT_SECRET` — set in the **Netlify dashboard**
  (Site settings → Environment variables), used server-side only by the two
  Netlify Functions. Never committed to the repo.
- Note: `index.html` also has a hardcoded `MAL_CLIENT_ID` constant
  (currently `e9680e7186ded7fcedca3dad37cc9906`) — that's expected and safe
  to have client-side; MAL's "Other" app type is a public OAuth client with
  no secret, so the client ID isn't sensitive. The real secret
  (`MAL_CLIENT_SECRET`) only ever lives in Netlify's env vars, never in the
  HTML.
- If you ever rotate the MAL app credentials, update both the Netlify env
  vars and the `MAL_CLIENT_ID` constant in `index.html`.

### localStorage keys (client-side persistence, no backend DB)

| Key | Holds |
|---|---|
| `surpriseme_watchlist_v2` | Saved-for-later list |
| `surpriseme_seen_v1` | Already-seen list (with optional MAL status per entry) |
| `surpriseme_mal_auth_v1` | MAL OAuth tokens, once connected |

### Known API quirks worth remembering

- **AniList's `averageScore_greater` filter is inclusive** (`>=`, not `>`
  despite the name) — confirmed by direct testing. The app uses `75` to mean
  "7.5+", not `74`.
- **AniList's `pageInfo.lastPage`/`total` are unreliable** — the app
  binary-searches for the true last page instead of trusting those fields
  directly. If you touch pagination, keep the probe's `perPage` identical to
  the real fetch's `perPage` (page numbers aren't comparable across
  different `perPage` values).
- **Pagination is capped** at `page × perPage ≤ 5000` by AniList itself.

### CSS gotchas that bit us repeatedly this project

- Any class that both uses `[hidden]` *and* has an explicit `display: ...`
  rule needs an extra `.class[hidden] { display: none; }` override — an
  author's `display` rule always beats the browser's default
  `[hidden] { display: none }`. This bit `.result-grid`, `.browse-grid`,
  `.load-more-btn`, `.tape-row`, `.mal-connected-badge`, and `.home-view` —
  check this first if something won't hide.
- Elements sized `width: min(Npx, 100%)` need either to be a direct flex
  child of an `align-items: center` parent, or their own `margin: 0 auto` —
  especially if the same class gets reused in more than one DOM nesting
  context (this broke `.category-nav` when it moved from a direct child of
  `.page` to nested inside `.browse-view`).

### Regenerating PWA icons

If you want to change the icon design, edit `.claude/make-icons.ps1` (pure
GDI+ drawing, no image dependencies) and rerun:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .claude/make-icons.ps1
```
It overwrites everything in `icons/`.

### Deploying

Nothing to do beyond `git push` — Netlify is already wired to this GitHub
repo and redeploys automatically on every push to `main`.

### Feature list (as of this doc)

- Random pick (score-weighted, with a "Higher Rated" 7.5+ filter — available
  on the home page and on every genre/mood/category browse page)
- Browse by category: Movies, Short Watches, Shonen, Family-Friendly, Top
  Rated
- Genre and mood-based browsing (moods are MAL-genre-taxonomy-inspired
  groupings, not a literal AniList field)
- Plot/title/genre search with client-side keyword matching (no LLM/backend)
- Watchlist ("Saved for Later") and "Already Seen" tracking, both
  localStorage-based
- Optional real MyAnimeList OAuth login, read-only import of your MAL list
- Installable as a PWA (manifest + service worker + app icons)

### Deliberate non-features (don't re-add without discussing first)

- No LLM/AI-powered search — chosen to avoid needing a backend + API key
- No write-back to MyAnimeList — the MAL integration is read-only by design
