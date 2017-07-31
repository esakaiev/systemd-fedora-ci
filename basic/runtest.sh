#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of basic systemd test
#   Description: Basic systemd setup
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

# Inspiration from

PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
    rlPhaseEnd

    rlPhaseStartTest
	rlLog "Basic systemd setup"

     	rlRun "systemctl --state=failed --no-legend --no-pager > /tmp/failed ; echo OK > /tmp/testok"
        rlAssertNotGrep "failed" "/tmp/testok"

       rlPhaseEnd

    rlPhaseStartCleanup
         rlRun "rm /tmp/testok /tmp/failed"
     rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
