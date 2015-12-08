#import "AppsCollectionViewController.h"
#import "FernSettingsManager.h"
#import "Interfaces.h"

static NSArray *personalIdentifiers;

@implementation AppsCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.collectionView registerClass:[AppCollectionViewCell class] forCellWithReuseIdentifier: @"Cell"];

    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .35;
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.collectionView addGestureRecognizer:lpgr];

    sharedList = [ALApplicationList sharedApplicationList];
    NSDictionary *allApps = sharedList.applications;
    NSMutableDictionary *copy = [allApps mutableCopy];
    [copy removeObjectsForKeys:[self hiddenDisplayIdentifiers]];
    if([self removeCustomIdentifiers] != nil){
        [copy removeObjectsForKeys: [self removeCustomIdentifiers]];
    }
    apps = [[NSDictionary alloc] initWithDictionary: copy];
    NSArray *displayIdentifiers = [[apps allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[apps objectForKey:obj1] caseInsensitiveCompare:[apps objectForKey:obj2]];}];

    items = displayIdentifiers;
    personalIdentifiers = [[NSArray alloc] initWithObjects: displayIdentifiers, nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [items count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AppCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [cell setBackgroundColor: [UIColor clearColor]];
    NSString *bundleID = [items objectAtIndex: indexPath.row];
    NSString *appName = [apps valueForKey: bundleID];
    UIImage *iconImage = [sharedList iconOfSize: ALApplicationIconSizeLarge forDisplayIdentifier: bundleID];
    [cell.imageView setImage:iconImage];
    if([[FernSettingsManager sharedManager] iconLabels])
        [cell.appLabel setText: appName];
    [cell setTag: indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width / 5, collectionView.frame.size.width / 5 + 25);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger cellToBlacklist = indexPath.row;
    NSString *bundleIdentifier = [[personalIdentifiers objectAtIndex: 0] objectAtIndex: indexPath.row];
    for(UITableViewCell *cell in [collectionView visibleCells]){
        if([cell tag] != (int)cellToBlacklist)
            [cell setAlpha: .3];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .35 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        for(UITableViewCell *cell in [collectionView visibleCells]){
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
    CGPoint p = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        if (indexPath != nil){
            for(UITableViewCell *cell in [self.collectionView visibleCells]){
                if([cell tag] != (int)indexPath.row)
                    [cell setAlpha: .3];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .35 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                for(UITableViewCell *cell in [self.collectionView visibleCells]){
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
                }
            });
        }
    }else{
       for(UITableViewCell *cell in [self.collectionView visibleCells]){
           if([cell tag] != (int)indexPath.row)
               [cell setAlpha: .3];
       }
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    cell.alpha = 0;
    [UIView beginAnimations:@"fade" context:NULL];
    [UIView setAnimationDuration: .25];
    cell.alpha = 1;
    cell.layer.shadowOffset = CGSizeMake(0, 0);
    [UIView commitAnimations];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
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
