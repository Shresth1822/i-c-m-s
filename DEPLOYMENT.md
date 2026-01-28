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

### Option 1: Git Integration (Recommended)

1.  Push your code to GitHub/GitLab/Bitbucket.
2.  Import the project in Vercel.
3.  **Build Settings**:
    - Framework Preset: `Other`
    - Build Command: `flutter build web --release`
    - Output Directory: `build/web`
4.  **Environment Variables**:
    - You may need to create a script to generate the `.env` file during the build process on Vercel if you don't commit it (which is best practice).
    - _Simpler Approach for Demo_: Since `.env` is currently committed/assets-bundled, just ensure it's correct.

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
