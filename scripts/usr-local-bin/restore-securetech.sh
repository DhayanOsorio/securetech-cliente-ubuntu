#!/bin/bash
set -euo pipefail

RESTIC_CMD="/usr/local/bin/restic-securetech"

SNAPSHOT="${1:-latest}"
TARGET="${2:-/tmp/restore_prueba}"

mkdir -p "$TARGET"

"$RESTIC_CMD" restore "$SNAPSHOT" --target "$TARGET"
echo "Restauración completada en: $TARGET"
