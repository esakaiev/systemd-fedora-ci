#!/bin/bash

set -x
set -e
set -o pipefail

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

result=0

function is_inaccessible_available() {
    files='/run/systemd/inaccessible/reg
           /run/systemd/inaccessible/dir
           /run/systemd/inaccessible/chr
           /run/systemd/inaccessible/blk
           /run/systemd/inaccessible/fifo
           /run/systemd/inaccessible/sock'

    local ret='0'

    for file in $files
    do
        if [ ! -r $file ]
        then
            ret='-1'
            echo $ret
        fi
    done

    echo $ret
}

test_exec_workingdirectory() {
    mkdir -m 0755 -p "/tmp/test-exec_workingdirectory"

    systemctl start exec-workingdirectory.service
    [[ $? -eq 0 ]]

    rm -rf "/tmp/test-exec_workingdirectory"
}

test_exec_privatedevices() {

    if is_inaccessible_available "0"
    then

        systemctl start exec-privatedevices-yes.service
        [[ $? -eq 0 ]]

        systemctl start exec-privatedevices-no.service
        [[ $? -eq 0 ]]
    fi
}

test_exec_privatedevices_capabilities() {

    if is_inaccessible_available "0"
    then

        systemctl start exec-privatedevices-yes-capability-mknod.service
        [[ $? -eq 0 ]]

        systemctl start exec-privatedevices-no-capability-mknod.service
        [[ $? -eq 0 ]]

        systemctl start exec-privatedevices-yes-capability-sys-rawio.service
        [[ $? -eq 0 ]]

        systemctl start exec-privatedevices-no-capability-sys-rawio.service
        [[ $? -eq 0 ]]

    fi
}

test_exec_protectkernelmodules() {

    if is_inaccessible_available "0"
    then

        if [ `which capsh` != "" ]; then

            systemctl start exec-protectkernelmodules-no-capabilities.service
            [[ $? -eq 0 ]]
            systemctl start exec-protectkernelmodules-yes-capabilities.service
            [[ $? -eq 0 ]]
            systemctl start exec-protectkernelmodules-yes-mount-propagation.service
            [[ $? -eq 0 ]]

        fi
    fi
}

test_exec_readwritepaths() {

    systemctl start exec-readwritepaths-mount-propagation.service
    [[ $? -eq 0 ]]
}

test_exec_inaccessiblepaths() {

    systemctl start exec-inaccessiblepaths-mount-propagation.service
    [[ $? -eq 0 ]]
}

test_exec_inaccessiblepaths_proc() {

    if is_inaccessible_available "0"
    then

        systemctl start exec-inaccessiblepaths-proc.service
        [[ $? -eq 0 ]]
    fi
}

test_exec_user() {

    if grep -q "nobody" /etc/group
    then

        systemctl start exec-user.service
        [[ $? -eq 0 ]]

    elif grep -q "nfsnobody" /etc/group
    then
        systemctl start exec-user-nfsnobody.service
        [[ $? -eq 0 ]]
    else
        echo "Skipping test_exec_user, could not find nobody/nfsnobody user"
    fi
}

test_exec_group() {

    if grep -q "nobody" /etc/group
    then
        systemctl start exec-group.service
        [[ $? -eq 0 ]]

    elif grep -q "nfsnobody" /etc/group
    then
        systemctl start exec-group-nfsnobody.service
        [[ $? -eq 0 ]]

    else
        echo "Skipping test_exec_group, could not find nobody/nfsnobody group"
    fi
}

test_exec_privatetmp() {
    touch "/tmp/test-exec_privatetmp"

    systemctl start exec-privatetmp-yes.service
    [[ $? -eq 0 ]]

    systemctl start exec-privatetmp-no.service
    [[ $? -eq 0 ]]

    unlink "/tmp/test-exec_privatetmp"
}

test_exec_supplementary_groups() {

    systemctl start exec-supplementarygroups.service
    [[ $? -eq 0 ]]

    systemctl start exec-supplementarygroups-single-group.service
    [[ $? -eq 0 ]]

    systemctl start exec-supplementarygroups-single-group-user.service
    [[ $? -eq 0 ]]

    systemctl start exec-supplementarygroups-multiple-groups-default-group-user.service
    [[ $? -eq 0 ]]

    systemctl start exec-supplementarygroups-multiple-groups-withgid.service
    [[ $? -eq 0 ]]

    systemctl start exec-supplementarygroups-multiple-groups-withuid.service
    [[ $? -eq 0 ]]
}

