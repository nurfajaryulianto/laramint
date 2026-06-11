# Roadmap Production Ready + Migrasi Database ke Supabase

## Tujuan

Menjadikan aplikasi siap production dengan target utama:

1. Infrastruktur stabil, aman, dan bisa di-scale.
2. Alur CI/CD dan quality gate berjalan otomatis.
3. Observability lengkap (monitoring, logging, alerting).
4. Database pindah dari MySQL/MariaDB ke Supabase (PostgreSQL) dengan downtime minimal.

---

## Scope Hasil Akhir (Definition of Done)

Project dianggap selesai saat semua poin berikut terpenuhi:

- Aplikasi berjalan di environment production dengan `APP_ENV=production` dan `APP_DEBUG=false`.
- Semua test critical lulus di pipeline CI.
- Deploy otomatis via CI/CD dengan mekanisme rollback.
- Database production sudah menggunakan Supabase PostgreSQL.
- Migrasi data tervalidasi (row count, checksum sampling, smoke test).
- Monitoring + alerting aktif untuk app, DB, queue, dan error rate.
- Backup, restore drill, dan incident runbook sudah terdokumentasi.

---

## Fase 0 - Baseline & Audit (Minggu 1)

### Task

- Bekukan versi dependency (`composer.lock`, `package-lock.json`) dan pastikan install reproducible.
- Audit konfigurasi `.env` untuk pemisahan `local`, `staging`, `production`.
- Petakan semua query/raw SQL yang berpotensi spesifik MySQL.
- Jalankan baseline test: unit, feature, static analysis (`phpstan`).
- Catat performa baseline: p95 response time, throughput, memory usage.

### Output

- Dokumen baseline teknis + daftar risiko awal.
- Daftar gap menuju production-ready.

---

## Fase 1 - Hardening Aplikasi (Minggu 1-2)

### Task

- Set konfigurasi production aman:
  - `APP_DEBUG=false`
  - `LOG_LEVEL=warning` atau `error`
  - session/cookie secure (`SESSION_SECURE_COOKIE=true`).
- Pastikan semua secret dipindah ke secret manager (bukan file repo).
- Aktifkan rate limiting untuk endpoint sensitif (login, register, reset password).
- Review authorization policy dan role-permission critical path.
- Pastikan queue, cache, dan mail fallback tidak mengganggu jalur request utama.

### Output

- Security hardening checklist 100% terpenuhi.

---

## Fase 2 - Migrasi DB ke Supabase (Minggu 2-3)

## 2.1 Persiapan Supabase

### Task

- Buat project Supabase production + staging.
- Aktifkan network restriction (IP allowlist/VPC jika tersedia).
- Buat user DB terpisah:
  - `app_rw` untuk app read/write
  - `app_ro` untuk read-only/reporting
  - `migration_admin` untuk migrasi skema.
- Atur connection pooling Supabase (transaction mode untuk workload web).

### Output

- Kredensial aman tersimpan di secret manager CI/CD.

## 2.2 Adaptasi Laravel ke PostgreSQL

### Task

- Gunakan `DB_CONNECTION=pgsql`.
- Review migration yang memakai fitur spesifik MySQL (mis. `after()`, enum behavior, alter column).
- Verifikasi tipe data yang sensitif:
  - boolean
  - json/jsonb
  - datetime/timestamp timezone
  - unsigned integer assumptions.
- Jalankan `php artisan migrate:fresh --seed` pada database PostgreSQL staging.

### Output

- Semua migration dan seeder lulus di PostgreSQL staging.

## 2.3 Strategi Migrasi Data

### Task

- Pilih strategi cutover:
  1. Big bang (downtime pendek), atau
  2. Dual-write sementara + cutover bertahap.
- Ekspor data dari MySQL (logical dump) dan import ke PostgreSQL.
- Jalankan verifikasi integritas:
  - row count per tabel
  - sampling checksum data kritis
  - validasi foreign key.
