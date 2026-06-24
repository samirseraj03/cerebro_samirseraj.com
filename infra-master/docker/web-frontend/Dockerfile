# ============================================
# 🌐 Web Frontend - Portfolio (React + Vite + TypeScript)
# ============================================
# Multi-stage build para optimizar el tamaño de la imagen final
# Stage 1: Build → Stage 2: Servir con Nginx

# --- STAGE 1: Build de la aplicación ---
FROM node:20-alpine AS builder

WORKDIR /app

# Copiar ficheros de dependencias primero (para aprovechar cache de Docker)
COPY package.json package-lock.json* ./

# Instalar dependencias
RUN npm ci --production=false

# Copiar el resto del código fuente
COPY . .

# Construir la aplicación para producción
RUN npm run build

# --- STAGE 2: Servir con Nginx ---
FROM nginx:alpine AS production

# Eliminar la configuración por defecto de Nginx
RUN rm -rf /usr/share/nginx/html/*

# Copiar los archivos construidos desde el builder
COPY --from=builder /app/dist /usr/share/nginx/html

# Configuración de Nginx personalizada para SPA (Single Page Application)
# Redirige todas las rutas al index.html para el router del frontend
RUN echo 'server { \
    listen 80; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    \
    # Compresión gzip \
    gzip on; \
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript image/svg+xml; \
    gzip_min_length 256; \
    \
    # Cache de assets estáticos (JS, CSS, imágenes) \
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ { \
        expires 1y; \
        add_header Cache-Control "public, immutable"; \
    } \
    \
    # SPA fallback: cualquier ruta desconocida → index.html \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
