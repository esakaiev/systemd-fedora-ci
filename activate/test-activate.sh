#!/bin/bash
set -x
set -e
set -o pipefail

if ! type "nc" > /dev/null; then
    echo "Skipping test as netcat package does not exist ."
    touch /tmp/testok
    exit 0
fi

echo "Starting test activate socket ..."

systemctl stop test-activate.service
systemctl start test-activate.service

# TCP
test="echo hello | nc localhost 2000"

printf hello | nc localhost 2000 > /tmp/test-active
[[ $(cat /tmp/test-active) == "hello" ]]

touch /tmp/testok

systemctl stop test-activate.service
rm /tmp/test-active
