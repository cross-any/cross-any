#!/bin/bash
set -e
set -x
basedir=$(realpath $(dirname $0))
mkdir -p $basedir/downloads
pushd $basedir/downloads
wget -N https://download.redis.io/redis-stable.tar.gz
popd
pushd $HOME
rm -rf redis-stable
tar xvf $basedir/downloads/redis-stable.tar.gz
cd redis-stable
make
make PREFIX=$PWD/dist install
file ./dist/bin/redis-server
./dist/bin/redis-server &
sleep 2
./dist/bin/redis-benchmark
./dist/bin/redis-cli shutdown
popd
