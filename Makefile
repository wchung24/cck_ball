# CCK-BALL ZMK Firmware Build Makefile

# Configuration
BOARD := nice_nano_v2
ZMK_CONFIG := /work/config
BUILD_DIR := build
OUTPUT_DIR := /work

# Snippet for ZMK Studio support (right side only)
STUDIO_SNIPPET := studio-rpc-usb-uart

.PHONY: all setup init update left right clean help

# Default target: build both halves
all: left right

# Full setup (init + update + export)
setup: init update export

# Initialize west workspace
init:
	west init -l config

# Update west modules
update:
	west update

# Export Zephyr
export:
	west zephyr-export

# Install development dependencies (requires root)
deps:
	apt update && apt install -y vim

# Build left half (peripheral)
left:
	west build -p always -s zmk/app -b $(BOARD) -- \
		-DZMK_CONFIG=$(ZMK_CONFIG) \
		-DSHIELD=cck_ball_left
	cp $(BUILD_DIR)/zephyr/zmk.uf2 $(OUTPUT_DIR)/zmk_cck_ball_left.uf2
	@echo "✓ Left half built: $(OUTPUT_DIR)/zmk_cck_ball_left.uf2"

# Build right half (central - with ZMK Studio support)
right:
	west build -p always -s zmk/app -b $(BOARD) -S $(STUDIO_SNIPPET) -- \
		-DZMK_CONFIG=$(ZMK_CONFIG) \
		-DSHIELD=cck_ball_right \
		-DCONFIG_ZMK_STUDIO=y
	cp $(BUILD_DIR)/zephyr/zmk.uf2 $(OUTPUT_DIR)/zmk_cck_ball_right.uf2
	@echo "✓ Right half built: $(OUTPUT_DIR)/zmk_cck_ball_right.uf2"

# Clean build directory
clean:
	rm -rf $(BUILD_DIR)
	@echo "✓ Build directory cleaned"

# Help
help:
	@echo "CCK-BALL ZMK Firmware Build"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all     - Build both left and right halves (default)"
	@echo "  setup   - Initialize workspace (init + update + export)"
	@echo "  init    - Initialize west workspace"
	@echo "  update  - Update west modules"
	@echo "  export  - Export Zephyr"
	@echo "  deps    - Install development dependencies"
	@echo "  left    - Build left half only"
	@echo "  right   - Build right half only (with ZMK Studio)"
	@echo "  clean   - Clean build directory"
	@echo "  help    - Show this help message"
