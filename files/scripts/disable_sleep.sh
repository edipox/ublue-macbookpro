#!/bin/bash
# Script to disable sleep / suspend / hibernate / hybrid-sleep targets
# https://www.tecmint.com/disable-suspend-and-hibernation-in-linux/

# fail if any errors
set -oue pipefail

echo "Disabling sleep / suspend / hibernate / hybrid-sleep ..."
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
