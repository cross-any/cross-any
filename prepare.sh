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
cp -avf profiles/thirdpartymirrors $ROOT/var/db/repos/gentoo/profiles/thirdpartymirrors
if [ "$USE_MIRROR" = "CN" ]; then
  sed -i "s/rsync.gentoo.org/mirrors.tuna.tsinghua.edu.cn/g" $ROOT/usr/share/portage/config/repos.conf
  grep ^GENTOO_MIRRORS $ROOT/etc/portage/make.conf>/dev/null 2>/dev/null || echo GENTOO_MIRRORS="https://mirrors.tuna.tsinghua.edu.cn/gentoo" >> $ROOT/etc/portage/make.conf
  grep ^gnu $ROOT/etc/portage/mirrors >/dev/null 2>/dev/null|| echo gnu https://mirrors.tuna.tsinghua.edu.cn/gnu >> $ROOT/etc/portage/mirrors
fi
#emerge --tree --sync
ulimit -a

emerge --tree -j$JOBS -vn --autounmask-continue --autounmask=y --autounmask-write dev-util/ninja lsof =sys-devel/make-4.3-r1
#emerge --tree -j$JOBS -vn --autounmask-continue --autounmask=y --autounmask-write '=sys-devel/gcc-13*'
#gcc-config 2
PYTHON_TARGETS="python3_11" USE=pam emerge --tree -j$JOBS -vn --autounmask-continue --autounmask=y --autounmask-write crossdev vim dev-vcs/git dev-util/patchelf app-portage/gentoolkit dev-util/pkgdev sudo file app-admin/eselect app-arch/zip app-arch/zstd  dev-libs/libxml2
PYTHON_TARGETS="python3_11" USE="static-user -python" QEMU_USER_TARGETS="x86_64 loongarch64 hexagon aarch64 aarch64_be alpha arm armeb cris hppa i386 m68k microblaze microblazeel mips mips64 mips64el mipsel mipsn32 mipsn32el nios2 or1k ppc ppc64 ppc64abi32 ppc64le riscv32 riscv64 s390x sh4 sh4eb sparc sparc32plus sparc64 tilegx xtensa xtensaeb"  emerge --tree   --autounmask-continue --autounmask=y --autounmask-write  -vn -j$JOBS '>app-emulation/qemu-8'
# QEMU_SOFTMMU_TARGETS=-x86_64

mkdir -p $ROOT/cross/crossdev/{profiles,metadata}
echo 'crossdev' > $ROOT/cross/crossdev/profiles/repo_name
echo 'masters = gentoo' > $ROOT/cross/crossdev/metadata/layout.conf
chown -R portage:portage $ROOT/cross 

mkdir -p $ROOT/etc/portage/repos.conf
if [ ! -e $ROOT/etc/portage/repos.conf/localrepo.conf ]; then
cat > $ROOT/etc/portage/repos.conf/localrepo.conf <<EOF
[localrepo]
location = $basefolder
masters = gentoo
auto-sync = yes
sync-type = git
sync-uri = https://github.com/cross-any/cross-any.git
EOF
fi
if [ ! -e $ROOT/etc/portage/repos.conf/crossdev.conf ]; then
cat > $ROOT/etc/portage/repos.conf/crossdev.conf <<EOF
[crossdev]
location = $crossrepofolder
priority = 10
masters = gentoo
auto-sync = no
EOF
fi

# if [ "$USE_MIRROR" = "CN" ]; then
#   emerge --tree -vn -j$JOBS  '=net-libs/nodejs-14*::localrepo'
# else
#   emerge --tree -vn -j$JOBS  '=net-libs/nodejs-14*::gentoo'
# fi
emerge --tree -vn -j$JOBS --autounmask-continue --autounmask=y --autounmask-write '=net-libs/nodejs-18.16.1' '<sys-devel/gcc-13'
emerge --tree -vn -j$JOBS --autounmask-continue --autounmask=y --autounmask-write libffi '=dev-lang/python-3.11*' acct-group/nobody acct-user/nobody

cat <<EOF >>/etc/locale.gen
zh_CN.UTF8 UTF-8
en_US.UTF8 UTF-8
EOF
locale-gen
popd
#fpm to allow build rpm or deb package
PYTHON_TARGETS="python3_11" LUA_SINGLE_TARGET=lua5-4 emerge --tree -j$JOBS -vn --autounmask-continue --autounmask=y --autounmask-write '<ruby-3.2'
PYTHON_TARGETS="python3_11" LUA_SINGLE_TARGET=lua5-4 emerge --tree -j$JOBS -vn --autounmask-continue --autounmask=y --autounmask-write rpm dpkg
gem install fpm
find $ROOT/usr/local/*/ruby/gems/*/gems/fpm-*/templates/ -name "*.sh" -o -name "*.sh.erb"|xargs sed -i "s#/bin/sh#/bin/bash#g"
rm -rf $ROOT/var/tmp/* $ROOT/var/log/* $ROOT/var/cache/*/*
rm -rf $ROOT/cross/localrepo/*.core
ln -s $basefolder/register.sh $ROOT/register
ln -s $basefolder/register.sh $ROOT/usr/bin/register
ln -s $basefolder/crossenv $ROOT/crossenv
ln -s $basefolder/crossenv $ROOT/usr/bin/crossenv
ln -s $basefolder/crossit $ROOT/usr/bin/crossit
ln -s $basefolder/nativerun $ROOT/usr/bin/nativerun
chmod +x $basefolder/crossenv
