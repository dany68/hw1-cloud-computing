# Change to the project directory
cd /var/www/html/hw1-cloud-computing

# Turn on maintenance mode
php artisan down || true

# Pull the latest changes from the git repository
# git reset --hard
# git clean -df
git pull origin master

# Install/update composer dependecies
composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

# Restart FPM
# ( flock -w 10 9 || exit 1
#     echo 'Restarting FPM...'; sudo -S service $FORGE_PHP_FPM reload ) 9>/tmp/fpmlock

# Run database migrations
php artisan migrate --force

# Clear caches
php artisan cache:clear

# Clear and cache routes
php artisan route:cache

# Clear and cache config
php artisan config:cache

# Clear and cache views
php artisan view:cache

# Turn off maintenance mode
php artisan up