- Freeze write traffic saat final sync untuk menghindari data loss.

### Output

- Laporan validasi migrasi data (signed-off).

## 2.4 Cutover Production

### Task

- Deploy release yang kompatibel PostgreSQL.
- Ubah secret environment production ke Supabase.
- Jalankan smoke test end-to-end setelah cutover.
- Monitor error rate, latency, dan query performance selama 24-48 jam.

### Output

- Production stabil di Supabase, tanpa blocker kritis.

---

## Fase 3 - CI/CD Production Grade (Minggu 3)

### Task

- Tambah pipeline bertahap:
  1. install deps
  2. lint/static analysis
  3. unit/feature test
  4. build assets
  5. deploy staging
  6. deploy production (manual approval).
- Terapkan migration gate: deploy gagal jika migration gagal.
- Simpan artifact release untuk rollback cepat.
- Buat tagging release semver + changelog otomatis.

### Output

- Pipeline CI/CD end-to-end dengan approval dan rollback.

---

## Fase 4 - Observability & Reliability (Minggu 3-4)

### Task

- Centralized logging (app logs, PHP-FPM/web logs, queue logs).
- APM/metrics dashboard:
  - request rate
  - p95/p99 latency
  - error rate
  - DB connection usage
  - slow query.
- Alerting rules:
  - error spike
  - DB connection saturation
  - queue backlog
  - failed job threshold.
- Siapkan runbook incident (sev1/sev2), on-call flow, dan SLA response.

### Output

- Dashboard + alert aktif, runbook teruji.

---

## Fase 5 - Operasional, Backup, dan DR (Minggu 4)

### Task

- Validasi backup otomatis Supabase (PITR/snapshot sesuai paket).
- Lakukan restore drill ke environment terpisah.
- Uji skenario disaster recovery (RTO/RPO target).
- Finalize SOP operasi rutin:
  - rotasi secret
  - patch dependency berkala
  - kapasitas DB dan app scaling.

### Output

- Bukti restore drill + dokumen DR disetujui.

---

## Matrix Risiko Utama

1. Inkompatibilitas query MySQL ke PostgreSQL.
   - Mitigasi: audit query + integration test PostgreSQL.
2. Downtime saat cutover.
   - Mitigasi: maintenance window + freeze write + rollback plan.
3. Performa menurun pasca migrasi.
   - Mitigasi: index review + slow query monitoring + tuning connection pool.
4. Kebocoran secret.
   - Mitigasi: secret manager + rotasi + least privilege DB user.

---

## Rollback Plan (Wajib Siap Sebelum Go-Live)

Jika cutover gagal:

1. Aktifkan maintenance mode.
2. Kembalikan env DB ke MySQL lama.
3. Redeploy artifact stabil terakhir.
4. Jalankan smoke test kritikal.
5. Buka maintenance mode.
6. Triage akar masalah sebelum jadwal cutover ulang.

---

## Checklist Go-Live Final

- [ ] UAT sign-off dari stakeholder.
- [ ] Semua critical test lulus di staging.
- [ ] Backup terbaru tervalidasi.
- [ ] Runbook incident tersedia untuk tim on-call.
- [ ] Rollback drill pernah diuji.
- [ ] Dashboard dan alert real-time aktif.
- [ ] Secrets production sudah final (Supabase).

---

## Catatan Konfigurasi Supabase untuk Laravel

Gunakan variabel environment seperti berikut pada staging/production:

- `DB_CONNECTION=pgsql`
- `DB_HOST=<your-supabase-host-or-pooler>`
- `DB_PORT=6543` (pooler) atau `5432` (direct)
- `DB_DATABASE=postgres`
- `DB_USERNAME=<your-db-user>`
- `DB_PASSWORD=<your-db-password>`
- `DB_SSLMODE=require` (tambahkan bila dibutuhkan oleh platform deployment)

Untuk performa, utamakan pooler endpoint Supabase untuk traffic aplikasi web.
