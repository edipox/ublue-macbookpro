#!/bin/sh
# Script to install facetimehd akmod from: https://copr.fedorainfracloud.org/coprs/mulderje/intel-mac-rpms

# fail if any errors
set -oeux pipefail

ARCH="$(rpm -E '%_arch')"
KERNEL="$(rpm -q "${KERNEL_NAME:-kernel}" --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
RELEASE="$(rpm -E '%fedora')"

echo "Downloading COPR repo source ..."
curl -L -o /etc/yum.repos.d/_copr_mulderje-intel-mac-rpms.repo \
    "https://copr.fedorainfracloud.org/coprs/mulderje/intel-mac-rpms/repo/fedora-${RELEASE}/mulderje-intel-mac-rpms-fedora-${RELEASE}.repo"

echo "Fixing directory permissions for build ..."
chmod a=rwx,u+t /tmp # fix /tmp permissions
mkdir -p /run/akmods # fix missing location for lock file

echo "Installing akmod-facetimehd-*.fc${RELEASE}.${ARCH} ..." 
dnf5 install -y akmod-facetimehd-*.fc${RELEASE}.${ARCH}

echo "Patching /usr/sbin/akmods (should not see --nogpgcheck or --disablerepo flags below) ..."
# fix the --gpgcheck and --disablerepo errors for /usr/sbin/akmods
# see: https://universal-blue.discourse.group/t/need-help-building-system76-io-akmods/5725/3
sed -i "s/dnf -y \${pkg_install:-install} --nogpgcheck --disablerepo='*'/dnf -y \${pkg_install:-install}/" /usr/sbin/akmods
# check this is working
cat /usr/sbin/akmods | grep "dnf -y"

echo "Running akmods for facetimehd ..."
akmods --force --kernels "${KERNEL}" --kmod facetimehd

echo "Checking it was installed (should see facetimehd.ko.xz) ..."
modinfo "/usr/lib/modules/${KERNEL}/extra/facetimehd/facetimehd.ko.xz" > /dev/null \
    || (find /var/cache/akmods/facetimehd/ -name \*.log -print -exec cat {} \; && exit 1)

echo "Removing COPR repo download ..."
rm -f /etc/yum.repos.d/_copr_mulderje-facetimehd-kmod.repo
