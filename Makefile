VERSION=0.1.1

all: package

package:
	mkdir -p packages
	pkgbuild --root build --install-location '/Library/Input Methods' --component-plist AewolInputPackage.plist packages/AewolInput-$(VERSION).pkg
