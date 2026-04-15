# IBStudy landing page (Vercel)

Single-page marketing + download link for the macOS app.

## Local development

```bash
cd website
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

## Environment variables (Vercel)

In the Vercel project → **Settings** → **Environment Variables**:

| Name | Example | Purpose |
|------|---------|---------|
| `NEXT_PUBLIC_DOWNLOAD_URL` | `https://github.com/zBossPC/IB-Study-App/releases/download/v1.0.10/IBStudy-macos.dmg` | Direct link to the DMG on GitHub Releases |
| `NEXT_PUBLIC_GITHUB_REPO_URL` | `https://github.com/yourname/IBStudy` | Optional “Source on GitHub” link |

Redeploy after changing variables.

## Build

```bash
npm run build
```

Vercel runs this automatically on push.

## Project root

Set **Root Directory** to `website` when importing this monorepo into Vercel (see `docs/GITHUB_AND_VERCEL.md` in the repo root).
