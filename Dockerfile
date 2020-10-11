# name the portage image
FROM gentoo/portage:20201007 as portage

# image is based on stage3
FROM gentoo/stage3:systemd-20201007

# copy the entire portage volume in
COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

ADD . /cross/localrepo

# prepare base env
RUN /cross/localrepo/prepare.sh