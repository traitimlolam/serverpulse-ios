TARGET := iphone:clang:latest:15.0
ARCHS := arm64 arm64e

FINALPACKAGE = 1
DEBUG = 0

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = ServerPulse

ServerPulse_FILES = main.m AppDelegate.m RootViewController.m SettingsViewController.m
ServerPulse_FRAMEWORKS = UIKit CoreGraphics Foundation
ServerPulse_RESOURCE_DIRS = Resources
ServerPulse_CFLAGS = -fobjc-arc -I. -Wno-error -Wno-unguarded-availability-new
ServerPulse_CODESIGN_FLAGS = -Sentitlements.plist

include $(THEOS_MAKE_PATH)/application.mk
