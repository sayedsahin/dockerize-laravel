# 1️⃣ Base image (PHP 8.3 FPM on Debian 13 base)
FROM php:8.2-fpm

# 2️⃣ Pass build arguments
ARG UID=1000
ARG GID=1000

# 3️⃣ Create non-root user matching host UID/GID
RUN addgroup --gid $GID laravel \
    && adduser --disabled-password --gecos "" --uid $UID --gid $GID laravel

# 2️⃣ System dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev libzip-dev nodejs npm netcat-openbsd \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

 # 3️⃣ Composer install
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 4️⃣ Set working directory
WORKDIR /var/www/html

# 5️⃣ Copy application source
COPY . .

# 6️⃣ Copy entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh



RUN chmod +x /usr/local/bin/entrypoint.sh

# 7️⃣ Ensure permissions for Laravel writable dirs
RUN mkdir -p storage/framework/{cache,sessions,views} \
    && mkdir -p storage/app/public bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# 🔟 Enable PHP Opcache for performance
RUN docker-php-ext-enable opcache

# 🔧 Expose port
EXPOSE 9000

# 🏁 Entrypoint
ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm"]
