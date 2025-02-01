#!/bin/bash
# Script to install facetimehd akmod from: https://copr.fedorainfracloud.org/coprs/mulderje/intel-mac-rpms

sudo curl -L -o /etc/yum.repos.d/_copr_mulderje-intel-mac-rpms.repo \
    "https://copr.fedorainfracloud.org/coprs/mulderje/intel-mac-rpms/repo/fedora-$(rpm -E %fedora)/mulderje-intel-mac-rpms-fedora-$(rpm -E %fedora).repo"

rpm-ostree install facetimehd-kmod
