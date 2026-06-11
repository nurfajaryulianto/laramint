# ============================================================
# Stage 1 – Install dependencies (builder)
# ============================================================
FROM php:8.2-fpm-alpine AS builder

# System dependencies
RUN apk add --no-cache \
    bash \
    curl \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    oniguruma-dev \
    icu-dev

# PHP extensions needed by Laravel + Supabase (pgsql)
RUN docker-php-ext-install \
    pdo \
    pdo_pgsql \
    pgsql \
    zip \
    bcmath \
    mbstring \
    intl \
    gd

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy dependency manifests first (better layer caching)
COPY composer.json composer.lock ./

# Install PHP deps (no dev, optimised autoloader)
RUN composer install \
    --no-dev \
    --no-interaction \
    --no-scripts \
    --prefer-dist \
    --optimize-autoloader

# Copy the rest of the application
COPY . .

# Cache Laravel routes & config for production
RUN php artisan config:clear && \
    php artisan route:clear && \
    php artisan view:clear

# ============================================================
# Stage 2 – Lean runtime image
# ============================================================
FROM php:8.2-fpm-alpine

RUN apk add --no-cache \
    libpng \
    libzip \
    icu-libs \
    oniguruma

RUN docker-php-ext-install \
    pdo \
    pdo_pgsql \
    pgsql \
    zip \
    bcmath \
    mbstring \
    intl \
    gd

WORKDIR /var/www/html

# Copy built application from builder stage
COPY --from=builder /var/www/html /var/www/html

# Set correct permissions
RUN chown -R www-data:www-data /var/www/html/storage \
    /var/www/html/bootstrap/cache && \
    chmod -R 775 /var/www/html/storage \
    /var/www/html/bootstrap/cache

# Non-root user for security
USER www-data

EXPOSE 9000

CMD ["php-fpm"]
