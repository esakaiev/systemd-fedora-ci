#!/bin/bash

set -x
set -e
set -o pipefail

[[ "$(systemctl show -p LimitNOFILESoft testsuite.service)" = "LimitNOFILESoft=10000" ]]
[[ "$(systemctl show -p LimitNOFILE testsuite.service)" = "LimitNOFILE=16384" ]]

[[ "$(ulimit -n -S)" = "10000" ]]
[[ "$(ulimit -n -H)" = "16384" ]]

touch /tmp/testok
