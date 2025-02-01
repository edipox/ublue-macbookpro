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

echo "Cleaning up ..."
rm /tmp/build-kmod-facetimehd.sh
