#!/bin/bash
# Script to install facetimehd akmod
# https://raw.githubusercontent.com/ublue-os/akmods/refs/heads/main/build_files/extra/build-kmod-facetimehd.sh

set -oeux pipefail

ARCH="$(rpm -E '%_arch')"
KERNEL="$(rpm -q "${KERNEL_NAME:-kernel}" --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
RELEASE="$(rpm -E '%fedora')"

if [[ "${RELEASE}" -ge 41 ]]; then
    COPR_RELEASE="rawhide"
else
    COPR_RELEASE="${RELEASE}"
fi

curl -LsSf -o /etc/yum.repos.d/_copr_mulderje-facetimehd-kmod.repo \
    "https://copr.fedorainfracloud.org/coprs/mulderje/facetimehd-kmod/repo/fedora-${COPR_RELEASE}/mulderje-facetimehd-kmod-fedora-${COPR_RELEASE}.repo"

### BUILD facetimehd (succeed or fail-fast with debug output)
dnf install -y akmod-facetimehd-*.fc${RELEASE}.${ARCH}

echo "Fixing /tmp permissions for akmodsbuild"
chmod a=rwx,u+t /tmp

echo " =====> Attempting akmods --force --kernels "${KERNEL}" --kmod facetimehd ..."
akmods --force --kernels "${KERNEL}" --kmod facetimehd
cat /var/cache/akmods/facetimehd/*.failed.log


echo "Attempting modinfo ==> modinfo /usr/lib/modules/${KERNEL}/extra/facetimehd/facetimehd.ko.xz ..."
modinfo "/usr/lib/modules/${KERNEL}/extra/facetimehd/facetimehd.ko.xz" > /dev/null \
    || (find /var/cache/akmods/facetimehd/ -name \*.log -print -exec cat {} \; && exit 1)

echo "Removing /etc/yum.repos.d/_copr_mulderje-facetimehd-kmod.repo ..."
rm -f /etc/yum.repos.d/_copr_mulderje-facetimehd-kmod.repo


# # fail if any errors
# set -oeux pipefail

# echo "Downloading build-kmod-facetimehd.sh script ..."
# curl -LsSf -o /tmp/build-kmod-facetimehd.sh \
#     "https://raw.githubusercontent.com/ublue-os/akmods/refs/heads/main/build_files/extra/build-kmod-facetimehd.sh"

# echo "Fixing /tmp permissions for akmodsbuild"
# chmod a=rwx,u+t /tmp

# echo "Marking as executable ..."
# chmod +x /tmp/build-kmod-facetimehd.sh

# echo "Calling the install script ..."
# /bin/sh -c /tmp/build-kmod-facetimehd.sh

# cat /var/cache/akmods/facetimehd/0.6.8.1-1.20240319git0.6.8.1-for-6.12.9-200.fc41.x86_64.failed.log

# echo "Cleaning up ..."
# rm /tmp/build-kmod-facetimehd.sh
