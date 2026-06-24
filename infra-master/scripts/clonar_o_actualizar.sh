#!/bin/bash
# Comprueba cambios en GitHub, descarga y buildea

# Obtener el directorio raíz del proyecto (infra-master)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR" || exit 1

# Cargar variables del archivo .env
set -a
source .env
set +a

PROYECTOS_DIR="$ROOT_DIR/proyectos"
DOCKER_DIR="$ROOT_DIR/docker"
mkdir -p "$PROYECTOS_DIR"

# Lista de tus repositorios (Formato: usuario/repositorio)
REPOS=(
    "samirseraj03/Wether"                # django
    "samirseraj03/DataSimulation"         # fastapi
    "samirseraj03/RecollirEnquestesEnPHP" # laravel
    "samirseraj03/my_porfolio"            # frontend-porfolio
)

# Nombres de las carpetas locales equivalentes
CARPETAS=(
    "django-backend"
    "fastapi-service"
    "laravel-app"
    "web-frontend"
)

echo "=== VERIFICANDO REPOSITORIOS Y ACTUALIZACIONES ==="

for i in "${!REPOS[@]}"; do
    REPO=${REPOS[$i]}
    CARPETA=${CARPETAS[$i]}
    PATH_PROYECTO="$PROYECTOS_DIR/$CARPETA"

    # URL usando el Token HTTPS para repositorios privados
    URL_AUTH="https://${GH_TOKEN}@github.com/${REPO}.git"

    if [ ! -d "$PATH_PROYECTO/.git" ]; then
        # Si no existe o no es un repo git, limpiar y clonar
        if [ -d "$PATH_PROYECTO" ]; then
            echo "⚠️  $CARPETA existe pero no es un repo git. Limpiando..."
            rm -rf "$PATH_PROYECTO"
        fi
        echo "⬇️  Clonando por primera vez: $CARPETA..."
        if git clone "$URL_AUTH" "$PATH_PROYECTO" 2>/dev/null; then
            echo "✅ $CARPETA clonado correctamente."
        else
            echo "❌ Error clonando $CARPETA. Creando directorio vacío para simulación..."
            mkdir -p "$PATH_PROYECTO"
        fi
    else
        echo "🔄 Comprobando actualizaciones para $CARPETA..."
        pushd "$PATH_PROYECTO" > /dev/null || continue

        # Actualizar URL del remoto (por si cambia el token)
        git remote set-url origin "$URL_AUTH"

        git fetch origin > /dev/null 2>&1

        LOCAL=$(git rev-parse @ 2>/dev/null)
        REMOTE=$(git rev-parse @{u} 2>/dev/null)

        if [ -z "$REMOTE" ]; then
            echo "⚠️  No se pudo determinar la rama remota para $CARPETA. Saltando..."
        elif [ "$LOCAL" != "$REMOTE" ]; then
            echo "🆕 ¡Cambios detectados! Actualizando código de $CARPETA..."
            git pull origin main 2>/dev/null || git pull origin master 2>/dev/null
            echo "🐳 Forzando reconstrucción de imágenes..."
            docker compose -f "$ROOT_DIR/docker-compose.yml" build "$CARPETA"
        else
            echo "✅ $CARPETA ya está actualizado."
        fi

        popd > /dev/null
    fi

    # Copiar Dockerfile, .dockerignore y archivos de config desde docker/
    if [ -d "$DOCKER_DIR/$CARPETA" ]; then
        echo "📦 Copiando configuración Docker para $CARPETA..."
        cp -f "$DOCKER_DIR/$CARPETA/"* "$PATH_PROYECTO/" 2>/dev/null
    fi

    echo ""
done
echo "=================================================="