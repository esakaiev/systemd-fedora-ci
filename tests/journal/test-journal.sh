#!/bin/bash

set -x
set -e
set -o pipefail

# Test stdout stream

# Skip empty lines
ID=$(journalctl --new-id128 | sed -n 2p)
>/opt/expected
printf $'\n\n\n' | systemd-cat -t "$ID" --level-prefix false
journalctl --sync
journalctl -b -o cat -t "$ID" >/opt/output
cmp /opt/expected /opt/output

ID=$(journalctl --new-id128 | sed -n 2p)
>/opt/expected
printf $'<5>\n<6>\n<7>\n' | systemd-cat -t "$ID" --level-prefix true
journalctl --sync
journalctl -b -o cat -t "$ID" >/opt/output
cmp /opt/expected /opt/output

# Remove trailing spaces
ID=$(journalctl --new-id128 | sed -n 2p)
printf "Trailing spaces\n">/opt/expected
printf $'<5>Trailing spaces \t \n' | systemd-cat -t "$ID" --level-prefix true
journalctl --sync
journalctl -b -o cat -t "$ID" >/opt/output
cmp /opt/expected /opt/output

ID=$(journalctl --new-id128 | sed -n 2p)
printf "Trailing spaces\n">/opt/expected
printf $'Trailing spaces \t \n' | systemd-cat -t "$ID" --level-prefix false
journalctl --sync
journalctl -b -o cat -t "$ID" >/opt/output
cmp /opt/expected /opt/output

# Don't remove leading spaces
ID=$(journalctl --new-id128 | sed -n 2p)
printf $' \t Leading spaces\n'>/opt/expected
printf $'<5> \t Leading spaces\n' | systemd-cat -t "$ID" --level-prefix true
journalctl --sync
journalctl -b -o cat -t "$ID" >/opt/output
cmp /opt/expected /opt/output

ID=$(journalctl --new-id128 | sed -n 2p)
printf $' \t Leading spaces\n'>/opt/expected
printf $' \t Leading spaces\n' | systemd-cat -t "$ID" --level-prefix false
journalctl --sync
journalctl -b -o cat -t "$ID" >/opt/output
cmp /opt/expected /opt/output

# Don't lose streams on restart
systemctl start forever-print-hola
sleep 3
systemctl restart systemd-journald
sleep 3
systemctl stop forever-print-hola
[[ ! -f "/i-lose-my-logs" ]]

# https://github.com/systemd/systemd/issues/4408
rm -f /i-lose-my-logs
systemctl start forever-print-hola
sleep 3
systemctl kill --signal=SIGKILL systemd-journald
sleep 3
[[ ! -f "/i-lose-my-logs" ]]

touch /tmp/testok
