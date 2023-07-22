#!/bin/bash
set -e
locale-gen
rm -f /etc/portage/repos.conf/*
cd /var/db/pkg
find dev-perl -type d|grep /|sed "s/dev-perl/=dev-perl/g"|xargs emerge -v -j$(nproc)
emerge --tree -j$JOBS -vn =sys-devel/make-4.3-r1
PYTHON_TARGETS="python3_11" LUA_SINGLE_TARGET=lua5-4 emerge --tree -j$JOBS -vn --autounmask-continue --autounmask=y --autounmask-write ruby rpm dpkg \
        && gem install fpm \
        && find $ROOT/usr/local/*/ruby/gems/*/gems/fpm-*/templates/ -name "*.sh" -o -name "*.sh.erb"|xargs sed -i "s#/bin/sh#/bin/bash#g"
rm -rf $ROOT/var/tmp/* $ROOT/var/log/* $ROOT/var/cache/*/*
rm -rf $ROOT/cross/localrepo/*.core
