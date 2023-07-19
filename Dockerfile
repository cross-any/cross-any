ARG GCC_VERSION=
ARG GLIBC_VERSION=
ARG KERNEL_VERSION=
ARG BINUTILS_VERSION=
ARG BINUTILS_STAGE3_VERSION=
# name the portage image
FROM gentoo/portage:20230703 as portage

# image is based on stage3
FROM gentoo/stage3:systemd-20230703

# copy the entire portage volume in
COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

ADD . /cross/localrepo

ENV FEATURES="-ipc-sandbox -network-sandbox -pid-sandbox -sandbox -usersandbox"
# prepare base env
RUN /bin/env GCC_VERSION="${GCC_VERSION}" \
	GLIBC_VERSION="${GLIBC_VERSION}" \
	KERNEL_VERSION="${KERNEL_VERSION}" \
	BINUTILS_VERSION="${BINUTILS_VERSION}" \
	BINUTILS_STAGE3_VERSION="${BINUTILS_STAGE3_VERSION}" \
	/bin/bash /cross/localrepo/prepare.sh

ENTRYPOINT [ "/crossenv" ]
