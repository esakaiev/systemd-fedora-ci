#!/bin/bash
set -x
set -e
set -o pipefail

if ! type "ip" > /dev/null; then
    echo "Skipping test as iproute package does not exist ."
    touch /tmp/testok
    exit 0
fi

# Netdev Kind test
# bond bridge gre gretap ip6gre	ip6tnl ip6gretap ipip ipvlan macvlan macvtap
# sit tap tun veth vlan vti vti6 vxlan geneve vrf vcan

# Test creation of netdevs does not require .network file support
# Create indepedent

# Bridge
cat >/etc/systemd/network/25-bridge.netdev <<EOF
[NetDev]
Name=bridge99
Kind=bridge

[Bridge]
HelloTimeSec=9
MaxAgeSec=9
ForwardDelaySec=9
AgeingTimeSec=9
Priority=9
MulticastQuerier= true
MulticastSnooping=true
STP=true

EOF

# Bond
cat >/etc/systemd/network/25-bond.netdev <<EOF
[NetDev]
Name=bond99
Kind=bond

[Bond]
Mode=802.3ad
TransmitHashPolicy=layer3+4
MIIMonitorSec=1s
LACPTransmitRate=fast
UpDelaySec=2s
DownDelaySec=2s
ResendIGMP=4
MinLinks=1

EOF

# Veth pair
cat >/etc/systemd/network/25-veth.netdev <<EOF
[NetDev]
Name=veth99
Kind=veth

[Peer]
Name=veth-peer
EOF

# dummy
cat >/etc/systemd/network/25-dummy.netdev <<EOF
[NetDev]
Name=dummy99
Kind=dummy
MACAddress=12:34:56:78:9a:bc
EOF

# VRF
cat >/etc/systemd/network/25-vrf.netdev <<EOF
[NetDev]
Name=vrf99
Kind=vrf

[VRF]
TableId=42
EOF

# Tap
cat >/etc/systemd/network/25-tap.netdev <<EOF
[NetDev]
Name=tap99
Kind=tap

[Tap]
MultiQueue=true
PacketInfo=true
EOF

# Tun
cat >/etc/systemd/network/25-tun.netdev <<EOF
[NetDev]
Name=tun99
Kind=tun

[Tun]
MultiQueue=true
PacketInfo=true
EOF

#  Virtual Can
cat >/etc/systemd/network/25-vcan.netdev <<EOF
[NetDev]
Name=vcan99
Kind=vcan

EOF

systemctl stop systemd-networkd
systemctl start systemd-networkd

sleep 3

[[ -L /sys/class/net/tap99 ]]
[[ -L /sys/class/net/tun99 ]]
[[ -L /sys/class/net/bridge99 ]]
[[ -L /sys/class/net/veth99 ]]
[[ -L /sys/class/net/bond99 ]]
[[ -L /sys/class/net/dummy99 ]]
[[ -L /sys/class/net/vrf99 ]]
[[ -L /sys/class/net/vcan99 ]]


# Bridge property test

read HelloTimeSec <  /sys/devices/virtual/net/bridge99/bridge/hello_time
[[ "$HelloTimeSec" == "900" ]]

read MaxAgeSec <  /sys/devices/virtual/net/bridge99/bridge/max_age
[[ "$MaxAgeSec" == "900" ]]

read ForwardDelaySec <  /sys/devices/virtual/net/bridge99/bridge/forward_delay
[[ "$ForwardDelaySec" == "900" ]]

read AgeingTimeSec <  /sys/devices/virtual/net/bridge99/bridge/ageing_time
[[ "$AgeingTimeSec" == "900" ]]

read Priority <  /sys/devices/virtual/net/bridge99/bridge/priority
[[ "$Priority" == "9" ]]

read MulticastQuerier <  /sys/devices/virtual/net/bridge99/bridge/multicast_querier
[[ "$MulticastQuerier" == "1" ]]

read MulticastSnooping <  /sys/devices/virtual/net/bridge99/bridge/multicast_snooping
[[ "$MulticastSnooping" == "1" ]]

read STP <  /sys/devices/virtual/net/bridge99/bridge/stp_state
[[ "$STP" == "1" ]]


# Bonding property test
read Mode < /sys/devices/virtual/net/bond99/bonding/mode
[[ "$Mode" == "802.3ad 4" ]]

