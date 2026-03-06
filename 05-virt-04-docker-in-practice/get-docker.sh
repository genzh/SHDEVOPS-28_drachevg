#!/bin/bash
set -euo pipefail

BACKUP_DIR="/opt/backup"
DB_CONTAINER="shvirtd-example-python-web_db-1"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

# ✅ ПРЯМАЯ pipe из контейнера (100% рабочая!)
docker exec ${DB_CONTAINER} mysqldump \
  --single-transaction --routines --triggers \
  --opt --hex-blob \
  -uroot -proot_pass123 virtd > "${BACKUP_DIR}/virtd_${DATE}.sql"

RECORDS=$(grep -c "^INSERT INTO \`requests\` VALUES" "${BACKUP_DIR}/virtd_${DATE}.sql" || echo 0)
SIZE=$(du -h "${BACKUP_DIR}/virtd_${DATE}.sql" | cut -f1)

find "$BACKUP_DIR" -name "virtd_*.sql" -mtime +1 -delete

echo "✅ $(date): ${SIZE}, ${RECORDS} записей"