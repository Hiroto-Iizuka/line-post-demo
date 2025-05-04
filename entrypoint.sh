#!/bin/sh

set -e

cd /app

rm -f tmp/pids/server.pid

exec "$@"
