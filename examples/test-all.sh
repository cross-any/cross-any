#!/bin/bash
set -e
basedir=$(realpath $(dirname $0))
$basedir/test-redis.sh