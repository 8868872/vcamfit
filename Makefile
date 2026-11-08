TARGET := iphone:clang:latest:16.0
ARCHS = arm64 arm64e
THEOS_PACKAGE_SCHEME = rootless

INSTALL_TARGET_PROCESSES = mediaserverd

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = VCamFit
VCamFit_FILES = Tweak.xm
VCamFit_FRAMEWORKS = Foundation CoreVideo VideoToolbox
VCamFit_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

