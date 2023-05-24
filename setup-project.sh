#!/bin/bash

# Update the server
sudo apt update

# Install necessary packages
echo "Installing required packages..."
sudo apt install nginx
sudo ufw allow 'Nginx HTTP'

sudo apt install mysql-server
sudo mysql_secure_installation

sudo apt install php-fpm php-mysql
sudo apt install php-mbstring php-xml php-bcmath

# MySQL and the project .env file must be configured
# sudo mysql
# create database hw1;
# exit;
# sudo nano /var/www/html/hw1-cloud-computing/.env # Set the DATABASE env variables accordingly

# Nginx must be configured as follow:
# cd /etc/nginx/sites-available
# sudo nano hw1-cloud-computing
# server {
#     listen 80;
#     listen [::]:80;
#     root /var/www/html/hw1-cloud-computing/public;
#     index  index.php index.html index.htm;
#     server_name _;

#     location / {
#         try_files $uri $uri/ =404;       
#     }

  
#      # pass PHP scripts to FastCGI server
#         #
#         location ~ \.php$ {
#                include snippets/fastcgi-php.conf;
#         #
#         #       # With php-fpm (or other unix sockets):
#                fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
#         #       # With php-cgi (or other tcp sockets):
#         #       fastcgi_pass 127.0.0.1:9000;
#         }
# }

# We enable the project via a symlink
sudo ln -s /etc/nginx/sites-available/hw1-cloud-computing /etc/nginx/sites-enabled
# Restart Nginx
sudo systemctl restart nginx.service

# Clone Laravel project from GitHub
echo "Cloning Laravel project from GitHub..."
git clone https://github.com/dany68/hw1-cloud-computing /var/www/html

# Install Laravel dependencies
echo "Installing Laravel dependencies..."
cd /var/www/html
sudo apt install composer
cd hw1-cloud-computing
composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

# Generate Laravel application key
echo "Generating Laravel application key..."
php artisan key:generate

# Run database migrations
php artisan migrate --force

# We give permission for the storage and bootstrap folders
sudo chown -R www-data:www-data /var/www/html/hw1-cloud-computing/storage
sudo chown -R www-data:www-data /var/www/html/hw1-cloud-computing/bootstrap

# Start Laravel development server
echo "Starting Laravel development server..."
php artisan serve

# Wait for Laravel server to start
echo "Waiting for Laravel server to start..."