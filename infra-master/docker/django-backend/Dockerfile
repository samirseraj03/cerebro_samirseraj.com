# ============================================
# 🐍 Django Backend - Wether (API Real)
# ============================================

FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Instalar dependencias del sistema (incluye libpq-dev para PostgreSQL)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements y hacer la instalación
COPY requirements.txt* ./
RUN if [ -f requirements.txt ]; then \
        pip install --no-cache-dir --upgrade pip && \
        pip install --no-cache-dir -r requirements.txt; \
    fi

# Copiar el código fuente
COPY . .

# Modificar ALLOWED_HOSTS de forma dinámica (para que funcione sin alterar el git reset)
RUN if [ -f "config/settings.py" ]; then \
        sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \['*'\]/" config/settings.py; \
    fi

EXPOSE 8000

# Ejecutar migraciones, el script de inicialización de datos (seed.py), y luego iniciar el servidor Django real
CMD ["sh", "-c", "python manage.py migrate && python seed.py && python manage.py runserver 0.0.0.0:8000"]
