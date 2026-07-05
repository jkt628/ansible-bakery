export SHELL:=$(shell which bash)
DEV_NBD?=/dev/nbd11
MNT_NBD:=/mnt${DEV_NBD}
.ONESHELL:

.PHONY: default
default:
	echo >&2 pick a target
	exit 1

.INTERMEDIATE: ${TARGET} ${SRC}
${TARGET}: ${SRC}
	set -ex
	(( UID == 0 ))
	cp $< $@
	modprobe nbd max_part=8
	CLEANUP='modprobe -r nbd ||:'
	trap 'eval "$$CLEANUP"' EXIT
	qemu-nbd --connect ${DEV_NBD} $@
	CLEANUP="qemu-nbd --disconnect ${DEV_NBD}; $$CLEANUP"
	mkdir -p ${MNT_NBD}/7
	for (( i = 5; --i >= 0; )); do if [ -b ${DEV_NBD}p7 ]; then break; fi; sleep 1; done # wait for partition to appear
	mount ${DEV_NBD}p7 ${MNT_NBD}/7
	CLEANUP="umount ${MNT_NBD}/7; $$CLEANUP"
	mkdir -p ${MNT_NBD}/7/{root,etc/udev/rules.d}
	install -m u=rwx,go= -d ${MNT_NBD}/7/root/.ssh
	install -m u=rw,go= --target-directory ${MNT_NBD}/7/root/.ssh ~${SUDO_USER}/.ssh/authorized_keys
	install -m u=rw,go=r --target-directory ${MNT_NBD}/7/etc/udev/rules.d etc/udev/rules.d/*
	chmod +x ${MNT_NBD}/7/etc/udev/rules.d/*.sh
	HOST=$(subst .qcow2,,$(notdir $@))
	if [ -n "$$HOST" ]; then
	  echo "$$HOST" > ${MNT_NBD}/7/etc/hostname
	  echo -e "127.0.0.1\tlocalhost\n127.0.1.1\t$$HOST" > ${MNT_NBD}/7/etc/hosts
	fi

%.tar.xz: %.qcow2
	tar -cJf $@ $(notdir $<)
%.qcow2: %.qcow2.xz
	xz --decompress --keep $<
