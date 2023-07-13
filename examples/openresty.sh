#!/bin/bash
set -e
set -x
basedir=$(realpath $(dirname $0))
mkdir -p $basedir/downloads
pushd $basedir/downloads
wget -N --no-check-certificate --content-disposition https://sourceforge.net/projects/pcre/files/pcre/8.45/pcre-8.45.tar.gz/download
wget -N --no-check-certificate https://www.openssl.org/source/openssl-3.1.1.tar.gz
wget -N --no-check-certificate https://www.zlib.net/zlib-1.2.13.tar.gz
wget -N --no-check-certificate https://openresty.org/download/openresty-1.21.4.1.tar.gz
wget -N --no-check-certificate -O ngx-fancyindex-0.5.2.tar.gz https://github.com/aperezdc/ngx-fancyindex/archive/refs/tags/v0.5.2.tar.gz
popd
mkdir -p $HOME/openresty
pushd $HOME/openresty
rm -rf openresty-1.21.4.1
tar xvf $basedir/downloads/ngx-fancyindex-0.5.2.tar.gz
tar xvf $basedir/downloads/pcre-8.45.tar.gz
tar xvf $basedir/downloads/openssl-3.1.1.tar.gz
tar xvf $basedir/downloads/zlib-1.2.13.tar.gz
tar xvf $basedir/downloads/openresty-1.21.4.1.tar.gz

#correct mips64el setting for openssl
#sed -i "s/linux-mips64/linux64-mips64/g" openssl-3.1.1/config
sed -i "s/linux-mips64/linux64-mips64/g" openssl-3.1.1/util/perl/OpenSSL/config.pm

# compile it
cd openresty-1.21.4.1
PREFIX=$PWD/dist.$(arch)
time ./configure --prefix=$PREFIX --with-http_v2_module --with-http_ssl_module --with-http_auth_request_module --with-pcre=$PWD/../pcre-8.45 --with-openssl=$PWD/../openssl-3.1.1 --with-zlib=$PWD/../zlib-1.2.13  --add-module=$PWD/../ngx-fancyindex-0.5.2
time make -j 8
make install

mkdir $PREFIX/nginx/conf.d
# start nginx
$PREFIX/nginx/sbin/nginx
$PREFIX/nginx/sbin/nginx -t
#stop
#stop
$basedir/../nativerun emerge -j8 -vn app-arch/zstd
$basedir/../nativerun emerge -j8 -vn apache-tools
$PREFIX/nginx/sbin/nginx -s quit
popd
