# ============================================
# 🐘 Laravel App - RecollirEnquestesEnPHP
# ============================================
# El proyecto Laravel está dentro del subdirectorio enquestes/
# Multi-stage para instalar Composer y luego servir con php:apache

# --- STAGE 1: Instalar dependencias con Composer ---
FROM php:8.3-cli AS composer-deps

# Instalar composer dentro de PHP 8.3 para compatibilidad
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Instalar dependencias del sistema necesarias para composer
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    git \
    libzip-dev \
    libpq-dev \
    && docker-php-ext-install zip pgsql \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar ficheros de Composer desde el subdirectorio enquestes/
COPY enquestes/composer.json ./

# Desactivar el bloqueo por advisories de seguridad (Laravel 10 tiene CVEs conocidos)
# TODO: Actualizar a Laravel 11+ cuando sea posible
RUN composer config --global policy.advisories.block false

# Generar de nuevo las dependencias (update) en vez de usar el lock
RUN composer update \
    --no-dev \
    --no-interaction \
    --no-scripts \
    --prefer-source \
    --optimize-autoloader \
    --ignore-platform-reqs

# --- STAGE 2: Imagen de producción con Apache ---
FROM php:8.3-apache

# Instalar extensiones de PHP necesarias para Laravel
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libxml2-dev \
    libpq-dev \
    libonig-dev \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        mbstring \
        xml \
        bcmath \
        zip \
        gd \
    && rm -rf /var/lib/apt/lists/*

# Habilitar mod_rewrite de Apache (necesario para Laravel)
RUN a2enmod rewrite

# Configurar Apache para apuntar al directorio public/ de Laravel
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf \
    /etc/apache2/apache2.conf

WORKDIR /var/www/html

# Copiar dependencias de Composer desde el stage anterior
COPY --from=composer-deps /app/vendor ./vendor

# Copiar el código fuente de Laravel (desde enquestes/)
COPY enquestes/ .

# Crear directorios necesarios y dar permisos a storage y cache
RUN mkdir -p storage/framework/{sessions,views,cache} \
    storage/logs \
    bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Crear .env mínimo - las variables DB_* vienen del docker-compose.yml
# Laravel necesita APP_KEY y un .env file para funcionar
RUN rm -f .env && \
    echo "APP_NAME=Enquestes" > .env && \
    echo "APP_ENV=production" >> .env && \
    echo "APP_DEBUG=true" >> .env && \
    echo "APP_URL=http://localhost" >> .env && \
    echo "LOG_CHANNEL=stack" >> .env && \
    echo "SESSION_DRIVER=file" >> .env && \
    echo "CACHE_DRIVER=file" >> .env && \
    echo "QUEUE_CONNECTION=sync" >> .env

EXPOSE 80

CMD ["apache2-foreground"]
