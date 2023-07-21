#!/bin/bash
set -e
locale-gen
rm -f /etc/portage/repos.conf/*
cd /var/db/pkg
find dev-perl -type d|grep /|sed "s/dev-perl/=dev-perl/g"|xargs emerge -v -j$(nproc)
