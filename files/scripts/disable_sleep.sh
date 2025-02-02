#!/bin/bash
# Script to disable sleep / suspend / hibernate / hybrid-sleep targets
# https://www.tecmint.com/disable-suspend-and-hibernation-in-linux/

# fail if any errors
set -oue pipefail

echo "Disabling sleep / suspend / hibernate / hybrid-sleep ..."
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# could try with enabling some of these, and having the following on first boot...
# https://github.com/Dunedan/mbp-2016-linux?tab=readme-ov-file#suspend--hibernation
# echo 0 > /sys/bus/pci/devices/0000\:01\:00.0/d3cold_allowed
