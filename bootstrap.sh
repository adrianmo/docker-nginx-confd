#!/bin/bash
set -e

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
  confd -onetime -backend etcd -node http://$ETCD_NODE
  if [ $? != 0 ]; then
    echo "Error running confd"
    exit 1
  fi

  confd -interval 10 -backend etcd -node http://$ETCD_NODE &

else
  echo "confd backend not supported: $CONFD_BACKEND"
  exit 1
fi

/usr/sbin/nginx -g 'daemon off;'
