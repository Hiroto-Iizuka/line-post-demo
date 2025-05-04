#!/bin/sh

set -e

rm -f /sample-api/tmp/pids/server.pid

exec "$@"
