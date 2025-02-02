#!/bin/sh
# Script to install facetimehd akmod from: https://copr.fedorainfracloud.org/coprs/mulderje/intel-mac-rpms

set -oeux pipefail

ARCH="$(rpm -E '%_arch')"
KERNEL="$(rpm -q "${KERNEL_NAME:-kernel}" --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
RELEASE="$(rpm -E '%fedora')"

curl -L -o /etc/yum.repos.d/_copr_mulderje-intel-mac-rpms.repo \
    "https://copr.fedorainfracloud.org/coprs/mulderje/intel-mac-rpms/repo/fedora-$(RELEASE)/mulderje-intel-mac-rpms-fedora-$(RELEASE).repo"


chmod a=rwx,u+t /tmp # fix /tmp permissions
mkdir -p /run/akmods # fix missing location for lock file

dnf5 install -y akmod-facetimehd-*.fc${RELEASE}.${ARCH}

# fix the --gpgcheck error for akmods
# see: https://universal-blue.discourse.group/t/need-help-building-system76-io-akmods/5725/3
sed -i "s/--nogpgcheck//g"  /usr/sbin/akmods
akmods --force --kernels "${KERNEL}" --kmod facetimehd

#akmodsbuild --kernels "${KERNEL}" /usr/src/akmods/facetimehd-kmod-*.src.rpm

#modinfo "/usr/lib/modules/${KERNEL}/extra/facetimehd/facetimehd.ko.xz" > /dev/null \
#|| (find /var/cache/akmods/facetimehd/ -name \*.log -print -exec cat {} \; && exit 1)

#rm -f /etc/yum.repos.d/_copr_mulderje-facetimehd-kmod.repo





