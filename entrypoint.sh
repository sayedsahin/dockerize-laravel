#!/bin/bash
set -e

echo "🚀 Starting Laravel container..."

# Detect if Laravel is installed
if [ ! -f artisan ]; then
    echo "⚙️  No Laravel project detected, skipping Laravel setup."
    echo "🟢 Starting main process..."
    exec "$@"
    exit 0
fi

# Prepare storage and cache directories
echo "📁 Preparing Laravel directories..."
mkdir -p storage/framework/{cache,sessions,views}
mkdir -p storage/app/public bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Create .env if missing
if [ ! -f .env ] && [ -f .env.example ]; then
    echo "⚙️  .env not found, creating from .env.example"
    cp .env.example .env
fi

# Generate APP_KEY if missing
if ! grep -q "^APP_KEY=" .env || grep -q "^APP_KEY=$" .env; then
    echo "🔑 Generating APP_KEY..."
    php artisan key:generate --force || true
fi

# Wait for database if DB_HOST is defined
if [ -n "$DB_HOST" ]; then
    echo "⏳ Waiting for database at $DB_HOST..."
    until nc -z -v -w30 $DB_HOST 3306; do
        echo "   ... still waiting ..."
        sleep 5
    done
    echo "✅ Database is ready!"
fi

# Cache optimizations
echo "⚡ Running Laravel cache optimizations..."
php artisan config:clear || true
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

echo "🟢 Starting main process..."
exec "$@"
