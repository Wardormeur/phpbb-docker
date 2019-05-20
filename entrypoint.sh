#!/bin/sh
# shellcheck shell=dash

set -e

db_migrate() {
  local store=/var/www/html/phpBB/store
  # Wait 5 seconds for the db server to be available:
  sleep 5
  # Run db migration via phpBB CLI and log stdout and stderr to files:
  php bin/phpbbcli.php db:migrate \
    >> "$store"/db_migrate_out_"$(date +%s)".log \
    2>> "$store"/db_migrate_err_"$(date +%s)".log
  # Remove log files which are empty or older than 30 days:
  find "$store" -type f -name '*.log' \( -empty -o -mtime +30 \) -exec rm {} +
}

chmod 755 /var/www/html/phpBB/cache
chown www-data /var/www/html/phpBB/cache
chmod 755 /var/www/html/phpBB/store
chown www-data /var/www/html/phpBB/store
chmod 755 /var/www/html/phpBB/files
chown www-data /var/www/html/phpBB/files
chmod 755 /var/www/html/phpBB/ext
chown www-data /var/www/html/phpBB/ext

# Wait for mysql
maxcounter=120
 
counter=1
echo "$DBHOST $DBUSER $DBPASSWD"; 
while ! mysql --protocol TCP -h "$DBHOST" -u"$DBUSER" -p"$DBPASSWD" -e "show databases;" > /dev/null 2>&1; do
    sleep 1
    counter=`expr $counter + 1`
    if [ $counter -gt $maxcounter ]; then
        >&2 echo "We have been waiting for MySQL too long already; failing."
        exit 1
    fi;
done

# NOTE: is this bad ?
# Should we really modify the apache config from a plugin ?
chown www-data:www-data /var/www/html/phpBB/.htaccess
chown -R www-data /var/www/html/phpBB/cache/production

echo "installed ? $PHPBB_INSTALLED";
if [ "$PHPBB_INSTALLED" = "false" ]; then
  rm /var/www/html/phpBB/config.php
  echo "setting config.php"
  cp /etc/phpBB/install-config.yml /var/www/html/phpBB/install/install-config.yml
  php /var/www/html/phpBB/install/phpbbcli.php install /var/www/html/phpBB/install/install-config.yml 2> /dev/stderr
elif [ "$AUTO_DB_MIGRATE" = "true" ]; then
  # Run db migration as background process:
  db_migrate &
else 
  cp /etc/phpBB/config.php /var/www/phpBB/html/config.php
  chown www-data /var/www/html/phpBB/composer-ext.json
  chown www-data /var/www/html/phpBB/composer-ext.lock
fi

chown www-data /var/www/html/phpBB/config.php
chmod 755 /var/www/html/phpBB/config.php

cd phpBB
composer install --dev
rm -rf /var/www/html/phpBB/install # Disable install so the board can be used
exec apache2-foreground "$@"
