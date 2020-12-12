.DEFAULT_GOAL := help

BUILD_DIR := squashfs-root
DATE := $(shell date +%y%m%d-%H%M)

all: extract patch build

extract:
	unsquashfs $(FILE)

build:
	rm -f $(BUILD_DIR)/patched 2>/dev/null
	mksquashfs $(BUILD_DIR) release/image-$(DATE) -comp xz -noappend -always-use-fragments

patch:
	@for PATCH in scripts/??_*.sh; do \
		echo ">> $$PATCH"; \
		ROOTFS=$(BUILD_DIR) sh $$PATCH; \
		echo "----"; \
	done | tee -a patch.log
	@touch $(BUILD_DIR)/patched

clean:
	rm -rf $(BUILD_DIR)

$(BUILD_DIR): extract
$(BUILD_DIR)/patched: patch

help:
	@echo "Usage (as root): "
	@echo ""
	@echo "  make extract FILE=mtd4 - Extract the content of the image."
	@echo "                           Beware $(BUILD_DIR) will be deleted!"
	@echo ""
	@echo "  make patch             - Apply patches."
	@echo ""
	@echo "  make build             - Create a new image in release folder."
	@echo ""