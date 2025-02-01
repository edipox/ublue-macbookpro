KERNELRELEASE := $(shell rpm -qa kernel | cut -d '-' -f2-)
KERNELDIR= := /lib/modules/$(KERNELRELEASE)
KERNELBUILD := $(KERNELDIR)/build

all:
	make -C $(KERNELBUILD) M=$(shell pwd)/build/hda modules

clean:
	make -C $(KERNELBUILD) M=$(shell pwd)/build/hda clean

install:
	make INSTALL_MOD_DIR=updates -C $(KERNELBUILD) M=$(shell pwd)/build/hda CONFIG_MODULE_SIG_ALL=n modules_install
#	cp $(shell pwd)/build/hda/snd-hda-codec-cirrus.ko $(KERNELDIR)/updates
#	depmod -a $(KERNELRELEASE)
