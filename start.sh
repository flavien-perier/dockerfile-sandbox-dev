#!/bin/bash

echo "admin:$PASSWORD" | chpasswd
/usr/sbin/sshd -D