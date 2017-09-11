#!/bin/bash
set -x
set -e
set -o pipefail

if ! type "ip" > /dev/null; then
    echo "Skipping test as iproute package does not exist, skipping test."
    touch /tmp/testok
    exit 0
fi

ip link add name test99 type veth peer name test99-guest
ip link set dev test99 addr 00:01:02:aa:bb:cc
ip link set dev test99 up

cat >/etc/systemd/network/test99.link <<EOF

[Match]
MACAddress=00:01:02:aa:bb:cc

[Link]
AutoNegotiation=0
BitsPerSecond=1000k
MTUBytes=1280
TCPSegmentationOffload=on
GenericSegmentationOffload=on
UDPSegmentationOffload=on
GenericReceiveOffload=on
EOF

udevadm test-builtin net_setup_link /sys/class/net/test99

[[ "$(cat /sys/class/net/test99/speed)" == "10000" ]]
[[ "$(cat /sys/class/net/test99/mtu)"   == "1280" ]]

[[ "$(ethtool -k test99 | grep tcp-segmentation-offload)" == "tcp-segmentation-offload: on" ]]
[[ "$(ethtool -k test99 | grep udp-fragmentation-offload)" == "udp-fragmentation-offload: on" ]]
[[ "$(ethtool -k test99 | grep generic-segmentation-offload)" == "generic-segmentation-offload: on" ]]
[[ "$(ethtool -k test99 | grep generic-receive-offload)" == "generic-receive-offload: on" ]]

ip link del test99
rm /etc/systemd/network/test99.link

cat >/etc/systemd/network/test99.link <<EOF

[Match]
MACAddress=00:01:02:aa:bb:cc

[Link]
MACAddress=00:01:02:aa:bb:cd
Alias=testalias99
AutoNegotiation=0

EOF

ip link add name test99 type dummy
ip link set dev test99 addr 00:01:02:aa:bb:cc

udevadm test-builtin net_setup_link /sys/class/net/test99

[[ "$(cat /sys/class/net/test99/ifalias)" == "testalias99" ]]
[[ "$(cat /sys/class/net/test99/address)" == "00:01:02:aa:bb:cd" ]]

ip link del test99
rm /etc/systemd/network/test99.link

touch /tmp/testok
