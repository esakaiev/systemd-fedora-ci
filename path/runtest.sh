#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of path units
#   Description: Test for path units
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

# Inspiration from https://github.com/systemd/systemd/tree/master/src/test/test-path.c

PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE

	rlRun  "cp *.path *.service /etc/systemd/system/"

        rlRun -s "cat >/etc/systemd/system/testsuite.service <<EOF
[Unit]
Description=Testsuite service
After=multi-user.target

[Service]
ExecStart=/usr/bin/test-path.sh
Type=oneshot
EOF"
        rlRun "cp test-path.sh /usr/bin/"
        rlRun "systemctl daemon-reload"
    rlPhaseEnd

    rlPhaseStartTest
	rlLog "Path unit test"

	rlLog "starting testsuite.service"
     	rlRun "systemctl start testsuite.service"
        rlAssertExists "/tmp/testok"

       rlPhaseEnd

    rlPhaseStartCleanup
       rlRun "rm /tmp/testok"
       rlRun "rm /usr/bin/test-path.sh /etc/systemd/system/path-changed.path /etc/systemd/system/path-directorynotempty.service /etc/systemd/system/path-exists.path /etc/systemd/system/path-makedirectory.service  /etc/systemd/system/path-mycustomunit.service /etc/systemd/system/path-changed.service /etc/systemd/system/path-existsglob.path /etc/systemd/system/path-exists.service /etc/systemd/system/path-modified.path /etc/systemd/system/path-service.service /etc/systemd/system/path-directorynotempty.path /etc/systemd/system/path-existsglob.service /etc/systemd/system/path-makedirectory.path /etc/systemd/system/path-modified.service /etc/systemd/system/path-unit.path"

       rlRun "systemctl daemon-reload"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
