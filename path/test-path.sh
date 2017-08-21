#!/bin/bash

set -x
set -e
set -o pipefail

test_path_exists() {
    local test_path='/tmp/test-path_exists'

    systemctl start path-exists.path

    [[ ! -f $test_path ]]

    systemctl stop path-exists.service path-exists.path
}

test_path_existsglob() {
    local test_path='/tmp/test-path_existsglobFOOBAR'

    systemctl start path-existsglob.path

    [[ ! -f $test_path ]]

    systemctl stop path-existsglob.service path-existsglob.path
}

test_path_changed() {
    local test_path='/tmp/test-path_changed'

    touch $test_path

    systemctl start path-changed.path

    exec 3<>$test_path

    exec 3>&-

    systemctl stop path-changed.service path-changed.path
}

test_path_modified() {
    local test_path='/tmp/test-path_modified'

    touch $test_path

    systemctl start path-modified.path

    exec 3<>$test_path

    echo "test" >&3

    exec 3>&-

    systemctl stop path-modified.service path-modified.path
}

test_path_unit() {
    local test_path='/tmp/test-path_unit'

    systemctl start path-mycustomunit.service

    [[ ! -f $test_path ]]

    systemctl stop path-mycustomunit.service
}

test_path_directorynotempty() {
    local test_path='/tmp/test-path_directorynotempty/'

    [ ! -f $test_path ]

    systemctl start  path-directorynotempty.path

    # MakeDirectory default to no
    [[ ! -f $test_path ]]

    mkdir -p $test_path
    touch "$test_path/testfile"

    rm -rf $test_path

    systemctl stop path-directorynotempty.path path-directorynotempty.service
}

test_path_makedirectory_directorymode() {
    local test_path='/tmp/test-path_makedirectory/'
    local mode='744'

    [[ ! -d $test_path ]]

    systemctl start path-makedirectory.path

    # Check if the directory has been created
    [[ -d $test_path ]]

    # Check the mode we specified with DirectoryMode=0744

    test_mode="$(stat -c "%a" $test_path)"

    [[ $test_mode == $mode ]]

    rm -rf $test_path

    systemctl stop path-makedirectory.path path-makedirectory.service
}

test_path_exists
test_path_existsglob
test_path_changed
test_path_modified
test_path_unit
test_path_directorynotempty
test_path_makedirectory_directorymode

touch /tmp/testok
