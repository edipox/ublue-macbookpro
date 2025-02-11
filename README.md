[![ublue-macbookpro](https://github.com/transilluminate/ublue-macbookpro/actions/workflows/build.yml/badge.svg)](https://github.com/transilluminate/ublue-macbookpro/actions/workflows/build.yml)

# Universal Blue Custom Images for Macbook Pro 13,1 💻 (A1708)

# 🎯 Purpose

This is a personal image for testing a custom build for [Bluefin](https://projectbluefin.io/) and [Aurora](https://getaurora.dev/) with modifications to support custom hardware: an old [Intel Macbook Pro](https://support.apple.com/en-us/111951) 13,1 (A1708). Other immutable flavours will likely work just fine, just need to alter the [recipe](https://github.com/transilluminate/ublue-macbookpro/tree/main/recipes) to specify another base-image.

# 📋 Current Status

## 🔊 HDA Audio

- Working ✅
- This needs a kernel module patch compiled from [source](https://github.com/davidjo/snd_hda_macbookpro).
- See the install script here: [audio.sh](https://github.com/transilluminate/ublue-macbookpro/blob/main/files/scripts/audio.sh)
- Generally when an external script is called, they make use of `uname -r` to determine the current release of Linux
- This fails in the build process (Github actions), as this is reported as `azure` (Microsoft's [Azure Linux](https://en.wikipedia.org/wiki/Azure_Linux) Container OS host)
- To overcome this, the installed kernel release can be found with `rpm -qa kernel | cut -d '-' -f2-`
- With this script, the downloaded external Makefile is modified in-place using `sed` to explicitly pass the kernel release to `depmod -a`
  
## 📸 Facetime Webcam

- Working ✅
- Building this was a nightmare! Akmods aren't the easiest!
- See the install script here: [webcam.sh](https://github.com/transilluminate/ublue-macbookpro/blob/main/files/scripts/webcam.sh)
- This needed a few fixes for the build to work (directory permissions, directories not existing, and build flags...)
- The worst was patching `/usr/sbin/akmods` to remove the `--nogpgcheck --disablerepo` flags as these failed the build!

## 🛜 WiFi

- Working ✅
- this was working OOB until fairly recently, but broke on an update...
- to re-enable this, in terminal type `ujust configure-broadcom-wl`
- reboot, then configure WiFi in settings :)

## 🔋 Power / Sleep / Hibernate

- Not Working ❌
- There is no easy fix for this, so the targets are currently disabled using systemctl
- See the script here: [disable_sleep.sh](https://github.com/transilluminate/ublue-macbookpro/blob/main/files/scripts/disable_sleep.sh)
- There _may_ be a way to improve things...
- See the [info here](https://github.com/Dunedan/mbp-2016-linux?tab=readme-ov-file#suspend--hibernation) about disabling the NVMe controller's power state (`d3cold_allowed`)
- ... however, I can live without sleep! ☕

# Trying it out

## ⚠️ Disclaimer!

- Minimal testing has been done, use at your own risk!
- *Pull requests welcome!*

## 💻 Install Bluefin (or any other rpm-ostree image):

- Install Bluefin from their official iso [from here](https://projectbluefin.io/)...
- (reason: have not worked out how to generate an .iso!)
- enable wifi (see above for ujust terminal command)

## 🔐 Verify the cosign key (optional, but recommended):
```
cosign verify --key "https://raw.githubusercontent.com/transilluminate/ublue-macbookpro/refs/heads/main/cosign.pub" "ghcr.io/transilluminate/macbookpro-bluefin"
cosign verify --key "https://raw.githubusercontent.com/transilluminate/ublue-macbookpro/refs/heads/main/cosign.pub" "ghcr.io/transilluminate/macbookpro-aurora"
```
## ♻️ Rebase to this version:

- from within an existing rpm-ostree installation (i.e. Bluefin)
- load a terminal, rebase to this image, then reboot:
```
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/transilluminate/macbookpro-bluefin
systemctl reboot
```
- alternatively the Aurora image can be used:
```
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/transilluminate/macbookpro-aurora
systemctl reboot
```
- any issues, this can then be rolled back:
```
sudo rpm-ostree rollback
```
- or back to the 'stock' bluefin version:
```
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/bluefin:latest
```
# 🦖 How did this happen?

1. This was initialised from [BlueBuild](https://blue-build.org/) [workshop](https://workshop.blue-build.org/)
2. The cosign was automatically applied...
3. Alternatively, you can [do this manually](https://github.com/ublue-os/image-template?tab=readme-ov-file#container-signing):
- first install cosign (i.e. MacOS [homebrew](https://brew.sh/)) `brew install cosign`
- generate keys `cosign generate-key-pair`
- copy `cosign.pub` to the root of the github repo
- within settings, 'Actions secrets and variables', set up a secret variable named SIGNING_SECRET with the contents of `cosign.key`
4. Install [Pull app](https://github.com/apps/pull) for automatic updates
5. The build process is automatic with Github actions:
6. The Github workflow is triggered (see .github/workflows/[build.yml](https://github.com/transilluminate/ublue-macbookpro/blob/main/.github/workflows/build.yml))
7. This loads both the recipes to build (see the [recipes](https://github.com/transilluminate/ublue-macbookpro/tree/main/recipes) folder)
8. This in turn calls various custom scripts (see the [scripts](https://github.com/transilluminate/ublue-macbookpro/tree/main/files/scripts) folder)
9. On successful build this is pushed to the container registry (ghcr.io) where it can be pulled...
