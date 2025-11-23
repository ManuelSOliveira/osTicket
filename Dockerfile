FROM php:8.1-apache

# Instala extensões PHP necessárias
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libxml2-dev \
    libonig-dev \
    libc-client-dev \
    libkrb5-dev \
    libicu-dev \
    unzip \
    git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) \
    gd \
    mysqli \
    pdo \
    pdo_mysql \
    zip \
    mbstring \
    xml \
    intl \
    gettext \
    imap \
    && rm -rf /var/lib/apt/lists/*

# Configura Apache
RUN a2enmod rewrite

# Copia código osTicket
WORKDIR /var/www/html
COPY . .

# Permissões
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Cria directório de uploads
RUN mkdir -p include/attachments \
    && chown -R www-data:www-data include/attachments \
    && chmod -R 755 include/attachments

EXPOSE 80

CMD ["apache2-foreground"]
