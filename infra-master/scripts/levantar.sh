#!/bin/bash
# Arranca todo el ecosistema

# Obtener el directorio raíz del proyecto (infra-master)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR" || exit 1

echo "📁 Directorio de trabajo: $ROOT_DIR"

# 1. Asegurar permisos de ejecución del script de clonación
chmod +x "$SCRIPT_DIR/clonar_o_actualizar.sh"

# 2. Ejecutar la sincronización de repositorios y dependencias
echo ""
echo "=== PASO 1: Sincronizar repositorios ==="
"$SCRIPT_DIR/clonar_o_actualizar.sh"

# 3. Verificar que docker compose está disponible
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado. Instálalo primero."
    exit 1
fi

# 4. Levantar contenedores limpios o actualizados
echo ""
echo "=== PASO 2: Levantar servicios Docker ==="
echo "🚀 Construyendo y levantando servicios..."
docker compose up -d --build

echo ""
echo "=== ESTADO DE LOS CONTENEDORES ==="
docker compose ps

echo ""
echo "🎉 ¡Todo el ecosistema está en línea!"