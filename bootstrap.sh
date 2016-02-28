#!/bin/bash
set -e

TOML=/etc/confd/conf.d/nginx.toml

if [ -z "$CONFD_BACKEND" ]; then
  echo "CONFD_BACKEND environment variable not set. Exiting..."
  exit 1
fi

if [ "$CONFD_BACKEND" == "etcd" ]; then
  if [ -z "$ETCD_NODE" ]; then
    echo "ETCD_NODE environment variable not set. Exiting..."
    exit 1
  fi

  #launch it one time to see if it fails
  confd -onetime -backend etcd -node http://$ETCD_NODE -config-file ${TOML}
  if [ $? != 0 ]; then
    echo "Error running confd"
    exit 1
  fi

  confd -interval 10 -backend etcd -node http://$ETCD_NODE &
  echo "[nginx] confd is now monitoring etcd for changes..."

else
  echo "confd backend not supported: $CONFD_BACKEND"
  exit 1
fi

# Start the Nginx service using the generated config
echo "[nginx] starting nginx service..."
exec /usr/sbin/nginx -g 'daemon off;'
