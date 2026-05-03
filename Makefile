APP_NAME    = MachineHealth
BUILD_DIR   = .build/release
BUNDLE_DIR  = $(APP_NAME).app
INSTALL_DIR = /Applications

.PHONY: build run bundle install clean release help

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

release:
ifndef VERSION
	$(error VERSION is required — usage: make release VERSION=1.2.0)
endif
	@echo "Bumping version to $(VERSION)..."
	/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $(VERSION)" Resources/Info.plist
	/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $(shell git rev-list --count HEAD)" Resources/Info.plist
	git add Resources/Info.plist
	git commit -m "chore: bump version to $(VERSION)"
	git tag v$(VERSION)
	git push origin master --tags
	@echo "Tag v$(VERSION) pushed — release workflow will handle the rest."

clean:
	rm -rf .build $(BUNDLE_DIR)

help:
	@printf "build              compile release binary\n"
	@printf "run                run via swift run (dev)\n"
	@printf "bundle             create MachineHealth.app\n"
	@printf "install            bundle + copy to /Applications\n"
	@printf "release VERSION=x  bump version, tag, push — triggers CI release\n"
	@printf "clean              remove .build and .app\n"
