INSTALL_DIR=~/bin
BIN_NAME=emoji_mapping
BUILD_DIR=.build
BUILD_PATH=$(BUILD_DIR)/x86_64-apple-macosx10.10/release/$(BIN_NAME)

all: format build install clean

build:
	@swift build -c release -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.11"

install:
	@cp -p  $(BUILD_PATH) $(INSTALL_DIR)/$(BIN_NAME)

clean:
	@rm -rf $(BUILD_DIR)

format:
	@swiftlint autocorrect
	@swiftlint
	@swiftformat .
