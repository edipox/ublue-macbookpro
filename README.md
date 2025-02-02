# Bluebuild: Bluefin for Macbook Pro 13,1 💻

# Purpose

Personal image for testing a custom build for [Bluefin](https://projectbluefin.io/) with hardware modifications to support an old [Intel Macbook Pro](https://support.apple.com/en-us/111951) 13,1 (A1708)

# 🦖 How did this happen?

1. This was initialised from [BlueBuild](https://blue-build.org/) [workshop](https://workshop.blue-build.org/)
2. The cosign was automatically applied...
3. You can do this manually by installing [the cosign keys](https://github.com/ublue-os/image-template?tab=readme-ov-file#container-signing):
- first install cosign (i.e. MacOS [homebrew](https://brew.sh/)) `brew install cosign`
- generate keys `cosign generate-key-pair`
- copy `cosign.pub` to the root of the github repo
- within settings, 'Actions secrets and variables', set up a secret variable named SIGNING_SECRET with the contents of `cosign.key`
4. Install [Pull app](https://github.com/apps/pull) for automatic updates

# Modifications

## 📸 Facetime Webcam

- Working ✅
- What a nightmare! Akmods aren't the easiest!
- See the install script here: [webcam.sh](https://github.com/transilluminate/bluebuild-macbookpro-a1708/blob/main/files/scripts/webcam.sh)
- This needed a few fixes for the build to work (directory permissions, directories not existing, and build flags...)
- The worst was patching `/usr/sbin/akmods` to remove the `--nogpgcheck --disablerepo` flags as these failed the build!

## 🔊 HDA Audio

- Working ✅
- This needs a kernel module patch compiled from source.
- See the install script here: [audio.sh](https://github.com/transilluminate/bluebuild-macbookpro-a1708/blob/main/files/scripts/audio.sh)
- Complete nightmare for immutable distros, and probably a really bad idea to start with!
- Issues: `uname -r` is reported as 'azure' within the build process
- Fix: need to get the installed kernel release with `rpm -qa kernel | cut -d '-' -f2-`
- The Makefile then needed to be edited to explicitly pass the kernel version to `depmod`

## 🛜 WiFi

- Working ✅
- this was working OOB until fairly recently, but updates have since stopped it...
- to re-enable this, in terminal type `ujust configure-broadcom-wl`
- reboot, configure wifi in settings

## 🔋 Power / Sleep / Hibernate

- Not Working ❌
- The targets are currently disabled using systemctl:
```
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```
- There _may_ be a way to improve things... see the [info here](https://github.com/Dunedan/mbp-2016-linux?tab=readme-ov-file#suspend--hibernation) about disabling the NVMe controller's power state (`d3cold_allowed`), and there's a potential way to do this [suggested here](https://github.com/transilluminate/bluebuild-macbookpro-a1708/blob/main/files/scripts/disable_sleep.sh)...

# Trying it out

## ⚠️ Disclaimer!

- Minimal testing has been done, use at your own risk!
- *Pull requests welcome!*

## 💻 Install Bluefin (or any other rpm-ostree image):

- have not yet worked out how to generate an .iso yet!
- Install Bluefin from their official iso [from here](https://projectbluefin.io/)...
- enable wifi (see above for ujust terminal command)

## 🔐 Verify the cosign key (optional but recommended):
```
cosign verify --key "https://raw.githubusercontent.com/transilluminate/bluebuild-macbookpro-a1708/refs/heads/main/cosign.pub" "ghcr.io/transilluminate/macbookpro-13-1-bluefin"
```
## ♻️ Rebase to this version:

- from within an existing rpm-ostree installation (i.e. Bluefin)
- load a terminal, rebase to this image, then reboot:
```
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/transilluminate/macbookpro-13-1-bluefin
```
- any issues, this can then be rolled back:
```
sudo rpm-ostree rollback
```
- or back to the 'stock' bluefin version:
```
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/bluefin:latest
```
