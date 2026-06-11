# Go-Live Checklist – laramint × Supabase × Vercel

## ✅ Technical Checklist

### 1. Configuration
- [ ] `.env.production` filled with real Supabase credentials
- [ ] `APP_KEY` set (run `php artisan key:generate --show`)
- [ ] `APP_DEBUG=false` confirmed
- [ ] `APP_URL` matches the Vercel project URL
- [ ] `SESSION_SECURE_COOKIE=true` confirmed
- [ ] `LOG_LEVEL=warning` confirmed

### 2. Database (Supabase)
- [ ] Supabase project created (production)
- [ ] Database migrations run successfully: `php artisan migrate --force`
- [ ] Database seeded (if required)
- [ ] Row count per table verified
- [ ] Connection pooler endpoint used for web traffic (port 5432 or 6543)

### 3. Vercel Deployment
- [ ] `vercel.json` committed to repo
- [ ] Vercel project linked to GitHub repository
- [ ] All environment variables set in Vercel dashboard:
  - `APP_NAME`, `APP_ENV`, `APP_KEY`, `APP_URL`
  - `DB_CONNECTION`, `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`
  - `SESSION_SECURE_COOKIE`, `LOG_LEVEL`
- [ ] First deployment succeeded (`vercel --prod`)
- [ ] Custom domain configured (if applicable)

### 4. GitHub Actions CI/CD
- [ ] GitHub Secrets added:
  - `VERCEL_TOKEN`
  - `VERCEL_ORG_ID`
  - `VERCEL_PROJECT_ID`
- [ ] `deploy.yml` runs on push to `main`
- [ ] Tests pass in CI (green badge)
- [ ] Auto-deploy to Vercel works after tests pass

### 5. Smoke Tests (after deployment)
- [ ] Homepage loads without errors
- [ ] Login / Register works
- [ ] Role & permission system works
- [ ] Activity log writes correctly
- [ ] No 500 errors in Vercel logs

### 6. Security
- [ ] `APP_DEBUG=false` in Vercel env vars (not just .env.production)
- [ ] No sensitive credentials in repo (`.env` is in `.gitignore`)
- [ ] HTTPS enforced (Vercel does this automatically)
- [ ] Session cookies are secure

### 7. Backup
- [ ] Supabase PITR (Point-In-Time Recovery) confirmed enabled
- [ ] Supabase project plan supports backup frequency needed

## 📋 Sign-Off
| Item | Status | Date | Notes |
|------|--------|------|-------|
| UAT passed | | | |
| DB migration verified | | | |
| CI/CD pipeline green | | | |
| Production deploy succeeded | | | |
| 24-hour monitoring passed | | | |
