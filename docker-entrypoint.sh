#!/bin/sh
set -e

PORT="${PORT:-8080}"

sed -i "s/^Listen .*/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/:80>/:${PORT}>/g" /etc/apache2/sites-available/000-default.conf

mkdir -p "$(dirname "${SQLITE_DB_PATH:-/data/findit.sqlite}")" "${UPLOAD_PATH:-/data/uploads}"
chown -R www-data:www-data "$(dirname "${SQLITE_DB_PATH:-/data/findit.sqlite}")" "${UPLOAD_PATH:-/data/uploads}" || true
chmod -R 775 "$(dirname "${SQLITE_DB_PATH:-/data/findit.sqlite}")" "${UPLOAD_PATH:-/data/uploads}" || true

a2dismod mpm_event >/dev/null 2>&1 || true
a2dismod mpm_worker >/dev/null 2>&1 || true
rm -f /etc/apache2/mods-enabled/mpm_event.* /etc/apache2/mods-enabled/mpm_worker.* || true
a2enmod mpm_prefork >/dev/null 2>&1 || true

exec apache2-foreground
