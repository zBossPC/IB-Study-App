# GitHub + Vercel setup (friends-only distribution)

This repo contains the **Swift/macOS app** at the root and a **Next.js site** in `website/` for downloads and instructions.

**Live repo:** [github.com/zBossPC/IB-Study-App](https://github.com/zBossPC/IB-Study-App)

## 1. GitHub repository

The project is hosted at **zBossPC/IB-Study-App**. To push updates:

```bash
cd ~/Documents/IBStudy
git add .
git commit -m "Your message"
git push origin main
```

## 2. Ship a zip on GitHub Releases (for the download button)

Friends should download a **zip of the app**, not clone the whole repo.

1. Build and sync the app (from project root):

   ```bash
   swift build
   # Copy binary + bundle into IBStudy.app per your usual flow
   ```

2. Build an **unsigned DMG** (recommended — nice Finder window with app + Applications shortcut):

   ```bash
   cd ~/Documents/IBStudy
   brew install create-dmg   # once, for the polished layout
   chmod +x scripts/build-dmg.sh
   ./scripts/build-dmg.sh    # produces IBStudy-macos.dmg
   ```

   Or zip only: `ditto -c -k --sequesterRsrc --keepParent IBStudy.app IBStudy-macos.zip`

3. On GitHub: **Releases** → **Draft a new release** → tag e.g. `v1.0.2` → upload **`IBStudy-macos.dmg`** (and optionally the zip) → publish.

4. Direct download URL for the DMG (example **v1.0.2**):

   `https://github.com/zBossPC/IB-Study-App/releases/download/v1.0.2/IBStudy-macos.dmg`

## 3. Deploy the site on Vercel

1. Sign in at [vercel.com](https://vercel.com) with GitHub.
2. **Add New** → **Project** → import the `IBStudy` repository.
3. **Root Directory**: set to `website` (important).
4. Framework: Vercel should detect **Next.js**. Leave defaults.
5. **Environment variables** (optional — the site already defaults to the repo above):

   - `NEXT_PUBLIC_DOWNLOAD_URL` — override if you publish a new release with a different tag.
   - `NEXT_PUBLIC_GITHUB_REPO_URL` — override if you fork.

   Defaults are set in `website/app/page.tsx` for **zBossPC/IB-Study-App** and **v1.0.2**.

6. **Deploy**. Your site will be at something like `ib-study.vercel.app` (you can add a custom domain later).

After each Release, update `NEXT_PUBLIC_DOWNLOAD_URL` if the URL changes, or use a stable “latest” workflow (see GitHub docs for permanent latest-release links).

## 4. Optional: stable “latest” download URL

GitHub does not guarantee a single permanent URL for “always latest” for arbitrary assets; many teams either:

- Bump the env var in Vercel when they publish a new release, or  
- Link to the **Releases** page: `https://github.com/YOURUSER/IBStudy/releases/latest` and let users pick the zip (less one-click).

The landing page is designed for a **direct zip URL** via `NEXT_PUBLIC_DOWNLOAD_URL`.
