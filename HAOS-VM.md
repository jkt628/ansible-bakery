# Switch from Supervised to HAOS VM

[Home Assistant Supervised](https://github.com/home-assistant/supervised-installer) was
[deprecated](https://www.home-assistant.io/blog/2025/05/22/deprecating-core-and-supervised-installation-methods-and-32-bit-systems/) as of release 2025.12.0.
this requires a shift to a supported method: for maximum compatibility i choose [HAOS] running in a VM.
all the features of running on dedicated hardware are supported, importantly upgrades and
[Add-ons](https://www.home-assistant.io/addons/).
[Home Assistant] even provide qcow2 images for [QEMU](https://www.qemu.org/).
however, in a highly configured world this change is not a slam dunk;
this page discusses challenges and decisions for the transition.

## Single -> Dual host

[Supervised] runs docker directly on the host so there is only one server and one root to manage.

[HAOS] practically runs as an independent host which implies multiple servers and multiple roots.

### [HAOS] is limited

[HAOS] is a custom Linux distribution stripped down to just a few features, among them:

- docker - where all the magic really happens
- upgrade - partial through docker, full through [RAUC](https://rauc.io/)
- hardware integration - but limited

unfortunately, [python](https://python.org) is **not** among the features so ansible cannot be used on the guest.
considering that services, and even the OS itself!, are mostly ephemeral any permanent configuration is done to the host and
[mapped to the guest](./tasks/HAOS-VM.yml#L144-177).

## Network Services

the guest is connected to a bridge on the host to provide network services.
ideally this bridge is connected directly to the physical network so the guest truly presents as a fully independent host.
unfortunately, WiFi requires [4addr](https://superuser.com/questions/1601099/how-to-automatically-enable-wifi-4addr-wds-mode-before-connecting-to-specific) configuration, which breaks most networks so is not actually viable.
i choose to configure the guest behind a NAT network and [map required services](./files/etc/libvirt/hooks/qemu.d/haos).

### SSH to guest

i add the following to my local SSH config so i can simplify to `ssh haos-thinny`:

```text
Host haos-thinny
Hostname thinny.local
Port 22222
User root
ForwardX11 no
```

unfortunately, `ssh-keygen` does not honor this configuration, so use the full syntax:

```bash
ssh-keygen -R [thinny.local]:22222
```

### Guest IP Address

the [qemu hook](./files/etc/libvirt/hooks/qemu.d/haos) creates `/etc/profile.d/qemu-hook-${VM_NAME}.sh` with the IP address of the guest, _e.g._, `/etc/profile.d/qemu-hook-haos.sh`:

```bash
HAOS_IP=192.168.122.176
```

this is used by [juntek_monitor service](./tasks/install_juntek_monitor.yml#L38-39) to locate the MQTT server.

## Difficult filesystem

the qcow2 image is much more difficult to manage.
i choose to [limit customization](./Makefile) on the ansible host to a small set:

- change hostname, mostly to disambiguate instances.
- enable SSH.
- map host filesystem to guest, discussed later.

## Media storage

on my primary [Home Assistant] i have a dedicated drive to store recordings and clips by [Frigate NVR](https://frigate.video/).
i could have given the entire USB drive to the guest but [HAOS] is limited and does not have a good method to use it.
i choose to mount the drive using the much more capable host and
[map the storage to the guest with virtiofs](./files/etc/udev/rules.d/HAOS-VM-mount-virtiofs.md).
this allows occasional backup of recordings by the host and allows [HAOS] to backup a much smaller set of concerns.

<!-- cSpell: words RAUC -->
[HAOS]: https://developers.home-assistant.io/docs/operating-system/
[Home Assistant]: https://www.home-assistant.io/
[Supervised]: https://github.com/home-assistant/supervised-installer
