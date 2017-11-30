#!/bin/bash

set -x
set -e
set -o pipefail

systemctl stop timertest.timer

systemctl start timertest.timer

[[ "$(systemctl list-timers | grep timertest.timer |  awk '{print $9}')" == "timertest.timer" ]]

sleep 5

# test if the file exists should have created by service triggered by the timer.
[[ -f /tmp/timer-test ]]

rm /tmp/timer-test

touch /tmp/testok
