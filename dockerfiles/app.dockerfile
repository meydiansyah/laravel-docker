FROM php:8.0-fpm

# Set working directory
WORKDIR /var/www/html

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_17.x -o nodesource_setup.sh \
    && bash nodesource_setup.sh \
    && apt-get -y --force-yes install nodejs

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libonig-dev \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    wget \
    libfontconfig1 \
    libxrender1 \
    libssl-dev \
    curl

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions
RUN install-php-extensions pdo_mysql zip exif pcntl gd redis imagick

# Install composer
RUN install-php-extensions @composer

RUN sed -i "s/user = www-data/user = root/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = root/g" /usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

# Install wkhtmltopdf
# RUN apt update
# RUN apt install -y \
#     fontconfig \
#     xfonts-75dpi \
#     xfonts-base
# RUN wget -P /home https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_amd64.deb
# RUN dpkg -i /home/wkhtmltox_0.12.6-1.buster_amd64.deb
# RUN rm -rf /home/wkhtmltox_0.12.6-1.buster_amd64.deb

# Add user for laravel application
# RUN addgroup -g 1001 --system www
# RUN adduser -G www --system -D -s /bin/sh -u 1001 www

# RUN groupadd -g 1000 www
# RUN useradd -u 1000 -ms /bin/bash -g www www

# Change current user to www
# USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000

CMD ["php-fpm", "-y", "/usr/local/etc/php-fcm.conf", "-R"]
