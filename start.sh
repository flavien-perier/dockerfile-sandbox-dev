#!/bin/bash

set -e

pushd /etc/ssh
    ssh-keygen -A
popd

echo "admin:$PASSWORD" | chpasswd
/usr/sbin/sshd -D