test_exec_environment() {

    systemctl start exec-environment.service
    [[ $? -eq 0 ]]

    systemctl start exec-environment-multiple.service
    [[ $? -eq 0 ]]

    systemctl start exec-environment-empty.service
    [[ $? -eq 0 ]]
}

test_exec_environmentfile() {
    echo "VAR1='word1 word2'"      >  "/tmp/test-exec_environmentfile.conf"
    echo "VAR2='word3'"            >> "/tmp/test-exec_environmentfile.conf"
    echo "# comment1"              >> "/tmp/test-exec_environmentfile.conf"
    echo "# comment2"              >> "/tmp/test-exec_environmentfile.conf"
    echo "# comment3"              >> "/tmp/test-exec_environmentfile.conf"
    echo "# line without an equal" >> "/tmp/test-exec_environmentfile.conf"
    echo "VAR3='$word 5 6'"        >> "/tmp/test-exec_environmentfile.conf"

    systemctl start exec-environmentfile.service
    [[ $? -eq 0 ]]

    unlink "/tmp/test-exec_environmentfile.conf"
}

test_exec_umask() {

    systemctl start exec-umask-default.service
    [[ $? -eq 0 ]]

    systemctl start exec-umask-0177.service
    [[ $? -eq 0 ]]
}

test_exec_runtimedirectory() {

    systemctl start exec-runtimedirectory.service
    [[ $? -eq 0 ]]

    systemctl start exec-runtimedirectory-mode.service
    [[ $? -eq 0 ]]

    if grep -q "nobody" /etc/group
    then
        systemctl start exec-runtimedirectory-owner.service
        [[ $? -eq 0 ]]
    elif grep -q "nfsnobody" /etc/group
    then
        systemctl start exec-runtimedirectory-owner-nfsnobody.service
        [[ $? -eq 0 ]]
    else
        echo "Skipping test_exec_runtimedirectory, could not find nobody/nfsnobody group"
    fi
}

test_exec_capabilityboundingset() {

    if [ `which capsh` != "" ]; then

        systemctl start exec-capabilityboundingset-simple.service
        [[ $? -eq 0 ]]

        systemctl start exec-capabilityboundingset-reset.service
        [[ $? -eq 0 ]]

        systemctl start exec-capabilityboundingset-merge.service
        [[ $? -eq 0 ]]

        systemctl start exec-capabilityboundingset-invert.service
        [[ $? -eq 0 ]]

    fi
}

test_exec_privatenetwork() {

    if [ `which ip` != "" ]; then

        systemctl start exec-privatenetwork-yes.service
        [[ $? -eq 0 ]]
    fi
}

test_exec_oomscoreadjust() {

    systemctl start exec-oomscoreadjust-positive.service
    [[ $? -eq 0 ]]

    systemctl start exec-oomscoreadjust-negative.service
    [[ $? -eq 0 ]]
}

test_exec_ioschedulingclass() {

    systemctl start exec-ioschedulingclass-none.service
    [[ $? -eq 0 ]]

    systemctl start exec-ioschedulingclass-idle.service
    [[ $? -eq 0 ]]

    systemctl start exec-ioschedulingclass-realtime.service
    [[ $? -eq 0 ]]

    systemctl start exec-ioschedulingclass-best-effort.service
    [[ $? -eq 0 ]]
}

test_exec_spec_interpolation() {

    systemctl start exec-spec-interpolation.service
    [[ $? -eq 0 ]]
}

test_exec_read_only_path_suceed() {

    systemctl start exec-read-only-path-succeed.service
    [[ $? -eq 0 ]]
}

test_exec_restrict_realtime_fail() {

    set +e

    systemctl start exec-restrict-realtime.service > /dev/null 2>&1

    if [ $? -eq 0 ]
    then
        rlLogError "exec-restrict-realtime.service failed."
        result=1
    else
        rlLogDebug "exec-restrict-realtime.service passed."
    fi

    set -e
}

