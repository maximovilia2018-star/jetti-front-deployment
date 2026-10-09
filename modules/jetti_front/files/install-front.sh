#!/bin/bash

VER="$1"

/usr/bin/apt-get update -qq
DEBIAN_FRONTEND=noninteractive \
    /usr/bin/apt-get -q -y -o DPkg::Options::=--force-confold --allow-downgrades install "jetti-front=$VER" && reboot
