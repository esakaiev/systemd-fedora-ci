#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of timer
#   Description: Test for systemd timers
#   Author: Susant Sahani <susant@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2017 Red Hat, Inc.
#
#   This copyrighted material is made available to anyone wishing
#   to use, modify, copy, or redistribute it subject to the terms
#   and conditions of the GNU General Public License version 2.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE. See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free
#   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1


PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
	rlRun  "cp timertest.timer timertest.service /etc/systemd/system"

        rlRun -s "cat >/etc/systemd/system/testsuite.service <<EOF
[Unit]
Description=Testsuite service
After=multi-user.target

[Service]
ExecStart=/usr/bin/test-timers.sh
Type=oneshot
EOF"
        rlRun "cp test-timers.sh /usr/bin/"
        rlRun "systemctl daemon-reload"
    rlPhaseEnd

    rlPhaseStartTest
	rlLog "systemd timer test"

	rlLog "starting testsuite.service"
     	rlRun "systemctl start testsuite.service"
        rlAssertExists "/tmp/testok"
       rlPhaseEnd

    rlPhaseStartCleanup

       rlRun "rm /etc/systemd/system/timertest.timer /etc/systemd/system/timertest.service"
       rlRun "rm /tmp/testok"
       rlRun "rm /usr/bin/test-timers.sh"

       rlRun "systemctl daemon-reload"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
