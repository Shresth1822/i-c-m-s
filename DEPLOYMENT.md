# Deployment Guide for ICMS

This project is ready for deployment as a static site (Flutter Web).

## Prerequisites

- Flutter SDK installed.
- Supabase project set up.
- `.env` file populated with `SUPABASE_URL` and `SUPABASE_ANON_KEY`.

## Build Instructions

1.  **Generate Release Build**:

    ```bash
    flutter build web --release
    ```

    This creates the static files in `build/web`.

2.  **Environment Variables**:
    By default, the `.env` file is bundled with the application assets. Ensure your `.env` contains the correct production keys before building.

## Deploying to Vercel

### Option 1: Git Integration (Easiest for Static Site)

1.  **Commit the Build Artifacts**:
    - We have enabled committing the `build/web` folder.
    - Run `flutter build web --release`.
    - `git add build/web`
    - `git commit -m "chore: Add build artifacts for deployment"`
    - `git push`

2.  **Vercel Settings**:
    - Import the project in Vercel.
    - **Framework Preset**: `Other`
    - **Build Command**: Toggle "Override" and leave it **empty** (or use `echo "Using pre-built assets"`).
    - **Output Directory**: `build/web`

3.  **Deploy**: Vercel will simply serve the files you committed.

### Option 2: Vercel CLI

1.  Install Vercel CLI: `npm i -g vercel`
2.  Run `vercel login`.
3.  Run `vercel` from the root directory.
4.  Set output directory to `build/web`.

## Deploying to Other Static Hosts (Netlify, Firebase, GitHub Pages)

The contents of `build/web` can be served by any static file server.

- **GitHub Pages**: Use `flutter build web --base-href "/repo-name/"`.
- **Firebase**: `firebase deploy`.

## SPA Routing

A `vercel.json` file is included to handle Single Page Application routing (rewrites all 404s to `index.html`).
