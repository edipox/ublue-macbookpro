#!/bin/sh
# Script to install facetimehd akmod from: https://copr.fedorainfracloud.org/coprs/mulderje/intel-mac-rpms

set -oeux pipefail

ARCH="$(rpm -E '%_arch')"
KERNEL="$(rpm -q "${KERNEL_NAME:-kernel}" --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
RELEASE="$(rpm -E '%fedora')"

if [[ "${RELEASE}" -ge 41 ]]; then
    COPR_RELEASE="rawhide"
else
    COPR_RELEASE="${RELEASE}"
fi

curl -L -o /etc/yum.repos.d/_copr_mulderje-intel-mac-rpms.repo \
    "https://copr.fedorainfracloud.org/coprs/mulderje/intel-mac-rpms/repo/fedora-$(rpm -E %fedora)/mulderje-intel-mac-rpms-fedora-$(rpm -E %fedora).repo"
#rpm-ostree install facetimehd-kmod

tree -d /etc/yum.repos.d/_copr_mulderje-intel-mac-rpms.repo

# original command
#curl -LsSf -o /etc/yum.repos.d/_copr_mulderje-facetimehd-kmod.repo \
#    "https://copr.fedorainfracloud.org/coprs/mulderje/facetimehd-kmod/repo/fedora-${COPR_RELEASE}/mulderje-facetimehd-kmod-fedora-${COPR_RELEASE}.repo"

### BUILD facetimehd (succeed or fail-fast with debug output)
dnf install -y akmod-facetimehd-*.fc${RELEASE}.${ARCH}
akmods --force --kernels "${KERNEL}" --kmod facetimehd
modinfo "/usr/lib/modules/${KERNEL}/extra/facetimehd/facetimehd.ko.xz" > /dev/null \
|| (find /var/cache/akmods/facetimehd/ -name \*.log -print -exec cat {} \; && exit 1)

rm -f /etc/yum.repos.d/_copr_mulderje-facetimehd-kmod.repo





