#!/bin/bash
# Agente: consulta el panel por tareas pendientes y las ejecuta
set -euo pipefail

source /etc/securetech/client.env

RESP=$(curl -sS \
    -H "X-API-Key: ${API_KEY}" \
    "${API_BASE_URL}/api/pull_tasks.php?device_id=${DEVICE_ID}")

TASK_ID=$(echo "$RESP" | jq -r '.task.id // empty')
TYPE=$(echo "$RESP" | jq -r '.task.tipo_copia // empty')

if [[ -z "$TASK_ID" ]]; then
    # No hay tareas, salir silenciosamente
    exit 0
fi

echo "Tarea recibida: ID=$TASK_ID tipo=$TYPE"
/usr/local/bin/backup.sh "$TYPE" "$TASK_ID"
