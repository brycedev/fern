include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Fern
Fern_FILES = FernSettingsManager.m BDFRootListController.m BDFHideController.m BDFInterfaceController.m 
Fern_INSTALL_PATH = /Library/PreferenceBundles
Fern_LIBRARIES = applist
Fern_FRAMEWORKS = MessageUI UIKit
Fern_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Fern.plist$(ECHO_END)
