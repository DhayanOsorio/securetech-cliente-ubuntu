#!/bin/bash
# Script de backup de SecureTECH para ClientePyme Ubuntu
# Uso: backup.sh [full|incremental] [task_id]
set -euo pipefail

source /etc/securetech/restic.env
source /etc/securetech/client.env

TYPE="${1:-incremental}"
TASK_ID="${2:-}"

# Validar tipo
if [[ ! "$TYPE" =~ ^(full|incremental)$ ]]; then
    echo "ERROR: Tipo no valido. Usa full o incremental" >&2
    exit 1
fi

echo "Iniciando backup $TYPE..."

START_ISO=$(date -Iseconds)
START_EPOCH=$(date +%s)
SIZE_BYTES=$(du -sb "$BACKUP_PATH" | awk '{print $1}')

# Ejecutar el backup (sin parar aunque falle)
set +e
/usr/local/bin/restic-st backup "$BACKUP_PATH" \
    --tag "device:${DEVICE_ID}" \
    --tag "mode:${TYPE}"
RC=$?
set -e

END_EPOCH=$(date +%s)
END_ISO=$(date -Iseconds)
DURATION=$((END_EPOCH - START_EPOCH))

# Obtener el ID del último snapshot
SNAPSHOT_ID=$(/usr/local/bin/restic-st snapshots --json 2>/dev/null | \
    jq -r 'sort_by(.time) | last.id // empty')

if [[ $RC -eq 0 ]]; then
    STATUS="OK"
    ERROR_MSG=""
    echo "Backup completado en ${DURATION}s. Snapshot: $SNAPSHOT_ID"
else
    STATUS="ERROR"
    ERROR_MSG="restic salió con código ${RC}"
    echo "ERROR en el backup: $ERROR_MSG" >&2
fi

# Reportar resultado a la API del panel
TASK_JSON=$([ -n "$TASK_ID" ] && echo "${TASK_ID}" || echo "null")

jq -n \
    --arg device_uid "$DEVICE_ID" \
    --arg tipo_copia "$TYPE" \
    --arg estado "$STATUS" \
    --arg fecha_inicio "$START_ISO" \
    --arg fecha_fin "$END_ISO" \
    --arg snapshot_id "$SNAPSHOT_ID" \
    --arg detalle_error "$ERROR_MSG" \
    --argjson duracion_s "$DURATION" \
    --argjson tamano_bytes "$SIZE_BYTES" \
    --argjson task_id "$TASK_JSON" \
    '{
        device_uid: $device_uid,
        tipo_copia: $tipo_copia,
        estado: $estado,
        fecha_inicio: $fecha_inicio,
        fecha_fin: $fecha_fin,
        snapshot_id: $snapshot_id,
        detalle_error: $detalle_error,
        duracion_s: $duracion_s,
        tamano_bytes: $tamano_bytes,
        task_id: $task_id
    }' | curl -sS \
        -H "Content-Type: application/json" \
        -H "X-API-Key: ${API_KEY}" \
        -X POST \
        "${API_BASE_URL}/api/report.php" \
        --data-binary @-

exit $RC
