#/bin/sh
set -e
set -x
basefolder=$(realpath $(dirname $0))
crossrepofolder=$(realpath $basefolder/../crossdev)
JOBS=$(nproc --all||echo 2)
if [ "$JOBS" = 1 ]; then
    JOBS=2
fi
pushd $(dirname $0)
cp -avf profiles/thirdpartymirrors /var/db/repos/gentoo/profiles/thirdpartymirrors
if [ "$USE_MIRROR" = "CN" ]; then
  sed -i "s/rsync.gentoo.org/mirrors.tuna.tsinghua.edu.cn/g" /usr/share/portage/config/repos.conf
  grep ^GENTOO_MIRRORS /etc/portage/make.conf>/dev/null 2>/dev/null || echo GENTOO_MIRRORS="https://mirrors.tuna.tsinghua.edu.cn/gentoo" >> /etc/portage/make.conf
  grep ^gnu /etc/portage/mirrors >/dev/null 2>/dev/null|| echo gnu https://mirrors.tuna.tsinghua.edu.cn/gnu >> /etc/portage/mirrors
fi
#emerge --sync
ulimit -a

emerge -j$JOBS -vn --autounmask-continue --autounmask=y --autounmask-write dev-util/ninja lsof =sys-devel/make-4.3-r1
#emerge -j$JOBS -vn --autounmask-continue --autounmask=y --autounmask-write '=sys-devel/gcc-13*'
#gcc-config 2
emerge -j$JOBS -vn --autounmask-continue --autounmask=y --autounmask-write crossdev vim dev-vcs/git app-portage/gentoolkit dev-util/pkgdev sudo file app-admin/eselect
USE="static-user" QEMU_USER_TARGETS="loongarch64 hexagon aarch64 aarch64_be alpha arm armeb cris hppa i386 m68k microblaze microblazeel mips mips64 mips64el mipsel mipsn32 mipsn32el nios2 or1k ppc ppc64 ppc64abi32 ppc64le riscv32 riscv64 s390x sh4 sh4eb sparc sparc32plus sparc64 tilegx xtensa xtensaeb"  emerge   --autounmask-continue --autounmask=y --autounmask-write  -vn -j$JOBS qemu
# QEMU_SOFTMMU_TARGETS=-x86_64

mkdir -p /cross/crossdev/{profiles,metadata}
echo 'crossdev' > /cross/crossdev/profiles/repo_name
echo 'masters = gentoo' > /cross/crossdev/metadata/layout.conf
chown -R portage:portage /cross 

mkdir -p /etc/portage/repos.conf
if [ ! -e /etc/portage/repos.conf/localrepo.conf ]; then
cat > /etc/portage/repos.conf/localrepo.conf <<EOF
[localrepo]
location = $basefolder
masters = gentoo
auto-sync = yes
sync-type = git
sync-uri = https://github.com/cross-any/cross-any.git
EOF
fi
if [ ! -e /etc/portage/repos.conf/crossdev.conf ]; then
cat > /etc/portage/repos.conf/crossdev.conf <<EOF
[crossdev]
location = $crossrepofolder
priority = 10
masters = gentoo
auto-sync = no
EOF
fi

# if [ "$USE_MIRROR" = "CN" ]; then
#   emerge -vn -j$JOBS  '=net-libs/nodejs-14*::localrepo'
# else
#   emerge -vn -j$JOBS  '=net-libs/nodejs-14*::gentoo'
# fi
emerge -vn -j$JOBS --autounmask-continue --autounmask=y --autounmask-write '=net-libs/nodejs-18.16.1'
emerge -vn -j$JOBS --autounmask-continue --autounmask=y --autounmask-write dev-lang/python acct-group/nobody
# emerge -vn -j$JOBS  '=python-3.7*'

cat <<EOF >>/etc/locale.gen
zh_CN.UTF8 UTF-8
en_US.UTF8 UTF-8
EOF
locale-gen
popd
rm -rf /var/tmp/* /var/log/* /var/cache/*/*
ln -s $basefolder/register.sh /register
