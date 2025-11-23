FROM php:8.1-apache

# Instala extensões PHP necessárias
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libxml2-dev \
    libonig-dev \
    libicu-dev \
    unzip \
    git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
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
    && rm -rf /var/lib/apt/lists/*

# Configura Apache
RUN a2enmod rewrite

# Copia código osTicket
WORKDIR /var/www/html
COPY . .

# Permissões
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Cria directórios necessários
RUN mkdir -p include/attachments \
    && chown -R www-data:www-data include/attachments \
    && chmod -R 755 include/attachments

# Copia ficheiro de configuração de amostra
RUN cp include/ost-sampleconfig.php include/ost-config.php \
    && chmod 0666 include/ost-config.php

# Remove setup após primeira instalação (descomenta após instalar)
RUN rm -rf setup/

EXPOSE 80

CMD ["apache2-foreground"]
