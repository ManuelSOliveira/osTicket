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
    curl \
    wget \
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
RUN mkdir -p include/attachments include/i18n \
    && chown -R www-data:www-data include/attachments include/i18n \
    && chmod -R 755 include/attachments include/i18n

# Copia ficheiro de configuração de amostra
RUN cp include/ost-sampleconfig.php include/ost-config.php \
    && chmod 0666 include/ost-config.php

# Download pack de Português de Portugal (pt_PT)
# Nota: Se pt_PT não estiver disponível, usa pt_BR como fallback
RUN curl -L -f -o include/i18n/pt_PT.phar \
    https://osticket.com/sites/default/files/download/lang/pt_PT.phar \
    || curl -L -f -o include/i18n/pt_BR.phar \
    https://osticket.com/sites/default/files/download/lang/pt_BR.phar \
    || echo "Aviso: Pack de português não encontrado"

# Permissões para packs de idioma
RUN for lang in pt_PT pt_BR; do \
    if [ -f "include/i18n/${lang}.phar" ]; then \
        chown www-data:www-data "include/i18n/${lang}.phar" && \
        chmod 644 "include/i18n/${lang}.phar"; \
    fi; \
    done

# Define locale pt_PT (importante para formatação de datas, etc)
RUN apt-get update && apt-get install -y locales \
    && echo "pt_PT.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen pt_PT.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=pt_PT.UTF-8
ENV LANGUAGE=pt_PT:pt:en
ENV LC_ALL=pt_PT.UTF-8

EXPOSE 80

CMD ["apache2-foreground"]
