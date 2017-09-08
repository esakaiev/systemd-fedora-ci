#!/bin/bash
set -x
set -e
set -o pipefail

if ! type "netstat" > /dev/null; then
    echo "Skipping test as iproute package does not exist ."
    touch /tmp/testok
    exit 0
fi

if ! type "lsof" > /dev/null; then
    echo "Skipping test as lsof package does not exist ."
    touch /tmp/testok
    exit 0
fi

echo "Starting test socket ..."

systemctl stop test.socket
systemctl stop test-protocol.socket

systemctl start test.socket

# ListenStream=
[[ "$(netstat -antp | grep 9999 | awk '{print $NF}')" == "1/systemd" ]]

# ListenDatagram=
[[ "$(netstat -anup | grep 9999 | awk '{print $NF}')" == "1/systemd" ]]

# ListenSequentialPacket= Unix domain
[[ "$(netstat -lxp | grep "/var/run/test.socket" | awk '{print $6}')" == "SEQPACKET" ]]
[[ "$(netstat -lxp | grep "/var/run/test.socket" | awk '{print $9}')" == "1/systemd" ]]

[[ -p /var/run/test-fifo ]]

systemctl start test-protocol.socket

# ListenStream=sctp
[[ "$(netstat -antp | grep 9998 | awk '{print $NF}')" == "1/systemd" ]]

# ListenDatagram=udplite
[[ "$(lsof -p 1 | grep UDPLITE | awk '{print $NF}')" == "localhost:9998" ]]

# BindIPv6Only=both
[[ "$(netstat -antp | grep 9990 | awk '{print $NF}')" == "1/systemd" ]]
[[ "$(netstat -antp | grep 9990 | awk '{print $4}')"  == ":::9990"   ]]

# SocketUser=, SocketGroup=
[[ "$(ls -al /var/run/test-fifo | awk '{print $3 $4}')" == "nobodynobody" ]]

touch /tmp/testok

systemctl stop test.socket
systemctl stop test-protocol.socket
