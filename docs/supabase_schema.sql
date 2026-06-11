-- ============================================================
-- LARAMINT - Database Schema untuk Supabase (PostgreSQL)
-- ============================================================
-- Cara penggunaan:
--   1. Buka Supabase Dashboard -> pilih project Anda
--   2. Klik menu "SQL Editor" di sidebar kiri
--   3. Paste seluruh isi file ini
--   4. Klik "Run" (atau Ctrl+Enter)
--
-- Catatan:
--   - Script ini idempotent: aman dijalankan ulang (menggunakan IF NOT EXISTS)
--   - Urutan CREATE TABLE sudah disesuaikan agar FK tidak error
--   - Tipe data MySQL sudah dikonversi ke PostgreSQL:
--       TINYINT/SMALLINT  -> SMALLINT
--       BIGINT UNSIGNED   -> BIGINT
--       ENUM              -> TEXT + CHECK CONSTRAINT
--       JSON              -> JSONB
--       LONGTEXT          -> TEXT
-- ============================================================

-- ============================================================
-- 1. USERS (+ two_factor columns)
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id                        BIGSERIAL PRIMARY KEY,
    name                      VARCHAR(255)  NOT NULL,
    email                     VARCHAR(255)  NOT NULL UNIQUE,
    coins                     INTEGER       NOT NULL DEFAULT 0,
    email_verified_at         TIMESTAMPTZ,
    password                  VARCHAR(255)  NOT NULL,
    two_factor_secret         TEXT,
    two_factor_recovery_codes TEXT,
    avatar                    VARCHAR(255),
    theme                     VARCHAR(255)  NOT NULL DEFAULT 'default',
    remember_token            VARCHAR(100),
    created_at                TIMESTAMPTZ,
    updated_at                TIMESTAMPTZ
);

