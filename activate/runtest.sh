#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of activate
#   Description: Test for sactivate
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

        rlRun -s "cat >/etc/systemd/system/testsuite.service <<EOF
[Unit]
Description=Testsuite service
After=multi-user.target

[Service]
ExecStart=/usr/bin/test-activate.sh
Type=oneshot
EOF"
        rlRun "cp test-activate.sh /usr/bin/test-activate.sh"
        rlRun "cp test-activate.service /etc/systemd/system/"

        rlRun "systemctl daemon-reload"
    rlPhaseEnd

    rlPhaseStartTest
	rlLog "systemd activate related test"

	rlLog "starting testsuite.service"
     	rlRun "systemctl start testsuite.service"
        rlAssertExists "/tmp/testok"

       rlPhaseEnd

    rlPhaseStartCleanup

       rlRun "rm /tmp/testok /usr/bin/test-activate.sh /etc/systemd/system/test-activate.service"
       rlRun "systemctl daemon-reload"

    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
