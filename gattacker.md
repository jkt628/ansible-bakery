# [gattacker]

[noble] and [bleno] do not play well on modern Debian.  while implementing [gottacker] i decided to run
Debian stretch for the [gattacker] hosts since that seems to be the last version supported by the software.

this document details bits required to get to the point where
ansible will run, then [gattacker.yml](./gattacker.yml) adds the rest.

## Physical setup

i used two hosts as shown in Tal Melamed's [AN ACTIVE MAN-IN-THE-MIDDLE ATTACK ON
BLUETOOTH SMART DEVICES](https://www.witpress.com/Secure/ejournals/papers/SSE080202f.pdf), Figure 6.

## Central

a Raspberry Pi Zero W with [CSR 8510]-based USB dongle running
[Raspbian Stretch](https://downloads.raspberrypi.org/raspbian/images/raspbian-2019-04-09/2019-04-08-raspbian-stretch.zip).

### First boot (central)

i had trouble using [Raspberry Pi Imager](https://github.com/raspberrypi/rpi-imager) with
[OS customization settings](https://www.raspberrypi.com/documentation/computers/images/imager/os-customisation-general.png);
the system always ended up in rescue mode and partly mangled.  instead i go through first boot manually,
reboot, open a console and run

```bash
sudo -i
sed -i -e 's,/raspbian.raspberrypi,/legacy.raspbian,' /etc/apt/sources.list
systemctl enable --now ssh
```

on your development host run

``` bash
ssh-copy-id pi@raspberrypi.local
```

## Peripheral

an amd64 PC with [CSR 8510]-based USB dongle running
[Debian stretch live](https://cdimage.debian.org/mirror/cdimage/archive/9.13.0-live/amd64/iso-hybrid/) LXDE.

### First boot (peripheral)

run these in a console:

```bash
sudo -i
sed -i -e 's,/deb,/archive,' /etc/apt/sources.list
apt update
apt install -y openssh-server
systemctl start ssh
```

on your development host run

``` bash
ssh-copy-id user@debian.local # password: live
ssh user@debian.local
sudo -i
apt install -y curl
curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
```

## Both

ssh into both hosts.  easiest done with [konsole](https://konsole.kde.org/) _Copy Input To..._, [cssh](https://github.com/duncs/clusterssh/wiki) or similar.

```bash
sudo -i
apt update
apt upgrade -y
apt install -y build-essential bluetooth bluez curl libbluetooth-dev libudev-dev nodejs npm
node -v
npm install -g n
n 8.11.1
hash -r
npm install bluetooth-hci-socket --unsafe-perm
npm install gattacker
cd node_modules/gattacker
```

[bleno]: https://github.com/noble/bleno
[CSR 8510]: https://ebay.com/sch/i.html?_nkw=CSR+8510-based+USB+dongle
[gattacker]: https://github.com/securing/gattacker
[gottacker]: https://github.com/jkt628/gottacker
[noble]: https://github.com/noble/noble
