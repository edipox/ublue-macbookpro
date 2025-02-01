#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

# audio: https://github.com/leifliddy/macbook12-audio-driver & https://github.com/davidjo/snd_hda_macbookpro
echo "==> Install HDA audio"

echo " * clone repository"
git clone https://github.com/leifliddy/macbook12-audio-driver /tmp/macbook12-audio-driver
cd /tmp/macbook12-audio-driver

echo " * kernel version for patching"
# get the installed kernel version details with "rpm -qa kernel" => kernel-6.11.8-300.fc41.x86_64

kernel_release=$(rpm -qa kernel | cut -d '-' -f2-) # cut from the second field by '-' onwards => 6.11.8-300.fc41.x86_64
echo "   - kernel_release = $kernel_release"

kernel_full_version=$(echo $kernel_release | cut -d '-' -f1) # cut to first field by '-' => 6.11.8
echo "   - kernel_full_version = $kernel_full_version"

kernel_version=$(echo $kernel_full_version | cut -d '.' -f1) # cut to first field by '.' => 6
echo "   - kernel_version = $kernel_version"

kernel_major_revision=$(echo $kernel_full_version | cut -d '.' -f2) # second field => 11
echo "   - kernel_major_revision = $kernel_major_revision"

#kernel_minor_revision=$(echo $kernel_full_version | cut -d '.' -f3)  # third field => 8 (unused)
#echo "   - kernel_minor_revision = $kernel_minor_revision"

# specify directories under /tmp
build_dir="build"
patch_dir="patch_cirrus"
hda_dir="$build_dir/hda"
[[ ! -d $build_dir ]] && mkdir $build_dir

echo " * download kernel source"
echo "   - https://cdn.kernel.org/pub/linux/kernel/v$kernel_version.x/linux-$kernel_full_version.tar.xz"
wget -c https://cdn.kernel.org/pub/linux/kernel/v$kernel_version.x/linux-$kernel_full_version.tar.xz -P $build_dir
[[ $? -ne 0 ]] && echo "   - linux-$kernel_full_version.tar.xz could not be downloaded!" && exit

echo " * strip out the /sound/pci/hda from the kernel source"
tar --strip-components=3 -xvf $build_dir/linux-$kernel_full_version.tar.xz --directory=build/ linux-$kernel_full_version/sound/pci/hda

echo " * backup original files"
mv $hda_dir/Makefile $hda_dir/Makefile.orig
mv $hda_dir/patch_cirrus.c $hda_dir/patch_cirrus.c.orig

echo " * copy patched files"
cp $patch_dir/Makefile $patch_dir/patch_cirrus.c $patch_dir/patch_cirrus_a1534_setup.h $patch_dir/patch_cirrus_a1534_pcm.h $hda_dir/

# if kernel version is >= 6.12 then change
# snd_pci_quirk to hda_quirk
# SND_PCI_QUIRK to HDA_CODEC_QUIRK
# but leave alone SND_PCI_QUIRK_VENDOR
if (( kernel_version > 6 || (kernel_version == 6 && kernel_major_revision >= 12) )); then
   echo "   - changing some internals..."
   sed -i 's/snd_pci_quirk/hda_quirk/' $hda_dir/patch_cirrus.c
   sed -i 's/SND_PCI_QUIRK\b/HDA_CODEC_QUIRK/' $hda_dir/patch_cirrus.c
fi

update_dir="/lib/modules/$kernel_release/updates"
[[ ! -d $update_dir ]] && mkdir $update_dir

export KERNELRELEASE=$kernel_release # this is needed for 'make'
echo " * compiling kernel module"
make

# this is needed to pass in the $kernel_release to make install
echo " * altering Makefile"
sed -i 's/ifndef KERNELRELEASE/ifdef KERNELRELEASE/g' Makefile # change the if *n* def -> ifdef
sed -i 's/depmod -a/depmod -a $(KERNELRELEASE)/g' Makefile # pass in variable

echo " * installing kernel module"
make install
