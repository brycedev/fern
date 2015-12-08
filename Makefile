include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Fern
Fern_FILES = Fern.xm FernViewController.m FavoritesTableViewController.m AppsCollectionViewController.m FernTableViewCell.m AppsTableViewController.m AppCollectionViewCell.m FernSettingsManager.m HexColors.m
Fern_LIBRARIES = activator applist
Fern_FRAMEWORKS = CoreGraphics Foundation QuartzCore UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = com.brycedev.fern
com.brycedev.fern_INSTALL_PATH = /Library/Application Support/Fern

include $(THEOS)/makefiles/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += fern
include $(THEOS_MAKE_PATH)/aggregate.mk
