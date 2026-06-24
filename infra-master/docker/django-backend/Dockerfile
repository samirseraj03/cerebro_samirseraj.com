# ============================================
# 🐍 Django Backend - Wether (Simulado)
# ============================================
# Proyecto en desarrollo: actualmente solo funciones sueltas (funcions.py, program.py).
# Simulamos un servidor HTTP básico hasta que se convierta en Django real.

FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements si existe, sino crear uno mínimo
COPY requirements.txt* ./
RUN if [ -f requirements.txt ]; then \
        pip install --no-cache-dir --upgrade pip && \
        pip install --no-cache-dir -r requirements.txt; \
    else \
        pip install --no-cache-dir --upgrade pip; \
    fi

# Copiar el código fuente
COPY . .

# Crear un servidor HTTP simple que sirva como placeholder
# hasta que el proyecto se convierta en Django real
RUN echo 'from http.server import HTTPServer, SimpleHTTPRequestHandler\n\
import json\n\
\n\
class HealthHandler(SimpleHTTPRequestHandler):\n\
    def do_GET(self):\n\
        if self.path == "/" or self.path == "/health":\n\
            self.send_response(200)\n\
            self.send_header("Content-type", "application/json")\n\
            self.end_headers()\n\
            response = {"status": "ok", "service": "django-backend (simulado)", "message": "Wether - En desarrollo"}\n\
            self.wfile.write(json.dumps(response).encode())\n\
        else:\n\
            super().do_GET()\n\
\n\
if __name__ == "__main__":\n\
    server = HTTPServer(("0.0.0.0", 8000), HealthHandler)\n\
    print("🐍 Servidor Django simulado en puerto 8000")\n\
    server.serve_forever()\n' > server.py

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/')" || exit 1

CMD ["python", "server.py"]
