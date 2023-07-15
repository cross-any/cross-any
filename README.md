# Introducing 
## crossany  
A Powerful Cross-Building Environment for Any Architectures  
crossany is an advanced cross-building environment designed to support multiple CPU architectures, including x86_64, arm64, mips64el, riscv64, loongson, ft-2000, and more. Similar to "holy-build-box" in compatibility,crossbuild in cross cpu targets. It offers comprehensive cross-building capabilities within an x86_64/arm64 container, ensuring maximum performance and compatibility.  
## Key Features:  
### Versatile Architecture Support:  
crossany enables seamless cross-building for a wide range of CPU architectures, including x86_64, arm64, mips64el, riscv64, loongson, ft-2000, and others. It provides flexibility for developing Linux applications to run on any distributions. Just use /crossit [gnu target triplet] [15](https://wiki.osdev.org/Target_Triplet) to build one env if there's no prebuilt images.  
###  Extensive Distribution Compatibility:  
Incorporating glibc 2.17, binutils 2.26, and gcc 10.2.0, kernel version 3.18, as well as Python 3.11 and Node.js 18, crossany ensures compatibility with a wide range of application requirements.  
The binaries built using crossany are highly compatible and can run smoothly on various Linux distributions, including CentOS7 and Ubuntu 16.04, providing enhanced deployment options.  
###  Seamless Integration: 
crossany minimizes the need for significant modifications to your existing build system. You can build your applications as usual, allowing for a seamless integration process.  
### Efficient Mixed Environment:  
Leveraging a mixed environment, crossany combines the use of high-speed cross-compilers and native binaries, such as "uname" for the target architecture, leveraging QEMU when required. This approach eliminates the need to execute compilers on slow target machines, significantly enhancing performance.  
### Streamlined Workflow:  
Configure and compile your applications effortlessly using the familiar methods you are accustomed to. With crossany there's no need to overhaul your existing build processes. Just simplify it.  
### Easy Developing:  
The compiled binaries can be executed directly within the crossany build environment or effortlessly deployed onto the target machine, ensuring hassle-free deployment, developing and execution.  

## Source code and documents
https://github.com/cross-any/cross-any/  
https://gitee.com/crossany/cross-any/  
[Old version](../2020/README.md)  

# Usage
## Read first
Check https://hub.docker.com/r/crossany/crossany/tags for the tags. We have some prebuilt tags for mips64el,aarach64(arm),x86_64,riscv64,loongarch64.  
Use the tag you need in docker commands. For example crossany/crossany:latest， crossany/crossany:mips64el-latest, crossany/crossany:mips64el-2023. crossany/crossany:latest or crossany/crossany:date  only includes base tools.  crossany/crossany:arch-date includes the cross env for that arch.  
Precompile docker images:  
1. mips64el-latest or mips64el-2023 ...  compiled mips64el binaries can be run on loongson  
2. aarch64-latest arm64 or with certain date ,aarch64-2023 for example, can be used to compile arm64 apps. Compiled app should work on ft-2000 and kunpeng  etc  
3. x86_64-latest or special date version x86_64-2023 with lower glibc version so that compiled apps can be run on most linux distro. And gcc10 generated app can get up to 10% performance enhance per my test on LibreOffice 7.  
4. loongarch64-latest or loongarch64-2023 ...  compiled loongarch64 binaries can be run on loongson  
5. riscv64-latest or riscv64-2023 ...  compiled riscv64 binaries can be run on riscv64 cpu  
## Docker image repositories
docker hub repository: index.docker.io/crossany/crossany  
aliyun repository: registry.cn-beijing.aliyuncs.com/crossany/crossany  
You can try aliyun repository if docker hub is slow for you.Just replace crossany/crossany with registry.cn-beijing.aliyuncs.com/crossany/crossany in following examples.   
## In short  
```
docker run --rm --privileged crossany/crossany:aarch64-2023 /register --reset -p yes
git clone https://github.com/cross-any/cross-any.git
cd cross-any
docker run --rm -ti --workdir /ws -v $PWD/examples/helloworld:/ws crossany/crossany:aarch64-2023 make clean all package
ls examples/helloworld
```
## Getting started
cross-any is to enable an execution of different multi-architecture containers by QEMU [1] and binfmt_misc [2].
Run with privileged to register binfmt_misc. This step just need to be run one time.  
```shell
docker run --rm --privileged crossany/crossany:mips64el-2023 /register --reset -p yes
#docker run --rm --privileged crossany/crossany:aarch64-2023 /register --reset -p yes
#docker run --rm --privileged crossany/crossany:x86_64-2023 /register --reset -p yes
#docker run --rm --privileged crossany/crossany:loongarch64-2023 /register --reset -p yes
#docker run --rm --privileged crossany/crossany:riscv64-2023 /register --reset -p yes
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
Run with --privileged is suggested if you want run chroot in docker  
```shell
docker run -ti --privileged -v $PWD:/root/host  crossany/crossany:mips64el-2023 bash
```
## Make a cross env
```shell
/cross/localrepo/crossit mips64el-crossany-linux-gnuabi64
/cross/localrepo/crossit aarch64-crossany-linux-gnu
/cross/localrepo/crossit x86_64-crossany-linux-gnu
/cross/localrepo/crossit loongarch64-crossany-linux-gnu
/cross/localrepo/crossit riscv64-crossany-linux-gnu
```
You can build with different gcc/glibc/kernel version by setting the following envrioment variables before call crossit.  
GCC_VERSION=${GCC_VERSION:=10.2.0-r2}   
GLIBC_VERSION=${GLIBC_VERSION:=2.17}  
KERNEL_VERSION=${KERNEL_VERSION:=3.18}  
BINUTILS_VERSION=${BINUTILS_VERSION:=2.26-r1}  
BINUTILS_STAGE3_VERSION=${BINUTILS_STAGE3_VERSION:=2.35.1}  

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
crossany will set the cross compile env if you run an arch tag. Just excute the build command to build the project.  
The following command will build the helloworld example project at https://github.com/cross-any/cross-any/tree/2023/examples/helloworld. The helloworld project itself is a sample Makefile project to build greating apps write in c and c++, packages to deb,rpm and zip archive.  
```
   docker run --rm -ti --workdir /ws -v $PWD/examples/helloworld:/ws crossany/crossany:aarch64-2023 make clean all package
   ls examples/helloworld/dist/
```
`demo-greet-1.0_aarch64.rpm  demo-greet-1.0_aarch64.zip  demo-greet-1.0_arm64.deb`   
 
You can also find the openresty and redis build script in examples folder  
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
# Commands  
   /crossenv      #image entrypoint, switch to the five cross env by crossenv envirionemnt variable. It will call crossit to build one if the given one not exists.  
   /crossit       #build an cross compiler env. It accepts the compile triplet [15](https://wiki.osdev.org/Target_Triplet) such as x86_64-xxxx-linux-gnu.  
   source /usr/xxx/active #enter cross compile env.  
   deactive       #leave cross env  
   nativerun      #run native command if you are in a cross env    
#  Prebuild images  
   prebuild env                              image tag   
   mips64el-crossany-linux-gnuabi64       mips64el-2023  
   aarch64-crossany-linux-gnu             aarch64-2023  
   x86_64-crossany-linux-gnu              x86_64-2023  
   loongarch64-crossany-linux-gnu         loongarch64-2023  , new world   
   riscv64-crossany-linux-gnu             riscv64-2023

# Gentoo Commands maybe help when working with gentoo package
   ebuild xxx.ebuild manifest #refresh xxx package after modify the ebuild file  
   portageq owners / /usr/bin/bash  #find the package for a file
   equery b /usr/bin/bash  #find the package for a file
   emerge --ask --verbose --update --newuse --deep @world #update
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
1. https://wiki.osdev.org/Target_Triplet
