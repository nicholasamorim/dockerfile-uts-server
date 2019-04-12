#!/bin/sh
set -e


if [ "$1" = 'uts-server' ] && [ "$#" -eq 1 ]; then
    echo "Running in development mode with test certs as user $USER"
    exec uts-server -c /opt/uts-server/tests/cfg/uts-server.cnf -D
fi

echo "Running with arguments: $@"
exec uts-server "$@"
