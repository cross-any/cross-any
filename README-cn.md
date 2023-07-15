# cross-any
一个易用的交叉编译环境。可以编译x86,龙芯 mips，飞腾 arm，riscv等cpu的程序。并且是跨发行版的，各个linux操作系统厂商下都可以用。类似holy-build-box、crossbuild,但是支持交叉编译更多的cpu。更容易安装软件。   
基于Gentoo,全部由源代码编译。目前使用 glibc 2.17, bintuils 2.26, gcc 10.2.0, kernel 3.18, python 3.11, nodejs 18.  
用它编译的程序从 CentOS7 到 Ubuntu 16.04都能用，方便适配各种linux发行版。
使用这个方式编译，编译mips，arm程序不需要相关硬件，都在普通x86_64下，也不是使用模拟机。编译速度比较快，同时里面带有程序级的模拟，在编译过中创建的程序也可以直接执行，所以基本不需要改造编译脚本。  
编译完也可以直接运行测试。  
https://github.com/cross-any/cross-any/  
https://gitee.com/crossany/cross-any/  
[旧版](../2020/README.md)
# Usage
## Read first
Check https://hub.docker.com/r/crossany/crossany/tags for the tags. We have some prebuilt tags for mips,arm,pwoerpcc,x86.  
Use the tag you need in docker commands. For example crossany/crossany:latest， crossany/crossany:mips64el-latest, crossany/crossany:mips64el-2023. crossany/crossany:latest or crossany/crossany:date  只包含基本Gentoo环境.  crossany/crossany:arch-date 包含编译好的交叉编译环境.  
目前已经自动编译的包括:  
1. mips64el版，mips64el-latest或者带对应的日期，例如mips64el-2023, 可以编译龙芯cpu可用的程序，目前使用的标准mips64el，没有使用龙芯指令集  
2. aarch64也就是arm64版，aarch64-latest或者带对应的日期，例如aarch64-2023, 可以编译飞腾-2000和鲲鹏等arm cpu可用的程序，目前使用的标准arm64指令集  
3. x86_64 普通x86版, x86_64-latest或者x86_64-2023。 只是降低了glibc版本，方便编译跨发行版的二进制文件。另外因为使用的最新版的gcc，编译的结果程序质量好一下。自测LibreOffice在使用gcc10编译比使用gcc8，9同编译选项的情况下带来10%左右的提升。当然测试机器和软件数量有限，不能确定这个是否一般规律  
4. loongarch64-latest或者带对应的日期，例如loongarch64-2023, 可以编译龙芯cpu可用的程序，使用龙芯指令集
5. riscv64-latest or riscv64-2023 ...  compiled riscv64 binaries can be run on riscv64 cpu  
docker hub 仓库地址: index.docker.io/crossany/crossany  
阿里云仓库地址: registry.cn-beijing.aliyuncs.com/crossany/crossany  
## Getting started
cross-any is to enable an execution of different multi-architecture containers by QEMU [1] and binfmt_misc [2].
Run with privileged to register binfmt_misc.
```shell
docker run --rm --privileged crossany/crossany:mips64el-2023 /register --reset -p yes
#docker run --rm --privileged crossany/crossany:aarch64-2023 /register --reset -p yes
#docker run --rm --privileged crossany/crossany:x86_64-2023 /register --reset -p yes
#docker run --rm --privileged crossany/crossany:loongarch64-2023 /register --reset -p yes
#docker run --rm --privileged crossany/crossany:riscv64-2023 /register --reset -p yes
#We use shared gentoo portage, you may need to copy that to the container /var/db/repos/gentoo if your docker version does not support volumes-from
docker run -ti -v $PWD:/root/host  crossany/crossany:mips64el-2023 bash
#docker run -ti -v $PWD:/root/host  crossany/crossany:aarch64-2023 bash
#docker run -ti -v $PWD:/root/host  crossany/crossany:x86_64-2023 bash
#docker run -ti -v $PWD:/root/host  crossany/crossany:loongarch64-2023 bash
#docker run -ti -v $PWD:/root/host  crossany/crossany:riscv64-2023 bash
```
## Start a docker 
```shell
docker run -ti -v $PWD:/root/host  crossany/crossany:mips64el-2023 bash
#docker run -ti -v $PWD:/root/host  crossany/crossany:aarch64-2023 bash
#docker run -ti -v $PWD:/root/host  crossany/crossany:x86_64-2023 bash
#docker run -ti -v $PWD:/root/host  crossany/crossany:loongarch64-2023 bash
#docker run -ti -v $PWD:/root/host  crossany/crossany:riscv64-2023 bash
#docker run -ti --privileged -v $PWD:/root/host  crossany/crossany:x86_64-2023 bash
```
Run with --privileged is suggested.  
Or run with privileged to use chroot in docker  
```shell
docker run -ti --privileged -v $PWD:/root/host  crossany/crossany:mips64el-2023 bash
```
## Use a prebuilt env
```shell
docker run --rm --privileged crossany/crossany:mips64el-2023 /register --reset -p yes
#docker run --rm --privileged crossany/crossany:aarch64-2023 /register --reset -p yes
#docker run --rm --privileged crossany/crossany:x86_64-2023 /register --reset -p yes
#docker run --rm --privileged crossany/crossany:loongarch64-2023 /register --reset -p yes
#docker run --rm --privileged crossany/crossany:riscv64-2023 /register --reset -p yes
#We use shared gentoo portage, you may need to copy that to the container /var/db/repos/gentoo if your docker version does not support volumes-from
docker run -ti -v $PWD:/root/host  crossany/crossany:mips64el-2023 bash
#docker run -ti -v $PWD:/root/host  crossany/crossany:aarch64-2023 bash
#docker run -ti -v $PWD:/root/host  crossany/crossany:x86_64-2023 bash
#docker run -ti -v $PWD:/root/host  crossany/crossany:loongarch64-2023 bash
#docker run -ti -v $PWD:/root/host  crossany/crossany:riscv64-2023 bash
```
## Make a cross env
```shell
/cross/localrepo/crossit mips64el-crossany-linux-gnuabi64
/cross/localrepo/crossit aarch64-crossany-linux-gnu
/cross/localrepo/crossit x86_64-crossany-linux-gnu
/cross/localrepo/crossit loongarch64-crossany-linux-gnu
/cross/localrepo/crossit riscv64-crossany-linux-gnu
```
## Use the cross env
```shell
source /usr/mips64el-crossany-linux-gnuabi64/active
#source /usr/aarch64-crossany-linux-gnu/active
#source /usr/x86_64-crossany-linux-gnu/active
#source /usr/loongarch64-crossany-linux-gnu/active
#source /usr/riscv64-crossany-linux-gnu/active
#do the build just as normal
#run ldconfig and /usr/mips64el-crossany-linux-gnuabi64/sbin/ldconfig if you meet lib search issue
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
ebuild /cross/localrepo/$the_category/xxx.ebuild manifest
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
## 静态链接 libstdc++ and libgcc
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
