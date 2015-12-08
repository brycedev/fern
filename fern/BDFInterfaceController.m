#import "Global.h"
#include "BDFInterfaceController.h"

UIWindow *settingsView;
UIColor *originalTint;

@implementation BDFInterfaceController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Interface" target:self] retain];
	}
	return _specifiers;
}

- (void)loadView {
	[super loadView];
	[UISwitch appearanceWhenContainedIn: self.class, nil].onTintColor = FERN_GREEN;
	[UISegmentedControl appearanceWhenContainedIn: self.class, nil].tintColor = FERN_GREEN;
}

@end
