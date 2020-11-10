# cross-any
An cross build env for any arch with qemu and gentoo. Similar to holy-build-box but support cross build bot x86_64 and other CPUs all in a x86_64 container.      
You can use it to build linux application for x86_64/arm64/mips64el/loongson/ft-2000 ... cpus to run on any distro.  
It's shipped with glibc 2.17, bintuils 2.26, gcc 10.2.0, kernel 3.18, python 3.7, nodejs 14.  
Binary built by it can run on most linux distro from CentoOS7 to Ubuntu 16.04.  
You can just build your application as normal, not need to make any change to the build system of origin application. Just configure and make as usual.   
Compiled binary can be run directly in the build env or on target machine.
# Usage
## Read first
Check https://hub.docker.com/r/crossany/crossany/tags for the tags. We have some prebuilt tags for mips,arm,pwoerpcc,x86.  
Use the tag you need in docker commands. For example crossany/crossany:latest， crossany/crossany:mips64el-latest, crossany/crossany:mips64el-20201109. crossany/crossany:latest or crossany/crossany:date  only includes base tools.  crossany/crossany:arch-date includes the cross env for the arch.  
Precompile docker images:  
1. mips64el-latest or mips64el-20201109 ...  compiled mips64el binaries can be run on loongson  
2. aarch64-latest arm64 or with certain date ,aarch64-20201109 for example, can be used to compile arm64 apps. Compiled app should work on ft-2000 and kunpeng  etc  
3. x86_64-latest or special date version x86_64-20201109 with lower glibc version so that compiled apps can be run on most linux distro. And gcc10 generated app can get up to 10% performance enhance per my test on LibreOffice 7. 

## Getting started
cross-any is to enable an execution of different multi-architecture containers by QEMU [1] and binfmt_misc [2].
Run with privileged to register binfmt_misc.
```shell
docker run --rm --privileged crossany/crossany:mips64el-20201109 /register --reset -p yes
#We use shared gentoo portage, you may need to copy that to the container /var/db/repos/gentoo if your docker version does not support volumes-from
docker create -v /usr/portage --name crossportage gentoo/portage:20201007 /bin/true
docker run -ti --volumes-from crossportage  crossany/crossany:mips64el-20201109 bash
```
## Start a docker 
```shell
docker run -ti --volumes-from crossportage crossany/crossany:mips64el-20201109 bash
#docker run -ti --volumes-from crossportage crossany/crossany:aarch64-20201109 bash
#docker run -ti --privileged --volumes-from crossportage crossany/crossany:x86_64-20201109 bash
```
Run with --privileged is suggested.  
Or run with privileged to use chroot in docker  
```shell
docker run -ti --privileged --volumes-from crossportage crossany/crossany:mips64el-20201109 bash
```
## Use a prebuilt env
```shell
docker run --rm --privileged crossany/crossany:mips64el-latest /register --reset -p yes
#We use shared gentoo portage, you may need to copy that to the container /var/db/repos/gentoo if your docker version does not support volumes-from
docker create -v /usr/portage --name crossportage gentoo/portage:20201007 /bin/true
docker run -ti --volumes-from crossportage  crossany/crossany:mips64el-latest bash
```
## Make a cross env
```shell
/cross/localrepo/crossit mips64el-c17gcc10-linux-gnuabi64
/cross/localrepo/crossit aarch64-c17gcc10-linux-gnu
/cross/localrepo/crossit x86_64-c17gcc10-linux-gnu
```
## Use the cross env
```shell
source /usr/mips64el-c17gcc10-linux-gnuabi64/active
#do the build just as normal
#run ldconfig and /usr/mips64el-c17gcc10-linux-gnuabi64/sbin/ldconfig if you meet lib search issue
```
## Install new package
Most utils package can be install in the container directly before active cross env such make,ptotoc ... , for example:   
```shell
emerge -nuav make
```
lib for build can be install after active the cross env or using /usr/bin/$crossenv-emerge, for example  
Before active cross env:  
```shell
USE=static-libs /usr/bin/$crossenv-emerge -avun zlib
```   
Or after active:  
```shell
USE=static-libs emerge -avun zlib
```
## Where to find old package for gentoo
Clone https://github.com/gentoo/gentoo.git and checkout by date  
```shell
git clone https://github.com/gentoo/gentoo.git
git checkout `git rev-list -n 1 --first-parent --before="2018-01-01 00:00" master`
mkdir /cross/localrepo/$the_category/
cp -avf gentoo/$the_category/$the_package  /cross/localrepo/$the_category/
```
## Use different package when create the cross env
```
GCC_VERSION=9.3.0-r1 /cross/localrepo/crossit mips64el-c17gcc9-linux-gnuabi64
```
Other variables:  
```
GCC_VERSION=${GCC_VERSION:=10.2.0-r2}          #9.3.0-r1  
GLIBC_VERSION=${GLIBC_VERSION:=2.17}             #2.19-r2
KERNEL_VERSION=${KERNEL_VERSION:=3.18}
BINUTILS_VERSION=${BINUTILS_VERSION:=2.26-r1}
```
Find gentoo package versions at /var/db/repos/gentoo/sys-libs/glibc, /var/db/repos/gentoo/sys-devel/binutils, /var/db/repos/gentoo/sys-devel/gcc, /var/db/repos/gentoo/sys-kernel/linux-headers/ and /cross/localrepo.  

