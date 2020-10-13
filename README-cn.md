# cross-any
一个易用的交叉编译环境。可以编译x86,龙芯 mips，飞腾 arm，的程序。并且是跨发行版的，各个linux操作系统厂商下都可以用 
基于Gentoo,全部由源代码编译。目前使用 glibc 2.17, bintuils 2.26, gcc 9.3.0, kernel 3.18, python 3.7, nodejs 14.  
用它编译的程序从 CentOS7 到 Ubuntu 16.04都能用，方便适配各种linux发行版。
使用这个方式编译，编译mips，arm程序不需要相关硬件，都在普通x86_64下，也不是使用模拟机。编译速度比较快，同时里面带有程序级的模拟，在编译过中创建的程序也可以直接执行，所以基本不需要改造编译脚本。  
编译完也可以直接运行测试。  
# Usage
## Read first
Check https://hub.docker.com/r/crossany/crossany/tags for the tags. We have some prebuilt tags for mips,arm,pwoerpcc,x86.  
Use the tag you need in docker commands. For example crossany/crossany:latest， crossany/crossany:mips64el-latest, crossany/crossany:mips64el-20201012. crossany/crossany:latest or crossany/crossany:date  只包含基本Gentoo环境.  crossany/crossany:arch-date 包含编译好的交叉编译环境.  
## Getting started
cross-any is to enable an execution of different multi-architecture containers by QEMU [1] and binfmt_misc [2].
Run with privileged to register binfmt_misc.
```shell
docker run --rm --privileged crossany/crossany:mips64el-20201013 /register --reset -p yes
#We use shared gentoo portage, you may need to copy that to the container /var/db/repos/gentoo if your docker version does not support volumes-from
docker create -v /usr/portage --name crossportage gentoo/portage:20201007 /bin/true
docker run -ti --volumes-from crossportage  crossany/crossany:mips64el-20201013 bash
```
## Start a docker 
```shell
docker run -ti --volumes-from crossportage crossany/crossany:mips64el-20201013 bash
```
Or run with privileged to use chroot in docker  
```shell
docker run -ti --privileged --volumes-from crossportage crossany/crossany:mips64el-20201013 bash
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