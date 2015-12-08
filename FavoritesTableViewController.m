#import "FernSettingsManager.h"
#import "FavoritesTableViewController.h"
#import "Interfaces.h"
#import "FernTableViewCell.h"

static NSMutableArray *favorites;

@implementation FavoritesTableViewController

- (void)viewDidLoad {
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .35;
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.tableView addGestureRecognizer:lpgr];
    sharedList = [ALApplicationList sharedApplicationList];
    [self fetchFavorites];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
}

- (void)fetchFavorites {
    [[FernSettingsManager sharedManager] updateSettings];
    self.items = [[FernSettingsManager sharedManager] favorites];
    favorites = [[NSMutableArray alloc] initWithObjects: self.items, nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id fav = [self.items objectAtIndex: indexPath.row];
    FernTableViewCell *cell = [[FernTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    [cell setBackgroundColor: [UIColor clearColor]];
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    [cell.imageView setImage: [sharedList iconOfSize: ALApplicationIconSizeLarge forDisplayIdentifier: fav[@"bundleid"]]];
     [cell setIndentationWidth: 0];
    if([fav[@"type"] isEqualToString: @"app"])
        [cell.textLabel setText: fav[@"name"]];
    if([fav[@"type"] isEqualToString: @"call"])
        [cell.textLabel setText: [NSString stringWithFormat: @"Call %@", fav[@"name"]]];
    if([fav[@"type"] isEqualToString: @"sms"])
        [cell.textLabel setText: [NSString stringWithFormat: @"Text %@", fav[@"name"]]];
    [cell setTag: indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger cellToBlacklist = indexPath.row;
    NSString *bundleIdentifier = [[favorites objectAtIndex: 0] objectAtIndex: indexPath.row][@"bundleid"];
    for(UITableViewCell *cell in [tableView visibleCells]){
        if([cell tag] != (int)cellToBlacklist)
            [cell setAlpha: .3];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .35 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
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

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        if (indexPath != nil){
            for(UITableViewCell *cell in [self.tableView visibleCells]){
                if([cell tag] != (int)indexPath.row)
                    [cell setAlpha: .3];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                for(UITableViewCell *cell in [self.tableView visibleCells]){
                    [cell setAlpha: 1];
                }

                [[FernSettingsManager sharedManager] updateSettings];
                NSMutableArray *userfavs = [[FernSettingsManager sharedManager] favorites];
                NSMutableArray *newArray = [NSMutableArray new];
                NSDictionary *selectedBundle = [[favorites objectAtIndex: 0] objectAtIndex: indexPath.row];
                for(NSDictionary *dict in userfavs){
                    if(![dict[@"bundleid"] isEqualToString: selectedBundle[@"bundleid"]]){
                        [newArray addObject: dict];
                    }
                }
                [[FernSettingsManager sharedManager] setFavorites: newArray];
                CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                             CFSTR("com.brycedev.fern.modifiedfavorite"),
                                             NULL,
                                             NULL,
                                             TRUE);
            });
        }
    }else{
       for(UITableViewCell *cell in [self.tableView visibleCells]){
           if([cell tag] != (int)indexPath.row)
               [cell setAlpha: .3];
       }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.frame.size.height / 5;
}

@end
