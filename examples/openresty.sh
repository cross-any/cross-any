#!/bin/bash
mkdir openresty
pushd openresty
wget -N --no-check-certificate https://pan.bjtxra.com/files/releases/files/pcre-8.44.tar.gz
wget -N --no-check-certificate https://pan.bjtxra.com/files/releases/files/openssl-1.1.1h.tar.gz
wget -N --no-check-certificate https://pan.bjtxra.com/files/releases/files/zlib-1.2.11.tar.gz
wget -N --no-check-certificate https://pan.bjtxra.com/files/releases/files/openresty-1.17.8.2.tar.gz
wget -N --no-check-certificate https://pan.bjtxra.com/files/releases/files/ngx-fancyindex-0.4.2.tar.gz

tar xvf ngx-fancyindex-0.4.2.tar.gz
tar xvf pcre-8.44.tar.gz
tar xvf openssl-1.1.1h.tar.gz
tar xvf zlib-1.2.11.tar.gz
tar xvf openresty-1.17.8.2.tar.gz

#correct mips64el setting for openssl
sed -i "s/linux-mips64/linux64-mips64/g" openssl-1.1.1h/config

# compile it
cd openresty-1.17.8.2
time ./configure --prefix=/opt/openresty --with-http_v2_module --with-http_ssl_module --with-http_auth_request_module --with-pcre=$PWD/../pcre-8.44 --with-openssl=$PWD/../openssl-1.1.1h --with-zlib=$PWD/../zlib-1.2.11  --add-module=$PWD/../ngx-fancyindex-0.4.2
time make -j 8
make install

sudo mkdir /opt/openresty/nginx/conf.d
# start nginx
/opt/openresty/nginx/sbin/nginx
#stop
#pkill nginx

popd
