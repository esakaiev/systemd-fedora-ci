#!/bin/bash

set -x
set -e
set -o pipefail

/usr/lib/systemd/systemd-modules-load /etc/modules-load.d/virtio-net.conf
modinfo virtio_net

[[ "$?" == "0" ]]

touch /tmp/testok
