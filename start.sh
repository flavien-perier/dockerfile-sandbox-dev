#!/bin/bash

set -e

echo "admin:$PASSWORD" | chpasswd
/usr/sbin/sshd -D