#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of https://github.com/systemd/systemd/issues/2467
#   Description: Don't start services every few ms if condition fails
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

# Inspiration from https://github.com/systemd/systemd/tree/master/test/TEST-07-ISSUE-2467

PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE

          # setup the testsuite service
        rlRun -s "cat >/etc/systemd/system/testsuite.service <<EOF
[Unit]
Description=Testsuite service
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/sh -e -x -c 'rm -f /tmp/nonexistent; systemctl start test.socket; echo a | nc -U /run/test.ctl; >/tmp/testok'
TimeoutStartSec=10s
EOF"

       rlRun -s "cat  >/etc/systemd/system/test.socket <<'EOF'
[Socket]
ListenStream=/run/test.ctl
EOF"

        rlRun -s "cat > /etc/systemd/system/test.service <<'EOF'
[Unit]
Requires=test.socket
ConditionPathExistsGlob=/tmp/nonexistent

[Service]
ExecStart=/bin/true
EOF"
        rlRun "systemctl daemon-reload"
    rlPhaseEnd

    rlPhaseStartTest
	rlLog "Don't start services every few ms if condition fails "

	rlLog "starting testsuite.service"
     	rlRun "systemctl start testsuite.service" 1
        rlAssertNotExists "/tmp/testok"

       rlPhaseEnd

    rlPhaseStartCleanup
       rlRun "rm /etc/systemd/system/testsuite.service"
       rlRun "systemctl daemon-reload"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
