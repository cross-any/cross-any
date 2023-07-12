# name the portage image
FROM gentoo/portage:20230703 as portage

# image is based on stage3
FROM gentoo/stage3:systemd-20230703

# copy the entire portage volume in
COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

ADD . /cross/localrepo

ENV FEATURES="-ipc-sandbox -network-sandbox -pid-sandbox -sandbox -usersandbox"
# prepare base env
RUN /bin/bash /cross/localrepo/prepare.sh

ENTRYPOINT [ "/crossenv" ]
