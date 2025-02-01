# Bluebuild: Bluefin for Macbook Pro 13,1 💻

# Purpose

Personal image for testing a custom build for [Bluefin](https://projectbluefin.io/) with hardware modifications to support an old [Intel Macbook Pro](https://support.apple.com/en-us/111951) 13,1 (A1708)

# How did this happen?

1. This was initialised from [BlueBuild](https://blue-build.org/) [workshop](https://workshop.blue-build.org/)
2. The cosign was automatically applied...
3. You can do this manually by installing [the cosign keys](https://github.com/ublue-os/image-template?tab=readme-ov-file#container-signing):
- first install cosign (i.e. MacOS [homebrew](https://brew.sh/)) `brew install cosign`
- generate keys `cosign generate-key-pair`
- copy `cosign.pub` to the root of the github repo
- within settings, 'Actions secrets and variables', set up a secret variable named SIGNING_SECRET with the contents of `cosign.key`
4. Install [Pull app](https://github.com/apps/pull) for automatic updates

# Modifications

## 🔊 HDA Audio

- This needs a kernel module patch compiled from source.
- See the [hda_audio.sh script](https://github.com/transilluminate/bluebuild-macbookpro-a1708/blob/main/files/scripts/hda_audio.sh)
- Complete nightmare for immutable distros, and probably a really bad idea to start with.
- Not sure what I was thinking...
- Issues: `uname -r` is reported as 'azure' within the process.
- Fix: need to get the installed kernel with `rpm -qa kernel | cut -d '-' -f2-`
- From there used the process from [here](https://github.com/leifliddy/macbook12-audio-driver), which is itself modified from [here](https://github.com/davidjo/snd_hda_macbookpro).
- May look at making this into an akmod, but needs to be tested first!

## WiFi

- this was working OOB until fairly recently, but updates have since stopped it...
- to re-enable this, in terminal type `ujust configure-broadcom-wl`
- reboot, configure wifi in settings

## 🔋 Power / Sleep / Hibernate

- Issues: this does not work
- Fix: realistically, this needs to be disabled
- Will probably do something like [this](https://discussion.fedoraproject.org/t/f39-how-do-i-disable-suspend/128934/2).
- Try to use [nosuspend.conf](https://github.com/transilluminate/bluebuild-macbookpro-a1708/blob/main/files/system/etc/systemd/nosuspend.conf) which is added to the /etc folder

# Trying it out

## ⚠️ Disclaimer!

- Have not tested this! Use at own risk!
- I've got this working (with facetimehd and the cirrus driver) on fedora workstation.
- But have not yet tried to rebase this on my test HDD yet... :D
- *Pull requests welcome!*

## 💻 Install Bluefin (or any other rpm-ostree image):

- have not yet worked out how to generate an .iso yet!
- Install Bluefin from their official iso [from here](https://projectbluefin.io/)...
- enable wifi (see above for ujust terminal command)

## 🔐 Verify the cosign key (optional but recommended):
```
cosign verify --key "https://raw.githubusercontent.com/transilluminate/bluebuild-macbookpro-a1708/refs/heads/main/cosign.pub" "ghcr.io/transilluminate/bluefin-macbookpro-a1708:latest"
```
## ♻️ Swap to this version:

- from within an existing rpm-ostree installation (i.e. Bluefin)
- load a terminal, rebase to this image, then reboot:
```
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/transilluminate/bluebuild-macbookpro-a1708:latest
```
- any issues, this can then be rolled back:
```
sudo rpm-ostree rollback
```
- or back to the 'stock' bluefin version:
```
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/bluefin:latest
```
