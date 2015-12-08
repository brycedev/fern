#import "Interfaces.h"
#import <UIKit/UIKit.h>
#import "AppList/AppList.h"

@interface FavoritesTableViewController : UITableViewController < UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate> {
    ALApplicationList *sharedList;
}

@property(retain, nonatomic) NSMutableArray *items;
- (void)fetchFavorites;
@end
