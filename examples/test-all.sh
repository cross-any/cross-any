#!/bin/bash
set -e
basedir=$(realpath $(dirname $0))
echo "## Test redis"
$basedir/test-redis.sh
echo "## Test openresty"
$basedir/openresty.sh
