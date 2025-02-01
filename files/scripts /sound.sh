#!/bin/bash
# Script to install sound patches from: https://github.com/davidjo/snd_hda_macbookpro

# fail if any errors
set -oue pipefail

# get the kernel release version string to pass to the script
# as 'uname -r' returns 'azure' in Github build environment
# we need to get the installed kernel from rpm => kernel-6.11.8-300.fc41.x86_64
# now cut from the second field by '-' onwards => 6.11.8-300.fc41.x86_64
kernel_release=$(rpm -qa kernel | cut -d '-' -f2-) 
echo "Using kernel release: $kernel_release ..."

# make a target directory
echo "Creating directory /lib/modules/$kernel_release/updates ..."
mkdir -p /lib/modules/$kernel_release/updates

echo "Cloning the git repository ..."
git clone https://github.com/davidjo/snd_hda_macbookpro /tmp/snd_hda_macbookpro

# edit the Makefile to explicity state the kernel release
# otherwise this uses the 'uname -r' environment which will fail
echo "Edit the Makefile to add $kernel_release ..."
sed -i "s/depmod -a/depmod -a $kernel_release/" /tmp/snd_hda_macbookpro/Makefile

echo "Calling the install script ..."
cd /tmp/snd_hda_macbookpro
./install.cirrus.driver.sh -k $kernel_release

echo "Cleaning up ..."
rm -rf /tmp/snd_hda_macbookpro
