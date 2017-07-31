#!/bin/bash

set -x
set -e
set -o pipefail

[[ "$(systemctl show -p CPUSchedulingPolicy sched_idle_ok.service)" = "CPUSchedulingPolicy=0" ]]
[[ "$(systemctl show -p CPUSchedulingPriority sched_idle_ok.service)" = "CPUSchedulingPriority=0" ]]

[[ "$(systemctl show -p CPUSchedulingPolicy sched_idle_bad.service)" = "CPUSchedulingPolicy=0" ]]
[[ "$(systemctl show -p CPUSchedulingPriority sched_idle_bad.service)" = "CPUSchedulingPriority=0" ]]

[[ "$(systemctl show -p CPUSchedulingPolicy sched_rr_ok.service)" = "CPUSchedulingPolicy=2" ]]
[[ "$(systemctl show -p CPUSchedulingPriority sched_rr_ok.service)" = "CPUSchedulingPriority=1" ]]

[[ "$(systemctl show -p CPUSchedulingPolicy sched_rr_bad.service)" = "CPUSchedulingPolicy=2" ]]
[[ "$(systemctl show -p CPUSchedulingPriority sched_rr_bad.service)" = "CPUSchedulingPriority=1" ]]

[[ "$(systemctl show -p CPUSchedulingPolicy sched_rr_change.service)" = "CPUSchedulingPolicy=2" ]]
[[ "$(systemctl show -p CPUSchedulingPriority sched_rr_change.service)" = "CPUSchedulingPriority=99" ]]

touch /tmp/testok
