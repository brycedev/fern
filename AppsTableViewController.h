#import "Interfaces.h"
#import <UIKit/UIKit.h>
#import "AppList/AppList.h"

@interface AppsTableViewController : UITableViewController < UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate> {
    NSArray *items;
    NSDictionary *apps;
    ALApplicationList *sharedList;
}

@end
