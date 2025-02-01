#!/bin/bash

# fail if any errors
set -oue pipefail

# 'uname -r' returns 'azure', use this instead:
kernel_release=$(rpm -qa kernel | cut -d '-' -f2-) # cut from the second field by '-' onwards => 6.11.8-300.fc41.x86_64
echo "Using kernel release: $kernel_release ..."

echo "Cloning and moving to the git repository ..."
git clone --progress https://github.com/davidjo/snd_hda_macbookpro /tmp/snd_hda_macbookpro
cd /tmp/snd_hda_macbookpro

# edit the Makefile to explicity state the kernel release
echo "Edit the Makefile to add $kernel_release ..."
sed -i "s/depmod -a/depmod -a $kernel_release/" Makefile

echo "Calling the install script ..."
./install.cirrus.driver.sh -i -k $kernel_release

echo "Cleaning up ..."
rm -rf /tmp/snd_hda_macbookpro