read TransmitHashPolicy < /sys/devices/virtual/net/bond99/bonding/xmit_hash_policy
[[ "$TransmitHashPolicy" == "layer3+4 1" ]]

read MIIMonitorSec < /sys/devices/virtual/net/bond99/bonding/miimon
[[ "$MIIMonitorSec" == "1000" ]]

read LACPTransmitRate < /sys/devices/virtual/net/bond99/bonding/lacp_rate
[[ "$LACPTransmitRate" == "fast 1" ]]

read UpDelaySec < /sys/devices/virtual/net/bond99/bonding/updelay
[[ "$UpDelaySec" == "2000" ]]

read DownDelaySec < /sys/devices/virtual/net/bond99/bonding/downdelay
[[ "$DownDelaySec" == "2000" ]]

read ResendIGMP < /sys/devices/virtual/net/bond99/bonding/resend_igmp
[[ "$ResendIGMP" == "4" ]]

read MinLinks < /sys/devices/virtual/net/bond99/bonding/min_links
[[ "$MinLinks" == "1" ]]

# Tap and tun property test
read TapFlags < /sys/devices/virtual/net/tap99/tun_flags
[[ "$TapFlags" == "0x902" ]]

read TunFlags < /sys/devices/virtual/net/tun99/tun_flags
[[ "$TunFlags" == "0x901" ]]

ip link del bridge99
ip link del tap99
ip link del tun99
ip link del veth99
ip link del bond99
ip link del dummy99
ip link del vrf99
ip link del vcan99

rm /etc/systemd/network/25-veth.netdev
rm /etc/systemd/network/25-bond.netdev
rm /etc/systemd/network/25-dummy.netdev
rm /etc/systemd/network/25-vcan.netdev
rm /etc/systemd/network/25-vrf.netdev
rm /etc/systemd/network/25-bridge.netdev
rm /etc/systemd/network/25-tap.netdev
rm /etc/systemd/network/25-tun.netdev

# Test netdev which require a .network file support

# VLAN
cat >/etc/systemd/network/25-vlan1.netdev <<EOF
[NetDev]
Name=vlan99
Kind=vlan

[VLAN]
Id=99
EOF

# MacVTap
cat >/etc/systemd/network/25-macvtap.netdev <<EOF
[NetDev]
Name=macvtap99
Kind=macvtap
EOF

# MacVLan
cat >/etc/systemd/network/25-macvlan.netdev <<EOF
[NetDev]
Name=macvlan99
Kind=macvlan
EOF

# IPIP tunnel
cat >/etc/systemd/network/25-ipip.netdev <<EOF
[NetDev]
Name=ipiptun99
Kind=ipip
MTUBytes=1480

[Tunnel]
Local=192.168.223.238
Remote=192.169.224.239
TTL=64
EOF

# ip6tnl tunnel
cat >/etc/systemd/network/25-ip6tnl.netdev <<EOF
[NetDev]
Name=ip6tnl99
Kind=ip6tnl

[Tunnel]
Mode=ip6ip6
Local=2a00:ffde:4567:edde::4987
Remote=2001:473:fece:cafe::5179

EOF

# ip6gretap tunnel
cat >/etc/systemd/network/25-ip6gre.netdev <<EOF
[NetDev]
Name=ip6gretap99
Kind=ip6gretap

[Tunnel]
Local=2a00:ffde:4567:edde::4987
Remote=2001:473:fece:cafe::5179

EOF

# sit tunnel
cat >/etc/systemd/network/25-sit.netdev <<EOF
[NetDev]
Name=sittun99
Kind=sit

[Tunnel]
Local=10.65.223.238
Remote=10.65.223.239
EOF

# gre tunnel
cat >/etc/systemd/network/25-gre.netdev <<EOF
[NetDev]
Name=gretun99
Kind=gre

[Tunnel]
Local=10.65.223.238
Remote=10.65.223.239
EOF

# greptapl tunnel
cat >/etc/systemd/network/25-gretap.netdev <<EOF
[NetDev]
Name=gretap99
Kind=gretap

[Tunnel]
Local=10.65.223.238
Remote=10.65.223.239
EOF

# vti tunnel
cat >/etc/systemd/network/25-vti.netdev <<EOF
[NetDev]
Name=vtitun99
Kind=vti

[Tunnel]
Local=10.65.223.238
Remote=10.65.223.239
EOF