-- ============================================================
-- 2. PASSWORD RESETS
-- ============================================================
CREATE TABLE IF NOT EXISTS password_resets (
    email      VARCHAR(255) NOT NULL,
    token      VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_password_resets_email ON password_resets (email);

-- ============================================================
-- 3. PERSONAL ACCESS TOKENS (Sanctum)
-- ============================================================
CREATE TABLE IF NOT EXISTS personal_access_tokens (
    id             BIGSERIAL PRIMARY KEY,
    tokenable_type VARCHAR(255) NOT NULL,
    tokenable_id   BIGINT       NOT NULL,
    name           VARCHAR(255) NOT NULL,
    token          VARCHAR(64)  NOT NULL UNIQUE,
    abilities      TEXT,
    last_used_at   TIMESTAMPTZ,
    created_at     TIMESTAMPTZ,
    updated_at     TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_pat_tokenable ON personal_access_tokens (tokenable_type, tokenable_id);

-- ============================================================
-- 4. FAILED JOBS
-- ============================================================
CREATE TABLE IF NOT EXISTS failed_jobs (
    id         BIGSERIAL PRIMARY KEY,
    uuid       VARCHAR(255) NOT NULL UNIQUE,
    connection TEXT         NOT NULL,
    queue      TEXT         NOT NULL,
    payload    TEXT         NOT NULL,
    exception  TEXT         NOT NULL,
    failed_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 5. JOBS (Queue)
-- ============================================================
CREATE TABLE IF NOT EXISTS jobs (
    id           BIGSERIAL PRIMARY KEY,
    queue        VARCHAR(255)       NOT NULL,
    payload      TEXT               NOT NULL,
    attempts     SMALLINT           NOT NULL,
    reserved_at  INTEGER,
    available_at INTEGER            NOT NULL,
    created_at   INTEGER            NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_jobs_queue ON jobs (queue);

-- ============================================================
-- 6. PERMISSIONS (Spatie laravel-permission)
-- ============================================================
CREATE TABLE IF NOT EXISTS permissions (
    id         BIGSERIAL PRIMARY KEY,
    name       VARCHAR(255) NOT NULL,
    guard_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    UNIQUE (name, guard_name)
);

CREATE TABLE IF NOT EXISTS roles (
    id         BIGSERIAL PRIMARY KEY,
    name       VARCHAR(255) NOT NULL,
    guard_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    UNIQUE (name, guard_name)
);

CREATE TABLE IF NOT EXISTS model_has_permissions (
    permission_id BIGINT       NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    model_type    VARCHAR(255) NOT NULL,
    model_id      BIGINT       NOT NULL,
    PRIMARY KEY (permission_id, model_id, model_type)
);
CREATE INDEX IF NOT EXISTS idx_mhp_model ON model_has_permissions (model_id, model_type);

CREATE TABLE IF NOT EXISTS model_has_roles (
    role_id    BIGINT       NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    model_type VARCHAR(255) NOT NULL,
    model_id   BIGINT       NOT NULL,
    PRIMARY KEY (role_id, model_id, model_type)
);
CREATE INDEX IF NOT EXISTS idx_mhr_model ON model_has_roles (model_id, model_type);

CREATE TABLE IF NOT EXISTS role_has_permissions (
    permission_id BIGINT NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    role_id       BIGINT NOT NULL REFERENCES roles(id)       ON DELETE CASCADE,
    PRIMARY KEY (permission_id, role_id)
);

-- ============================================================
-- 7. DEPARTMENTS
-- ============================================================
CREATE TABLE IF NOT EXISTS departments (
    id           BIGSERIAL PRIMARY KEY,
    title        VARCHAR(255) NOT NULL,
    description  TEXT,
    image        VARCHAR(255),
    is_published BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ,
    updated_at   TIMESTAMPTZ
);

-- ============================================================
-- 8. COURSES
-- ============================================================
CREATE TABLE IF NOT EXISTS courses (
    id            BIGSERIAL PRIMARY KEY,
    department_id BIGINT       NOT NULL REFERENCES departments(id),
    title         VARCHAR(255) NOT NULL,
    description   TEXT         NOT NULL,
    image         VARCHAR(255) NOT NULL,
    is_published  BOOLEAN      NOT NULL DEFAULT TRUE,
    deleted_at    TIMESTAMPTZ,
    created_at    TIMESTAMPTZ,
    updated_at    TIMESTAMPTZ
);

-- ============================================================
-- 9. TERMS
-- ============================================================
CREATE TABLE IF NOT EXISTS terms (
    id            BIGSERIAL PRIMARY KEY,
    title         VARCHAR(255) NOT NULL,
    department_id BIGINT       NOT NULL REFERENCES departments(id),
    course_id     BIGINT       NOT NULL REFERENCES courses(id),
    description   TEXT         NOT NULL,
    -- is_published: awalnya float, lalu diubah nullable boolean
    is_published  BOOLEAN,
    image         VARCHAR(255) NOT NULL,
    deleted_at    TIMESTAMPTZ,
    created_at    TIMESTAMPTZ,
    updated_at    TIMESTAMPTZ
);

-- ============================================================
-- 10. SESSIONS (Laramint learning sessions, bukan Laravel HTTP session)
-- ============================================================
CREATE TABLE IF NOT EXISTS sessions (
    id         BIGSERIAL PRIMARY KEY,
    title      VARCHAR(255) NOT NULL,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);

-- ============================================================
-- 11. FILES
-- ============================================================
CREATE TABLE IF NOT EXISTS files (
    id          BIGSERIAL PRIMARY KEY,
    title       VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    file        VARCHAR(255) NOT NULL,
    file_size   INTEGER,
    file_type   VARCHAR(255),
    created_at  TIMESTAMPTZ,
    updated_at  TIMESTAMPTZ
);

-- ============================================================
-- 12. DOCUMENTS
-- ============================================================
CREATE TABLE IF NOT EXISTS documents (
    id          BIGSERIAL PRIMARY KEY,
    title       VARCHAR(255) NOT NULL,
    description TEXT         NOT NULL,
    deleted_at  TIMESTAMPTZ,
    created_at  TIMESTAMPTZ,
    updated_at  TIMESTAMPTZ
);

-- ============================================================
-- 13. DOCUMENT_FILE (pivot)
-- ============================================================
CREATE TABLE IF NOT EXISTS document_file (
    id          BIGSERIAL PRIMARY KEY,
    document_id BIGINT   NOT NULL REFERENCES documents(id),
    file_id     BIGINT   NOT NULL REFERENCES files(id),
    "order"     SMALLINT NOT NULL DEFAULT 1,
    created_at  TIMESTAMPTZ,
    updated_at  TIMESTAMPTZ
);

-- ============================================================
-- 14. SESSIONABLES (polymorphic pivot: session <-> document/quiz/etc)
-- ============================================================
CREATE TABLE IF NOT EXISTS sessionables (
    id               BIGSERIAL PRIMARY KEY,
    session_id       BIGINT       NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    "order"          SMALLINT     NOT NULL DEFAULT 1,
    -- morphs: sessionable_id + sessionable_type
    sessionable_id   BIGINT       NOT NULL,
    sessionable_type VARCHAR(255) NOT NULL,
    deleted_at       TIMESTAMPTZ,
    created_at       TIMESTAMPTZ,
    updated_at       TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_sessionables_morph ON sessionables (sessionable_type, sessionable_id);

-- ============================================================
-- 15. QUESTION TYPES
-- ============================================================
CREATE TABLE IF NOT EXISTS question_types (
    id         BIGSERIAL PRIMARY KEY,
    title      VARCHAR(255) NOT NULL,
    icon       VARCHAR(255),
    is_mentor  BOOLEAN      NOT NULL DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);

-- ============================================================
-- 16. QUESTIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS questions (
    id               BIGSERIAL PRIMARY KEY,
    title            VARCHAR(255) NOT NULL,
    question_body    VARCHAR(255) NOT NULL,
    question_type_id BIGINT       NOT NULL REFERENCES question_types(id),
    answer           JSONB,
    deleted_at       TIMESTAMPTZ,
    created_at       TIMESTAMPTZ,
    updated_at       TIMESTAMPTZ
);

-- ============================================================
-- 17. RUBRICS
-- ============================================================
CREATE TABLE IF NOT EXISTS rubrics (
    id          BIGSERIAL PRIMARY KEY,
    title       VARCHAR(255) NOT NULL,
    description TEXT         NOT NULL,
    body        JSONB        NOT NULL,
    deleted_at  TIMESTAMPTZ,
    created_at  TIMESTAMPTZ,
    updated_at  TIMESTAMPTZ
);

-- ============================================================
-- 18. FEEDBACK
-- ============================================================
CREATE TABLE IF NOT EXISTS feedback (
    id          BIGSERIAL PRIMARY KEY,
    title       VARCHAR(255) NOT NULL,
    description TEXT         NOT NULL,
    require     BOOLEAN      NOT NULL DEFAULT FALSE,
    deleted_at  TIMESTAMPTZ,
    created_at  TIMESTAMPTZ,
    updated_at  TIMESTAMPTZ
);

-- ============================================================
-- 19. FEEDBACK_QUESTION (pivot)
-- ============================================================
CREATE TABLE IF NOT EXISTS feedback_question (
    id          BIGSERIAL PRIMARY KEY,
    feedback_id BIGINT   NOT NULL REFERENCES feedback(id),
    question_id BIGINT   NOT NULL REFERENCES questions(id),
    "order"     SMALLINT NOT NULL DEFAULT 1,
    deleted_at  TIMESTAMPTZ,
    created_at  TIMESTAMPTZ,
    updated_at  TIMESTAMPTZ
);

-- ============================================================
-- 20. QUIZZES
-- ============================================================
CREATE TABLE IF NOT EXISTS quizzes (
    id              BIGSERIAL PRIMARY KEY,
    title           VARCHAR(255) NOT NULL,
    description     TEXT         NOT NULL,
    attempt         SMALLINT     NOT NULL DEFAULT 0,
    duration        SMALLINT     NOT NULL DEFAULT 0,
    is_mentor       BOOLEAN      NOT NULL DEFAULT FALSE,
    is_shuffle      BOOLEAN      NOT NULL DEFAULT TRUE,
    min_pass_score  SMALLINT     NOT NULL DEFAULT 80,
    -- ENUM dikonversi ke TEXT + CHECK
    show_question   TEXT         NOT NULL DEFAULT 'StepByStep'
                    CHECK (show_question IN ('StepByStep', 'OnePage')),
    random_question SMALLINT     NOT NULL DEFAULT 0,
    deleted_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ,
    updated_at      TIMESTAMPTZ
);

-- ============================================================
-- 21. QUESTION_QUIZ (pivot)
-- ============================================================
CREATE TABLE IF NOT EXISTS question_quiz (
    id          BIGSERIAL PRIMARY KEY,
    quiz_id     BIGINT   NOT NULL REFERENCES quizzes(id),
    question_id BIGINT   NOT NULL REFERENCES questions(id),
    "order"     SMALLINT NOT NULL DEFAULT 1,
    score       SMALLINT NOT NULL DEFAULT 1,
    deleted_at  TIMESTAMPTZ,
    created_at  TIMESTAMPTZ,
    updated_at  TIMESTAMPTZ
);

-- ============================================================
-- 22. ACTIVITY LOG (Spatie laravel-activitylog)
-- ============================================================
CREATE TABLE IF NOT EXISTS activity_log (
    id           BIGSERIAL PRIMARY KEY,
    log_name     VARCHAR(255),
    description  TEXT         NOT NULL,
    -- nullableMorphs subject
    subject_id   BIGINT,
    subject_type VARCHAR(255),
    event        VARCHAR(255),
    -- nullableMorphs causer
    causer_id    BIGINT,
    causer_type  VARCHAR(255),
    properties   JSONB,
    batch_uuid   UUID,
    created_at   TIMESTAMPTZ,
    updated_at   TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_activity_log_log_name  ON activity_log (log_name);
CREATE INDEX IF NOT EXISTS idx_activity_log_subject   ON activity_log (subject_type, subject_id);
CREATE INDEX IF NOT EXISTS idx_activity_log_causer    ON activity_log (causer_type, causer_id);

-- ============================================================
-- 23. TERM_USER (pivot: term <-> user <-> role)
-- ============================================================
CREATE TABLE IF NOT EXISTS term_user (
    id         BIGSERIAL PRIMARY KEY,
    term_id    BIGINT NOT NULL REFERENCES terms(id),
    user_id    BIGINT NOT NULL REFERENCES users(id),
    role_id    BIGINT NOT NULL REFERENCES roles(id),
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);

-- ============================================================
-- 24. SESSION_TERM (pivot: session <-> term)
-- ============================================================
CREATE TABLE IF NOT EXISTS session_term (
    id         BIGSERIAL PRIMARY KEY,
    term_id    BIGINT   NOT NULL REFERENCES terms(id),
    session_id BIGINT   NOT NULL REFERENCES sessions(id),
    "order"    SMALLINT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);

-- ============================================================
-- 25. PLANS
-- ============================================================
CREATE TABLE IF NOT EXISTS plans (
    id             BIGSERIAL PRIMARY KEY,
    title          VARCHAR(255) NOT NULL,
    description    TEXT,
    "validDaysForUse" SMALLINT NOT NULL DEFAULT 0,
    price          SMALLINT     NOT NULL,
    discount       SMALLINT     NOT NULL DEFAULT 0,
    deleted_at     TIMESTAMPTZ,
    created_at     TIMESTAMPTZ,
    updated_at     TIMESTAMPTZ
);

-- ============================================================
-- 26. WORKOUTS (progress tracking user per sessionable)
-- ============================================================
CREATE TABLE IF NOT EXISTS workouts (
    id              BIGSERIAL PRIMARY KEY,
    participant_id  BIGINT      NOT NULL REFERENCES term_user(id),
    sessionable_id  BIGINT      NOT NULL REFERENCES sessionables(id),
    date_first_view TIMESTAMP   NOT NULL,
    date_last_view  TIMESTAMP,
    is_completed    BOOLEAN     NOT NULL DEFAULT FALSE,
    is_mentor       BOOLEAN     NOT NULL DEFAULT FALSE,
    score           SMALLINT    NOT NULL DEFAULT 0,
    date_get_score  TIMESTAMP,
    created_at      TIMESTAMPTZ,
    updated_at      TIMESTAMPTZ
);

-- ============================================================
-- 27. WORKOUT_QUIZ_LOGS (log jawaban quiz per workout)
-- ============================================================
CREATE TABLE IF NOT EXISTS workout_quiz_logs (
    id          BIGSERIAL PRIMARY KEY,
    workout_id  BIGINT   NOT NULL REFERENCES workouts(id),
    quiz_id     BIGINT   NOT NULL REFERENCES quizzes(id),
    question_id BIGINT   NOT NULL REFERENCES questions(id),
    answer      JSONB,
    is_mentor   BOOLEAN  NOT NULL DEFAULT FALSE,
    score       SMALLINT,
    created_at  TIMESTAMPTZ,
    updated_at  TIMESTAMPTZ
);

-- ============================================================
-- 28. MENTOR_COMMENTS (polymorphic)
-- ============================================================
CREATE TABLE IF NOT EXISTS mentor_comments (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT       NOT NULL REFERENCES users(id),
    body            TEXT         NOT NULL,
    -- morphs activable
    activable_id    BIGINT       NOT NULL,
    activable_type  VARCHAR(255) NOT NULL,
    mentor_id       BIGINT       NOT NULL REFERENCES users(id),
    confirm         BOOLEAN      NOT NULL DEFAULT FALSE,
    confirm_date    TIMESTAMP,
    interested      BOOLEAN,
    interested_date TIMESTAMP,
    deleted_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ,
    updated_at      TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_mentor_comments_activable ON mentor_comments (activable_type, activable_id);

-- ============================================================
-- 29. NOTIFICATIONS (Laravel notifications)
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
    id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    type            VARCHAR(255) NOT NULL,
    -- morphs notifiable
    notifiable_id   BIGINT       NOT NULL,
    notifiable_type VARCHAR(255) NOT NULL,
    data            TEXT         NOT NULL,
    read_at         TIMESTAMPTZ,
    created_at      TIMESTAMPTZ,
    updated_at      TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_notifications_notifiable ON notifications (notifiable_type, notifiable_id);

-- ============================================================
-- 30. CONFIGURATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS configurations (
    id              BIGSERIAL PRIMARY KEY,
    config_type     VARCHAR(255) NOT NULL,
    config_value    JSONB        NOT NULL,
    config_category VARCHAR(255) NOT NULL DEFAULT 'global',
    created_at      TIMESTAMPTZ,
    updated_at      TIMESTAMPTZ
);

-- ============================================================
-- 31. BADGES
-- ============================================================
CREATE TABLE IF NOT EXISTS badges (
    id          BIGSERIAL PRIMARY KEY,
    title       VARCHAR(255) NOT NULL,
    description VARCHAR(255) NOT NULL,
    file        VARCHAR(255) NOT NULL,
    min_coins   INTEGER      NOT NULL,
    max_coins   INTEGER      NOT NULL,
    created_at  TIMESTAMPTZ,
    updated_at  TIMESTAMPTZ
);

-- ============================================================
-- 32. COINS_LOGS
-- ============================================================
CREATE TABLE IF NOT EXISTS coins_logs (
    id           BIGSERIAL PRIMARY KEY,
    user_id      BIGINT       NOT NULL REFERENCES users(id),
    coins        SMALLINT     NOT NULL,
    -- nullableMorphs causable
    causable_id  BIGINT,
    causable_type VARCHAR(255),
    description  TEXT         NOT NULL,
    is_manual    BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMPTZ,
    updated_at   TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_coins_logs_causable ON coins_logs (causable_type, causable_id);

-- ============================================================
-- 33. MIGRATIONS TABLE (opsional – Laravel butuh ini untuk tracking)
-- ============================================================
CREATE TABLE IF NOT EXISTS migrations (
    id        SERIAL       PRIMARY KEY,
    migration VARCHAR(255) NOT NULL,
    batch     INTEGER      NOT NULL
);

-- ============================================================
-- SELESAI
-- Semua tabel berhasil dibuat.
-- Selanjutnya update .env Anda:
--   DB_CONNECTION=pgsql
--   DB_HOST=<supabase-pooler-host>
--   DB_PORT=6543
--   DB_DATABASE=postgres
--   DB_USERNAME=<user>
--   DB_PASSWORD=<password>
-- ============================================================
