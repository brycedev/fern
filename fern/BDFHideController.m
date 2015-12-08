#import "Global.h"
#import "AppList/AppList.h"
#import "../FernSettingsManager.h"
#include "BDFHideController.h"

UIWindow *settingsView;
UIColor *originalTint;

@implementation BDFHideController

- (id)specifiers {

	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Hide" target:self] retain];
	}

    NSMutableArray *specifiersArray = [[NSMutableArray alloc] init];
	NSMutableArray *plistSpecifiers = [_specifiers mutableCopy];

	ALApplicationList *sharedList = [ALApplicationList sharedApplicationList];
    NSDictionary *allApps = sharedList.applications;
	NSMutableDictionary *copy = [allApps mutableCopy];
    [copy removeObjectsForKeys:[self hiddenDisplayIdentifiers]];
	NSDictionary *apps = [[NSDictionary alloc] initWithDictionary: copy];

	NSArray *displayIdentifiers = [[apps allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[apps objectForKey:obj1] caseInsensitiveCompare:[apps objectForKey:obj2]];}];

    for(id key in displayIdentifiers){

        PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed: [apps valueForKey: key]
            target:self
               set:@selector(setToggleValue:specifier:)
               get:@selector(readToggleValue:)
            detail:Nil
              cell:PSSwitchCell
              edit:Nil];

        [specifier setProperty:key forKey:@"id"];
        [specifier setProperty:@YES forKey:@"enabled"];
        [specifier setProperty:@"com.brycedev.fern" forKey:@"defaults"];
        [specifier setProperty:@"0" forKey:@"default"];
        [specifier setProperty:key forKey:@"label"];

        [specifiersArray addObject: specifier];

    }

	[plistSpecifiers addObjectsFromArray: specifiersArray];

	_specifiers = [[NSArray alloc] initWithArray: plistSpecifiers];

	return _specifiers;

}

- (void)setToggleValue:(NSNumber *)value specifier:(PSSpecifier *)specifier {
	NSMutableArray *blacklistArray = [[FernSettingsManager sharedManager] blacklist];
    if([value isEqual: @0]){
        [blacklistArray removeObject: [specifier identifier]];
    }
    else if([value isEqual: @1]){
        [blacklistArray addObject: [specifier identifier]];
    }
	[[FernSettingsManager sharedManager] setBlacklist: blacklistArray];
}

- (NSNumber *)readToggleValue:(PSSpecifier *)specifier {
    NSNumber *inBlacklist = @0;
    NSMutableArray *blacklistArray = [[FernSettingsManager sharedManager] blacklist];
	for(NSString *string in blacklistArray){
        if([string isEqual: [specifier identifier]]){
            inBlacklist = @1;
			return inBlacklist;
        }
    }
    return @0;
}

- (NSArray *)hiddenDisplayIdentifiers{
	NSArray *result = [[NSArray alloc] initWithObjects:
	    @"com.apple.AdSheet",
	    @"com.apple.AdSheetPhone",
	    @"com.apple.AdSheetPad",
	    @"com.apple.DataActivation",
	    @"com.apple.DemoApp",
	    @"com.apple.Diagnostics",
	    @"com.apple.fieldtest",
	    @"com.apple.iosdiagnostics",
	    @"com.apple.iphoneos.iPodOut",
	    @"com.apple.TrustMe",
	    @"com.apple.WebSheet",
	    @"com.apple.springboard",
	    @"com.apple.purplebuddy",
	    @"com.apple.datadetectors.DDActionsService",
	    @"com.apple.FacebookAccountMigrationDialog",
	    @"com.apple.iad.iAdOptOut",
	    @"com.apple.ios.StoreKitUIService",
	    @"com.apple.TextInput.kbd",
	    @"com.apple.MailCompositionService",
	    @"com.apple.mobilesms.compose",
	    @"com.apple.quicklook.quicklookd",
	    @"com.apple.ShoeboxUIService",
	    @"com.apple.social.remoteui.SocialUIService",
	    @"com.apple.WebViewService",
	    @"com.apple.gamecenter.GameCenterUIService",
	    @"com.apple.appleaccount.AACredentialRecoveryDialog",
	    @"com.apple.CompassCalibrationViewService",
	    @"com.apple.WebContentFilter.remoteUI.WebContentAnalysisUI",
	    @"com.apple.PassbookUIService",
	    @"com.apple.uikit.PrintStatus",
	    @"com.apple.Copilot",
	    @"com.apple.MusicUIService",
	    @"com.apple.AccountAuthenticationDialog",
	    @"com.apple.MobileReplayer",
	    @"com.apple.SiriViewService",
	    @"com.apple.TencentWeiboAccountMigrationDialog",
	    // iOS 8
	    @"com.apple.AskPermissionUI",
	    @"com.apple.CoreAuthUI",
	    @"com.apple.family",
	    @"com.apple.mobileme.fmip1",
	    @"com.apple.GameController",
	    @"com.apple.HealthPrivacyService",
	    @"com.apple.InCallService",
	    @"com.apple.mobilesms.notification",
	    @"com.apple.PhotosViewService",
	    @"com.apple.PreBoard",
	    @"com.apple.PrintKit.Print-Center",
	    @"com.apple.share",
	    @"com.apple.SharedWebCredentialViewService",
	    @"com.apple.webapp",
	    @"com.apple.webapp1",
	    // brycedev
	    @"com.apple.CloudKit.ShareBear",
	    @"com.apple.appleseed.FeedbackAssistant",
	    @"com.apple.nike",
	    @"com.apple.social.SLGoogleAuth",
		// iOS9
		@"com.apple.Home.HomeUIService",
		@"com.apple.SafariViewService",
		@"com.apple.ServerDocuments",
		@"com.apple.social.SLYahooAuth",
		@"com.apple.Diagnostics.Mitosis",
        @"com.apple.StoreDemoViewService",
	    nil];

    return result;
}

- (void)loadView {
	[super loadView];
	[UISwitch appearanceWhenContainedIn: self.class, nil].onTintColor = FERN_GREEN;
	[UISegmentedControl appearanceWhenContainedIn: self.class, nil].tintColor = FERN_GREEN;
}

@end
