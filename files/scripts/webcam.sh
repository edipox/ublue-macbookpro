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

# original command
#curl -LsSf -o /etc/yum.repos.d/_copr_mulderje-facetimehd-kmod.repo \
#    "https://copr.fedorainfracloud.org/coprs/mulderje/facetimehd-kmod/repo/fedora-${COPR_RELEASE}/mulderje-facetimehd-kmod-fedora-${COPR_RELEASE}.repo"

dnf5 install -y akmod-facetimehd-*.fc${RELEASE}.${ARCH}
chmod a=rwx,u+t /tmp # fix /tmp permissions
mkdir -p /run/akmods
#chmod a=rwx,u+t /run/akmods # fix /run/akmods ? permissions lets see...

akmods --force --kernels "${KERNEL}" #--kmod facetimehd

cat /var/cache/akmods/facetimehd/0.6.8.1-1.20240319git0.6.8.1-for-6.12.9-200.fc41.x86_64.failed.log

#akmodsbuild --kernels "${KERNEL}" /usr/src/akmods/facetimehd-kmod-*.src.rpm

#modinfo "/usr/lib/modules/${KERNEL}/extra/facetimehd/facetimehd.ko.xz" > /dev/null \
#|| (find /var/cache/akmods/facetimehd/ -name \*.log -print -exec cat {} \; && exit 1)

#rm -f /etc/yum.repos.d/_copr_mulderje-facetimehd-kmod.repo





