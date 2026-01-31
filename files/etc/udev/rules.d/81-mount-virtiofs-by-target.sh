#!/bin/bash
# Mount virtiofs filesystems to $tag
set -e -o pipefail
# set -vx # uncomment for debugging

valid='^/.*[^/]$'

for f in /sys/fs/virtiofs/*/tag; do
	tag="$(cat "$f")"
	if ! [[ "$tag" =~ $valid ]]; then
		echo >&2 "Skipping invalid tag: $tag"
		continue
	fi
	unit=$(echo "$tag" | sed 's,^/,,;s,/,-,g').mount
	cat > "/run/systemd/system/$unit" <<EOF
[Unit]
Description=virtiofs mount $tag
[Mount]
What=$tag
Where=$tag
Type=virtiofs
EOF
	systemctl daemon-reload
	systemctl start --no-block "$unit"
done
