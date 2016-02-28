#!/bin/bash
set -e

TOML=/etc/confd/conf.d/nginx.toml

if [ -z "$CONFD_BACKEND" ]; then
  echo "CONFD_BACKEND environment variable not set. Exiting..."
  exit 1
fi

if [ "$CONFD_BACKEND" == "etcd" ]; then
  if [ -z "$ETCD_HOST" ]; then
    echo "ETCD_HOST environment variable not set. Exiting..."
    exit 1
  fi
  CONFD_PARAMS="-backend etcd -node http://$ETCD_HOST"
else
  echo "confd backend not supported: $CONFD_BACKEND"
  exit 1
fi

# Launch it one time to see if it configured correctly
confd -onetime $CONFD_PARAMS -config-file ${TOML}
if [ $? != 0 ]; then
  echo "Error running confd"
  exit 1
fi

confd -interval 10 $CONFD_PARAMS -config-file ${TOML} &
echo "[nginx] confd is now monitoring etcd for changes..."

# Start the Nginx service using the generated config
echo "[nginx] starting nginx service..."
exec /usr/sbin/nginx -g 'daemon off;'
