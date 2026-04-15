# GitHub + Vercel setup (friends-only distribution)

This repo contains the **Swift/macOS app** at the root and a **Next.js site** in `website/` for downloads and instructions.

## 1. Create the GitHub repository

1. On GitHub: **New repository** → name e.g. `IBStudy` → Public (or Private for stricter sharing).
2. Do **not** add a README/license on GitHub if you already have one locally (avoid merge conflicts).

From your machine (replace `YOURUSER` and repo name):

```bash
cd ~/Documents/IBStudy
git add .
git commit -m "Initial commit: IBStudy app and Vercel landing site"
git branch -M main
git remote add origin https://github.com/YOURUSER/IBStudy.git
git push -u origin main
```

If the repo was created empty, `git push -u origin main` is enough.

## 2. Ship a zip on GitHub Releases (for the download button)

Friends should download a **zip of the app**, not clone the whole repo.

1. Build and sync the app (from project root):

   ```bash
   swift build
   # Copy binary + bundle into IBStudy.app per your usual flow
   ```

2. Zip the app bundle:

   ```bash
   cd ~/Documents/IBStudy
   ditto -c -k --sequesterRsrc --keepParent IBStudy.app IBStudy-macos.zip
   ```

3. On GitHub: **Releases** → **Draft a new release** → tag e.g. `v1.0.0` → upload `IBStudy-macos.zip` → publish.

4. Copy the **browser download URL** for that asset (right-click “IBStudy-macos.zip” → copy link). It looks like:

   `https://github.com/YOURUSER/IBStudy/releases/download/v1.0.0/IBStudy-macos.zip`

## 3. Deploy the site on Vercel

1. Sign in at [vercel.com](https://vercel.com) with GitHub.
2. **Add New** → **Project** → import the `IBStudy` repository.
3. **Root Directory**: set to `website` (important).
4. Framework: Vercel should detect **Next.js**. Leave defaults.
5. **Environment variables** (Production):

   - `NEXT_PUBLIC_DOWNLOAD_URL` = the Release asset URL from step 2.
   - `NEXT_PUBLIC_GITHUB_REPO_URL` = `https://github.com/YOURUSER/IBStudy` (optional).

6. **Deploy**. Your site will be at something like `ib-study.vercel.app` (you can add a custom domain later).

After each Release, update `NEXT_PUBLIC_DOWNLOAD_URL` if the URL changes, or use a stable “latest” workflow (see GitHub docs for permanent latest-release links).

## 4. Optional: stable “latest” download URL

GitHub does not guarantee a single permanent URL for “always latest” for arbitrary assets; many teams either:

- Bump the env var in Vercel when they publish a new release, or  
- Link to the **Releases** page: `https://github.com/YOURUSER/IBStudy/releases/latest` and let users pick the zip (less one-click).

The landing page is designed for a **direct zip URL** via `NEXT_PUBLIC_DOWNLOAD_URL`.
