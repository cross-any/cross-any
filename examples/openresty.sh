#!/bin/bash
set -e
set -x
if [ "$(arch)" = "riscv64" ]; then
    echo LuaJIT not supported on riscv64. Check later.
    exit 0
fi
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
if [ "$(arch)" = "loongarch64" ]; then
export PERL5LIB=/usr/$crossenv/usr/lib/perl5/5.36:/usr/$crossenv/usr/lib/perl5/5.36/loongarch64-linux
if [ ! -e $basedir/downloads/LuaJIT-v2.1-loongarch64.zip ]; then
  wget https://github.com/loongson/LuaJIT/archive/refs/heads/v2.1-loongarch64.zip -O $basedir/downloads/LuaJIT-v2.1-loongarch64.zip
fi
mv openresty-1.21.4.1/bundle/LuaJIT-2.1* .
pushd openresty-1.21.4.1/bundle
unzip $basedir/downloads/LuaJIT-v2.1-loongarch64.zip
popd
wget -O pcre-8.45/config.sub "https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub"
wget -O pcre-8.45/config.guess "https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess"
fi
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
ab -n 100000 -c 20 http://localhost/
$PREFIX/nginx/sbin/nginx -s quit
popd
