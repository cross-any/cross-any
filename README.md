# cross-any
An cross build env for any arch with qemu and gentoo.  
You can use it to build linux application for x86_64/arm64/mips64el/loongson/ft-2000 ... cpus to run on any distro.  
It's shipped with glibc 2.17, bintuils 2.26, gcc 9.3.0, kernel 3.18, python 3.7, nodejs 14.  
Binary built by it can run on most linux distro from CentoOS7 to Ubuntu 16.04.  
You can just build your application as normal, not need to make any change to the build system of origin application. Just configure and make as usual.   
# Usage
## Getting started
cross-any is to enable an execution of different multi-architecture containers by QEMU [1] and binfmt_misc [2].
Run with privileged to register binfmt_misc.
```shell
docker run --rm --privileged justdb/cross-any /register --reset -p yes
docker run --ti justdb/cross-any bash
```
## Start a docker 
```shell
docker run --ti justdb/cross-any bash
```
Or run with privileged to use chroot in docker  
```shell
docker run --ti --privileged justdb/cross-any bash
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
## Examples
   openresty build and libreoffice build preparation script in examples folder
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