test_exec_restrict_namespaces() {

    systemctl start exec-restrict-namespaces-no.service
    [[ $? -eq 0 ]]

    systemctl start exec-restrict-namespaces-mnt.service
    [[ $? -eq 0 ]]

    set +e

    systemctl start exec-restrict-namespaces-yes.service > /dev/null 2>&1

    if [ $? -eq 0 ]
    then
        rlLogError "exec-restrict-namespaces-yes.service failed."
        result=1
    else
        rlLogDebug "exec-restrict-namespaces-yes.service passed."
    fi

    systemctl start exec-restrict-namespaces-mnt-blacklist.service > /dev/null 2>&1

    if [ $? -eq 0 ]
    then
        rlLogError "exec-restrict-namespaces-mnt-blacklist.service failed."
        result=1
    else
        rlLogDebug "exec-restrict-namespaces-mnt-blacklist.service passed."
    fi

    set -e
}

test_exec_systemcallerrornumber() {

    set +e

    systemctl start exec-systemcallerrornumber.service > /dev/null 2>&1

    if [ $? -eq 0 ]
    then
        rlLogError "exec-systemcallerrornumber.service failed."
        result=1
    else
        rlLogDebug "exec-systemcallerrornumber.service passed."
    fi

    set -e
}

test_exec_systemcallfilter() {

    set +e

    systemctl start exec-systemcallfilter-not-failing.service

    [[ $? -eq 0 ]]

    systemctl start exec-systemcallfilter-not-failing2.service

    [[ $? -eq 0 ]]

    systemctl start exec-systemcallfilter-failing.service > /dev/null 2>&1

    if [ $? -eq 0 ]
    then
        rlLogError "exec-systemcallfilter-failing.service failed."
        result=1
    else
        rlLogDebug "exec-systemcallfilter-failing.service passed."
    fi

    systemctl start exec-systemcallfilter-failing2.service > /dev/null 2>&1

    if [ $? -eq 0 ]
    then
        rlLogError "exec-systemcallfilter-failing2.service failed."
        result=1
    else
        rlLogDebug "exec-systemcallfilter-failing2.service passed."
    fi

    set -e
}


test_exec_restrict_address_families() {

    set +e

    systemctl start exec-restrict-address-families.service

    sleep 1

    systemctl status exec-restrict-address-families.service #> /dev/null 2>&1

    if [ $? -eq 0 ]
    then
        rlLogError "exec-restrict-address-families.service failed."
        result=1
    else
        rlLogDebug "exec-restrict-address-families.service passed."
    fi

    set -e
}

test_exec_personality() {

    arch=$(uname --hardware-platform)
    byte_order=$(echo -n I | od -to2 | head -n1 | cut -f2 -d" " | cut -c6)

    if [ $(arch) == "x86_64" ]
    then
        systemctl start exec-personality-x86-64.service
    elif [ $(arch) == "s390" ]
    then
        systemctl start exec-personality-s390.service
    elif [ $(arch) == "powerpc64" ]
    then
        # little endian
        if [ $(byte_order) == "1" ]
        then
            systemctl start exec-personality-ppc64.service
        else
            systemctl start exec-personality-ppc64le.service
        fi
    elif [ $(arch) == "aarch64" ]
    then
        systemctl start exec-personality-aarch64.service
    elif [ $(arch) == "i386" ]
    then
        systemctl start exec-personality-x86.service
    fi
}

test_exec_dynamic_user() {
    systemctl start exec-dynamicuser-fixeduser.service
    [[ $? -eq 0 ]]

    systemctl start exec-dynamicuser-fixeduser-one-supplementarygroup.service
    [[ $? -eq 0 ]]

    systemctl start exec-dynamicuser-supplementarygroups.service
    [[ $? -eq 0 ]]

  #  systemctl start exec-dynamicuser-state-dir.service
  #  [[ $? -eq 0 ]]
}

test_exec_dynamic_user
test_exec_workingdirectory
test_exec_privatedevices
test_exec_privatedevices_capabilities
test_exec_protectkernelmodules
test_exec_readwritepaths
test_exec_inaccessiblepaths
test_exec_user
test_exec_group
test_exec_privatetmp
test_exec_supplementary_groups
test_exec_environment
test_exec_environmentfile
test_exec_umask
test_exec_runtimedirectory
test_exec_capabilityboundingset
test_exec_privatenetwork
test_exec_oomscoreadjust
test_exec_ioschedulingclass
test_exec_spec_interpolation
test_exec_read_only_path_suceed
test_exec_restrict_realtime_fail
test_exec_restrict_namespaces
test_exec_systemcallerrornumber
test_exec_systemcallfilter
test_exec_restrict_address_families
test_exec_personality

if [ $result -eq 0 ]
then
    touch /tmp/testok
fi
