#!/bin/bash
set -e
set -x
basedir=$(realpath $(dirname $0))
mkdir -p $basedir/downloads
pushd $basedir/downloads
wget -N --no-check-certificate --content-disposition https://sourceforge.net/projects/pcre/files/pcre/8.45/pcre-8.45.tar.gz/download
wget -N --no-check-certificate https://www.openssl.org/source/openssl-3.1.1.tar.gz
wget -N --no-check-certificate https://www.zlib.net/zlib-1.2.13.tar.gz
wget -N --no-check-certificate https://nginx.org/download/nginx-1.25.1.tar.gz
wget -N --no-check-certificate --content-disposition https://github.com/aperezdc/ngx-fancyindex/archive/refs/tags/v0.5.2.tar.gz
wget -N --no-check-certificate --content-disposition http://hg.nginx.org/njs/archive/0.8.0.tar.gz  #njs-0.8.0.tar.gz
popd
mkdir -p $HOME/nginx
pushd $HOME/nginx
rm -rf nginx-1.25.1
tar xvf $basedir/downloads/ngx-fancyindex-0.5.2.tar.gz
tar xvf $basedir/downloads/pcre-8.45.tar.gz
tar xvf $basedir/downloads/openssl-3.1.1.tar.gz
tar xvf $basedir/downloads/zlib-1.2.13.tar.gz
tar xvf $basedir/downloads/nginx-1.25.1.tar.gz
tar xvf $basedir/downloads/njs-0.8.0.tar.gz
if [ "$(arch)" = "loongarch64" ]; then
# export PERL5LIB=/usr/$crossenv/usr/lib/perl5/5.36:/usr/$crossenv/usr/lib/perl5/5.36/loongarch64-linux
# if [ ! -e $basedir/downloads/LuaJIT-v2.1-loongarch64.zip ]; then
#   wget https://github.com/loongson/LuaJIT/archive/refs/heads/v2.1-loongarch64.zip -O $basedir/downloads/LuaJIT-v2.1-loongarch64.zip
# fi
# mv nginx-1.25.1/bundle/LuaJIT-2.1* .
# pushd nginx-1.25.1/bundle
# unzip $basedir/downloads/LuaJIT-v2.1-loongarch64.zip
# popd
wget -O pcre-8.45/config.sub "https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub"
wget -O pcre-8.45/config.guess "https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess"
fi
#correct mips64el setting for openssl
#sed -i "s/linux-mips64/linux64-mips64/g" openssl-3.1.1/config
sed -i "s/linux-mips64/linux64-mips64/g" openssl-3.1.1/util/perl/OpenSSL/config.pm

# compile it
cd nginx-1.25.1
PREFIX=$PWD/dist.$(arch)/nginx
env USE="static-libs" emerge -j8 -vn dev-libs/libxslt
time ./configure --prefix=$PREFIX --with-http_v2_module --with-http_ssl_module --with-http_auth_request_module --with-pcre=$PWD/../pcre-8.45 --with-openssl=$PWD/../openssl-3.1.1 --with-zlib=$PWD/../zlib-1.2.13  --add-module=$PWD/../ngx-fancyindex-0.5.2 --add-module=$PWD/../njs-0.8.0/nginx
time make -j 8
make install

mkdir $PREFIX/conf.d
# start nginx
$PREFIX/sbin/nginx
$PREFIX/sbin/nginx -t
#stop
#stop
$basedir/../nativerun emerge -j8 -vn apache-tools
ab -n 100000 -c 20 http://localhost/
$PREFIX/sbin/nginx -s quit
popd
