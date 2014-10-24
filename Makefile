TARGET=iphone:clang:latest:6.0
THEOS_DEVICE_PORT=22
GO_EASY_ON_ME=1
export ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

THEOS_BUILD_DIR = Packages

LIBRARY_NAME = libuaunbox
libuaunbox_LOGOSFLAGS = -c generator=internal
libuaunbox_FILES = UBClient.m
libuaunbox_CFLAGS = -I.
libuaunbox_LIBRARIES = rocketbootstrap
libuaunbox_PRIVATE_FRAMEWORKS = AppSupport
libuaunbox_INSTALL_PATH = /usr/lib

TOOL_NAME = uaunbox
uaunbox_FILES = UBServer.m UBDelegate.m
uaunbox_FRAMEWORKS = Foundation CoreFoundation
uaunbox_PRIVATE_FRAMEWORKS = AppSupport
uaunbox_LIBRARIES = rocketbootstrap
uaunbox_INSTALL_PATH = /usr/libexec

include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/tool.mk

before-package::
	sudo find _ -name "uaunbox" -exec chown root:wheel {} \;
	sudo find _ -name "uaunbox" -exec chmod 4777 {} \;
	sudo find _ -name "com.unlimapps.uaunboxdlaunch.plist" -exec chown root:wheel {} \;
	find _ -name "uaunboxdlaunch" -exec chmod 755 {} \;
