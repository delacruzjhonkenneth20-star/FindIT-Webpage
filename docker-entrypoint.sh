#!/bin/sh
set -e

PORT="${PORT:-8080}"

sed -i "s/^Listen .*/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/:80>/:${PORT}>/g" /etc/apache2/sites-available/000-default.conf

mkdir -p "$(dirname "${SQLITE_DB_PATH:-/data/findit.sqlite}")" "${UPLOAD_PATH:-/data/uploads}"
chown -R www-data:www-data "$(dirname "${SQLITE_DB_PATH:-/data/findit.sqlite}")" "${UPLOAD_PATH:-/data/uploads}" || true
chmod -R 775 "$(dirname "${SQLITE_DB_PATH:-/data/findit.sqlite}")" "${UPLOAD_PATH:-/data/uploads}" || true

# Railway's runtime can re-enable the default MPM module even though the
# Dockerfile already switched to mpm_prefork at build time. Rather than
# rely on a2dismod succeeding, forcibly remove any enabled MPM module
# symlink that isn't prefork, then make sure prefork is enabled.
find /etc/apache2/mods-enabled -maxdepth 1 -iname '*mpm*' ! -iname '*prefork*' -exec rm -f {} \; 2>/dev/null || true
a2enmod mpm_prefork >/dev/null 2>&1 || true

echo "MPM modules currently enabled:"
ls -1 /etc/apache2/mods-enabled/ | grep -i mpm || echo "(none found)"

exec apache2-foreground
