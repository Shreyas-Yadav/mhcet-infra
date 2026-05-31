#!/usr/bin/env bash
# Export data from local Docker Postgres and import into Cloud SQL (dev).
set -euo pipefail

PROJECT_ID="${GCP_PROJECT_ID:-mhcet-app-498018}"
INSTANCE="${CLOUD_SQL_INSTANCE:-dev-mhcet-db}"
DB_NAME="${DB_NAME:-mhcet}"
DB_USER="${DB_USER:-mhcet}"
DOCKER_CONTAINER="${DOCKER_CONTAINER:-mhcet-db-1}"
GCS_BUCKET="${GCS_BUCKET:-mhcet-tf-state-498018}"
DUMP_FILE="/tmp/mhcet-data-clean.sql"

echo "Exporting from Docker container ${DOCKER_CONTAINER}..."
docker exec "${DOCKER_CONTAINER}" sh -c '
  pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" --data-only --table=public.colleges
  pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" --data-only --table=public.branches
  pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" --data-only --table=public.cutoffs
' | grep -vE '^(\\restrict|\\unrestrict)|DISABLE TRIGGER|ENABLE TRIGGER|SESSION AUTHORIZATION' \
  > "${DUMP_FILE}"

echo "Uploading to gs://${GCS_BUCKET}/imports/mhcet-data-clean.sql ..."
gsutil cp "${DUMP_FILE}" "gs://${GCS_BUCKET}/imports/mhcet-data-clean.sql"

echo "Importing into Cloud SQL ${INSTANCE}..."
gcloud sql import sql "${INSTANCE}" "gs://${GCS_BUCKET}/imports/mhcet-data-clean.sql" \
  --database="${DB_NAME}" \
  --user="${DB_USER}" \
  --project="${PROJECT_ID}" \
  --quiet

echo "Done. Verify: curl \${API_BASE_URL}/districts"
