//
//  FernViewController.h
//  Fern
//
//  Created by Bryce Jackson on 8/1/15.
//  Copyright (c) 2015 Bryce Jackson. All rights reserved.
//

#import "AppsTableViewController.h"
#import "FavoritesTableViewController.h"
#import "AppsCollectionViewController.h"

@interface FernViewController : UIViewController <UIScrollViewDelegate>
@property(retain, nonatomic) FavoritesTableViewController *favsController;;
@end
