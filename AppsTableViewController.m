#import "AppsTableViewController.h"
#import "FernSettingsManager.h"
#import "FernTableViewCell.h"

static NSArray *personalIdentifiers;

@implementation AppsTableViewController

- (void)viewDidLoad {

    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .35;
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.tableView addGestureRecognizer:lpgr];

    sharedList = [ALApplicationList sharedApplicationList];
    NSDictionary *allApps = sharedList.applications;
    NSMutableDictionary *copy = [allApps mutableCopy];
    [copy removeObjectsForKeys:[self hiddenDisplayIdentifiers]];
    if([self removeCustomIdentifiers] != nil)
        [copy removeObjectsForKeys: [self removeCustomIdentifiers]];
    apps = [[NSDictionary alloc] initWithDictionary: copy];
    NSArray *displayIdentifiers = [[apps allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[apps objectForKey:obj1] caseInsensitiveCompare:[apps objectForKey:obj2]];}];

    items = displayIdentifiers;
    personalIdentifiers = [[NSArray alloc] initWithObjects: displayIdentifiers, nil];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *bundleID = [items objectAtIndex: indexPath.row];
    NSString *appName = [apps valueForKey: bundleID];
    FernTableViewCell *cell = [[FernTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    [cell setBackgroundColor: [UIColor clearColor]];
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    [cell.imageView setImage: [sharedList iconOfSize: ALApplicationIconSizeLarge forDisplayIdentifier: bundleID]];
    [cell setIndentationWidth: 0];
    [cell.textLabel setText: appName];
    [cell setTag: indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger cellToBlacklist = indexPath.row;
    NSString *bundleIdentifier = [[personalIdentifiers objectAtIndex: 0] objectAtIndex: indexPath.row];
    for(UITableViewCell *cell in [tableView visibleCells]){
        if([cell tag] != (int)cellToBlacklist)
            [cell setAlpha: .3];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        for(UITableViewCell *cell in [tableView visibleCells]){
            [cell setAlpha: 1];

        }
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                     CFSTR("com.brycedev.fern.removefern"),
                                     NULL,
                                     NULL,
                                     TRUE);
        [[UIApplication sharedApplication] launchApplicationWithIdentifier: bundleIdentifier suspended:NO];
    });
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        if (indexPath != nil){
            for(UITableViewCell *cell in [self.tableView visibleCells]){
                if([cell tag] != (int)indexPath.row)
                    [cell setAlpha: .3];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .35 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                for(UITableViewCell *cell in [self.tableView visibleCells]){
                    [cell setAlpha: 1];
                }

                [[FernSettingsManager sharedManager] updateSettings];
                NSMutableArray *favorites = [[FernSettingsManager sharedManager] favorites];
                BOOL exists = NO;
                for(NSDictionary *dict in favorites){
                    if([dict[@"bundleid"] isEqualToString: [[personalIdentifiers objectAtIndex: 0] objectAtIndex: indexPath.row]]){
                        exists = YES;
                        break;
                    }
                }
                if(!exists){
                    NSDictionary *newObj =
                        @{@"bundleid" : [[personalIdentifiers objectAtIndex: 0] objectAtIndex: indexPath.row],
                        @"name" : [apps valueForKey: [[personalIdentifiers objectAtIndex: 0] objectAtIndex: indexPath.row]],
                        @"type" : @"app",
                        @"extra" : @""
                    };
                   [favorites addObject: newObj];
                   [[FernSettingsManager sharedManager] setFavorites: favorites];
                   CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                                CFSTR("com.brycedev.fern.modifiedfavorite"),
                                                NULL,
                                                NULL,
                                                TRUE);
                }else{
                    if(exists){
                        //the favorite already exists; don't do anything
                    }else {
                        //you can only have five favorites at one time. remove some to add more
                    }
                }

            });
        }
    }else{
       for(UITableViewCell *cell in [self.tableView visibleCells]){
           if([cell tag] != (int)indexPath.row)
               [cell setAlpha: .3];
       }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.alpha = 0;
    [UIView beginAnimations:@"fade" context:NULL];
    [UIView setAnimationDuration: .25];
    cell.alpha = 1;
    cell.layer.shadowOffset = CGSizeMake(0, 0);
    [UIView commitAnimations];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
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

- (NSArray *)removeCustomIdentifiers {
    return [[NSArray alloc] initWithArray: [[FernSettingsManager sharedManager] blacklist]];
}

@end
