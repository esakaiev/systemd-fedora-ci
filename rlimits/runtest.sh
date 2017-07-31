#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of rlimits
#   Description: Test for resource limits
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

# Inspiration from https://github.com/systemd/systemd/tree/master/test/TEST-05-RLIMITS

PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
	rlRun  "cp /etc/systemd/system.conf /tmp/system.conf"

	rlRun  "cat >/etc/systemd/system.conf <<EOF
[Manager]
DefaultLimitNOFILE=10000:16384
EOF"

        rlRun -s "cat >/etc/systemd/system/testsuite.service <<EOF
[Unit]
Description=Testsuite service
After=multi-user.target

[Service]
ExecStart=/usr/bin/test-rlimits.sh
Type=oneshot
EOF"
        rlRun "cp -v test-rlimits.sh /usr/bin/"
        rlRun "systemctl daemon-reload"
    rlPhaseEnd

    rlPhaseStartTest
	rlLog "Resource limits-related test"

	rlLog "starting testsuite.service"
     	rlRun "systemctl start testsuite.service"
        rlAssertExists "/tmp/testok"

       rlAssertEquals "DefaultLimitNOFILESoft=10000" "$(systemctl show -p DefaultLimitNOFILESoft)"  "DefaultLimitNOFILESoft=10000"
       rlAssertEquals "DefaultLimitNOFILE=16384"     "$(systemctl show -p DefaultLimitNOFILE)"  "DefaultLimitNOFILE=16384"

       rlPhaseEnd

    rlPhaseStartCleanup

       rlRun "mv /tmp/system.conf /etc/systemd/system.conf"
       rlRun "rm /tmp/testok"
       rlRun "rm /usr/bin/test-rlimits.sh"

       rlRun "systemctl daemon-reload"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
