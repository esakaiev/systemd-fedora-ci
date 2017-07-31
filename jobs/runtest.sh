#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of jobs
#   Description: Test for jobs
#   Author: Susant Sahani<susant@redhat.com>
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

# Inspiration from https://github.com/systemd/systemd/tree/master/test/TEST-05-JOBS

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
ExecStart=/usr/bin/test-jobs.sh
Type=oneshot
EOF"
         rlRun "cp hello.service sleep.service hello-after-sleep.target unstoppable.service /etc/systemd/system/"
         rlRun "cp test-jobs.sh /usr/bin"
         rlRun "systemctl daemon-reload"
    rlPhaseEnd

    rlPhaseStartTest
	rlLog "status jobs test"

        rlLog "starting testsuite.service"
     	rlRun "systemctl start testsuite.service"

        rlAssertExists "/tmp/testok"

       rlPhaseEnd
    rlPhaseStartCleanup

       rlRun "rm /tmp/testok"
       rlRun "rm  /etc/systemd/system/testsuite.service /etc/systemd/system/hello.service /etc/systemd/system/sleep.service "
             "/etc/systemd/system/hello-after-sleep.target /etc/systemd/system/unstoppable.service /usr/bin/test-jobs.sh /tmp/testok"

       rlRun "systemctl daemon-reload"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
