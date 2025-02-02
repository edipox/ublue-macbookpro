#!/bin/bash
# Script to disable sleep / suspend / hibernate / hybrid-sleep targets
# https://www.tecmint.com/disable-suspend-and-hibernation-in-linux/

# fail if any errors
set -oue pipefail

echo "Disabling sleep / suspend / hibernate / hybrid-sleep ..."
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# could try with enabling some of these, and having the following on boot
#
# in /etc/rc.local:
# #!/bin/sh
# https://github.com/Dunedan/mbp-2016-linux?tab=readme-ov-file#suspend--hibernation
# echo 0 > /sys/bus/pci/devices/0000\:01\:00.0/d3cold_allowed
# exit 1
#
# in /etc/systemd/rc-local.service:
# [Unit]
# Description=/etc/rc.local
# ConditionPathExists=/etc/rc.local
# [Service]
# ExecStart=/etc/rc.local start
# TimeoutSec=0
# StandardOutput=tty
# RemainAfterExit=yes
# SysVStartPriority=99
# [Install]
# WantedBy=multi-user.target
#
# then enable the service:
# $ systemctl enable rc-local
#