## Static link to libstdc++ and libgcc  
```
export LDFLAGS="$LDFLAGS -static-libstdc++ -static-libgcc"
```
## Gentoo 中文镜像
```
sed -i "s/rsync.gentoo.org/mirrors.tuna.tsinghua.edu.cn/g" /usr/share/portage/config/repos.conf
grep ^GENTOO_MIRRORS /etc/portage/make.conf>/dev/null 2>/dev/null || echo GENTOO_MIRRORS="https://mirrors.tuna.tsinghua.edu.cn/gentoo" >> /etc/portage/make.conf
grep ^gnu /etc/portage/mirrors >/dev/null 2>/dev/null|| echo gnu https://mirrors.tuna.tsinghua.edu.cn/gnu >> /etc/portage/mirrors
grep ^GENTOO_MIRRORS /usr/$crossenv/etc/portage/make.conf >/dev/null 2>/dev/null || grep ^GENTOO_MIRRORS /etc/portage/make.conf >> /usr/$crossenv/etc/portage/make.conf
/bin/cp -avf /etc/portage/mirrors /usr/$crossenv/etc/portage/mirrors
```
## Examples
   openresty build and libreoffice build preparation script in examples folder  
```
time bash /cross/localrepo/examples/openresty.sh
```
>real	3m16.150s  
>user	5m30.568s  
>sys	0m46.301s  
   ```
file /opt/openresty/nginx/sbin/nginx 
   ```
>/opt/openresty/nginx/sbin/nginx: ELF 64-bit LSB pie executable, MIPS, MIPS-III version 1 (SYSV), dynamically linked, interpreter /lib64/ld.so.1, for GNU/Linux 2.6.16, with debug_info, not stripped
```
/opt/openresty/nginx/sbin/nginx  -t
```
>nginx: the configuration file /opt/openresty/nginx/conf/nginx.conf syntax is ok  
>nginx: configuration file /opt/openresty/nginx/conf/nginx.conf test is successful  
# References
1. QEMU: https://www.qemu.org/
1. binfmt_misc: https://www.kernel.org/doc/html/latest/admin-guide/binfmt-misc.html
1. https://wiki.gentoo.org/wiki/Cross_build_environment
1. https://github.com/gentoo/gentoo-docker-images
1. https://wiki.gentoo.org/wiki/Version_specifier
1. https://wiki.gentoo.org/wiki/Gentoo_Cheat_Sheet
1. https://mirror.tuna.tsinghua.edu.cn/help/gentoo-portage/
1. https://edoceo.com/sys/emerge
1. https://wiki.gentoo.org/wiki//etc/portage/mirrors
1. https://wiki.gentoo.org/wiki/Dedicated_Build_Machine-Single_ARCH#Prepare_BUILD_machine
1. https://wiki.gentoo.org/wiki/Custom_repository#Crossdev
1. https://github.com/multiarch/qemu-user-static
1. https://www.kernel.org/doc/html/latest/admin-guide/binfmt-misc.html
1. https://github.com/phusion/holy-build-box
