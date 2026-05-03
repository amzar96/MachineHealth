APP_NAME    = MachineHealth
BUILD_DIR   = .build/release
BUNDLE_DIR  = $(APP_NAME).app
INSTALL_DIR = /Applications

.PHONY: build run bundle install clean help

build:
	swift build -c release

run:
	swift run

bundle: build
	mkdir -p $(BUNDLE_DIR)/Contents/MacOS
	mkdir -p $(BUNDLE_DIR)/Contents/Resources
	cp $(BUILD_DIR)/$(APP_NAME) $(BUNDLE_DIR)/Contents/MacOS/$(APP_NAME)
	cp Resources/Info.plist $(BUNDLE_DIR)/Contents/Info.plist
	cp Resources/AppIcon.icns $(BUNDLE_DIR)/Contents/Resources/AppIcon.icns
	xattr -cr $(BUNDLE_DIR)
	codesign --force --deep --sign - $(BUNDLE_DIR)

install: bundle
	cp -R $(BUNDLE_DIR) $(INSTALL_DIR)/$(BUNDLE_DIR)

clean:
	rm -rf .build $(BUNDLE_DIR)

help:
	@printf "build    compile release binary\n"
	@printf "run      run via swift run (dev)\n"
	@printf "bundle   create MachineHealth.app\n"
	@printf "install  bundle + copy to /Applications\n"
	@printf "clean    remove .build and .app\n"
