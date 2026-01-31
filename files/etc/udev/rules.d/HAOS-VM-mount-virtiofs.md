# Mount virtiofs share to HAOS media

with the [deprecation of Home Assistant Supervised] a recommended migration is HAOS.
unfortunately, HAOS is a limited and often outdated custom build that precludes, _i.e._,

* local browser monitoring the installation, especially cameras
* sophisticated backup solutions like [duplicati]
* WiFi AP

since HAOS is relatively lightweight it makes sense to run HAOS in a VM and run these other capabilities
alongside it on the host.  add-ons like [Frigate NVR] can store media, lots of media!, and may require
the host share a directory for both [duplicati] and [Frigate NVR] to access.

these files allow a HAOS guest to automatically mount `virtiofs` shares from the host.

see the `INSTALL` section in the [rules](./81-mount-virtiofs.rules).

[deprecation of Home Assistant Supervised]: https://www.home-assistant.io/blog/2025/05/22/deprecating-core-and-supervised-installation-methods-and-32-bit-systems/
[duplicati]: https://duplicati.org
[Frigate NVR]: https://frigate.video/