# vti6 tunnel
cat >/etc/systemd/network/25-vti6.netdev <<EOF
[NetDev]
Name=vti6tun99
Kind=vti6

[Tunnel]
Local=2a00:ffde:4567:edde::4987
Remote=2001:473:fece:cafe::5179

EOF

# VXLAN
cat >/etc/systemd/network/25-vxlan.netdev <<EOF
[NetDev]
Name=vxlan99
Kind=vxlan

[VXLAN]
Id=999

EOF

# IP Vlan
cat >/etc/systemd/network/25-ipvlan.netdev <<EOF
[NetDev]
Name=ipvlan99
Kind=ipvlan

[IPVLAN]
Mode=L2
EOF


# Create .network files
cat >/etc/systemd/network/test1.network <<EOF
[Match]
Name=test1

[Network]
Tunnel=ipiptun99
Tunnel=sittun99
Tunnel=gretap99
Tunnel=vtitun99
Tunnel=ip6tnl99

EOF

cat >/etc/systemd/network/test2.network <<EOF
[Match]
Name=test2

[Network]
VLAN=vlan99
EOF

cat >/etc/systemd/network/test3.network <<EOF
[Match]
Name=test3

[Network]
IPVLAN=ipvlan99

EOF

cat >/etc/systemd/network/test4.network <<EOF
[Match]
Name=test4

[Network]
MACVLAN=macvlan99
MACVTAP=macvtap99

EOF

cat >/etc/systemd/network/test5.network <<EOF
[Match]
Name=test5

[Network]
VXLAN=vxlan99

EOF

ip link add test1 type veth peer name peer1
ip link add test2 type veth peer name peer2
ip link add test3 type veth peer name peer3
ip link add test4 type veth peer name peer4
ip link add test5 type veth peer name peer5

systemctl stop systemd-networkd
systemctl start systemd-networkd

sleep 2

# verify all netdevs are created
[[ -L /sys/class/net/ipiptun99 ]]
[[ -L /sys/class/net/sittun99 ]]
[[ -L /sys/class/net/gretap99 ]]
[[ -L /sys/class/net/vtitun99 ]]
[[ -L /sys/class/net/ip6tnl99 ]]
[[ -L /sys/class/net/vxlan99 ]]
[[ -L /sys/class/net/vlan99 ]]
[[ -L /sys/class/net/macvtap99 ]]
[[ -L /sys/class/net/macvlan99 ]]
[[ -L /sys/class/net/ipvlan99 ]]

# netdev property test.

[[ "$(ip -d link show vlan99 | grep id |  awk '{print $5}')" == "99" ]]
[[ "$(ip -d link show vxlan99 | grep id | awk '{print $3}')" == "999" ]]

# Perform cleanup
# Remove netdevs
ip link del vlan99
ip link del ipiptun99
ip link del sittun99
ip link del gretap99
ip link del vtitun99
ip link del ip6tnl99
ip link del macvtap99
ip link del macvlan99
ip link del vxlan99
ip link del ipvlan99

# Remove confs
rm /etc/systemd/network/25-vlan1.netdev
rm /etc/systemd/network/25-ipip.netdev
rm /etc/systemd/network/25-ip6tnl.netdev
rm /etc/systemd/network/25-sit.netdev
rm /etc/systemd/network/25-gre.netdev
rm /etc/systemd/network/25-gretap.netdev
rm /etc/systemd/network/25-vti.netdev
rm /etc/systemd/network/25-vxlan.netdev
rm /etc/systemd/network/25-vti6.netdev
rm /etc/systemd/network/25-ip6gre.netdev
rm /etc/systemd/network/25-ipvlan.netdev
rm /etc/systemd/network/25-macvtap.netdev
rm /etc/systemd/network/25-macvlan.netdev

rm /etc/systemd/network/test1.network
rm /etc/systemd/network/test2.network
rm /etc/systemd/network/test3.network
rm /etc/systemd/network/test4.network
rm /etc/systemd/network/test5.network

ip link del test1
ip link del test2
ip link del test3
ip link del test4
ip link del test5

systemctl stop systemd-networkd

# DHCP
if ! type "python3" > /dev/null; then
    echo "Skipping DHCP test as python3 package does not exist ."
    touch /tmp/testok
    exit 0
fi

/usr/bin/python3 /usr/bin/networkd-test.py

return_code=$?

if [ $return_code != "0" ]; then
   exit $return_code
fi

touch /tmp/testok
