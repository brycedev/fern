#import "Interfaces.h"
#import "AppCollectionViewCell.h"
#import "AppList/AppList.h"

@interface AppsCollectionViewController : UICollectionViewController < UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate> {
    NSArray *items;
    NSDictionary *apps;
    ALApplicationList *sharedList;
}


@end
