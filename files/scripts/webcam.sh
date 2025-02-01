#!/bin/bash
# Script to install facetimehd from akmods (the Bluebuild yml was not working)

# fail if any errors
set -oeux pipefail

echo "Downloading build-kmod-facetimehd.sh script ..."
curl -LsSf -o /tmp/build-kmod-facetimehd.sh \
    "https://raw.githubusercontent.com/ublue-os/akmods/refs/heads/main/build_files/extra/build-kmod-facetimehd.sh"

echo "Marking as executable ..."
chmod +x /tmp/build-kmod-facetimehd.sh

echo "Calling the install script ..."
/bin/sh -c /tmp/build-kmod-facetimehd.sh

cat /var/cache/akmods/facetimehd/0.6.8.1-1.20240319git0.6.8.1-for-6.12.9-200.fc41.x86_64.failed.log

echo "Cleaning up ..."
rm /tmp/build-kmod-facetimehd.sh
