# ============================================
# 🚀 FastAPI Service - DataSimulation
# ============================================
# Aplicación FastAPI con Jinja2 templates, PostgreSQL, y matplotlib
# Usa uvicorn como servidor ASGI en producción

FROM python:3.12-slim

# Variables de entorno para Python
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Instalar dependencias del sistema necesarias para:
# - psycopg2: libpq-dev, gcc (driver nativo de PostgreSQL)
# - matplotlib: libfreetype6-dev, libpng-dev (renderizado de gráficas)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    libfreetype6-dev \
    libpng-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar e instalar dependencias de Python primero (cache de Docker)
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copiar el resto del código fuente
COPY . .

# Puerto por defecto de FastAPI/Uvicorn
EXPOSE 8000

# Healthcheck para que Docker sepa si el contenedor está sano
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD python -c "import httpx; httpx.get('http://localhost:8000/')" || exit 1

# Comando de inicio: uvicorn con hot-reload desactivado en producción
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
