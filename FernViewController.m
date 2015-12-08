#import "FernSettingsManager.h"
#import "FernViewController.h"
#import "HexColors.h"

static CGFloat maxHeight;
static CGFloat maxWidth;

UILabel *titleLabel;
UIPageControl *pageControl;
UIScrollView *scrollView;

UITableView *favsTableView;
UITableView *appsTableView;
UICollectionView *appsCollectionView;

AppsTableViewController *appsController;
AppsCollectionViewController *appsCollectionController;

@implementation FernViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    maxHeight = [[UIScreen mainScreen] bounds].size.height;
    maxWidth = [[UIScreen mainScreen] bounds].size.width;

    if ((appsController == nil) && ([[FernSettingsManager sharedManager] appsViewStyle] == 0)){

        appsController = [[AppsTableViewController alloc] init];

        [appsTableView setDataSource: appsController];
        [appsTableView setDelegate: appsController];
        appsTableView = appsController.tableView;

    }

    if (self.favsController == nil){

        self.favsController = [[FavoritesTableViewController alloc] init];

        [favsTableView setDataSource: self.favsController];
        [favsTableView setDelegate: self.favsController];
        favsTableView = self.favsController.tableView;

    }

    if ((appsCollectionController == nil) && ([[FernSettingsManager sharedManager] appsViewStyle] == 1)){

        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setMinimumInteritemSpacing: 20.0f];
        [layout setMinimumLineSpacing: 40.0f];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;

        appsCollectionController = [[AppsCollectionViewController alloc] initWithCollectionViewLayout: layout];

        [appsCollectionView setDataSource: appsCollectionController];
        [appsCollectionView setDelegate: appsCollectionController];
        appsCollectionView = appsCollectionController.collectionView;

    }

    if([[FernSettingsManager sharedManager] blur]){

        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle: 1];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [visualEffectView setFrame: [[UIScreen mainScreen] bounds]];
        [self.view addSubview: visualEffectView];

    }

    UIView *overlayView = [[UIView alloc] init];
    [overlayView setFrame: self.view.frame];
    [overlayView setBackgroundColor: [UIColor blackColor]];
    [overlayView setAlpha: (float)[[FernSettingsManager sharedManager] darkness]/10];
    [self.view addSubview: overlayView];

    titleLabel = [[UILabel alloc] init];
    CGFloat titleLabelX = (maxWidth - (.9 * maxWidth)) / 2;
    CGFloat titleLabelY = 30;
    CGFloat titleLabelWidth = .9 * maxWidth;
    CGFloat titleLabelHeight = 80;
    [titleLabel setFrame: CGRectMake(titleLabelX, titleLabelY, titleLabelWidth, titleLabelHeight)];
    [titleLabel setFont: [UIFont systemFontOfSize: 36]];
    [titleLabel setTextAlignment: NSTextAlignmentLeft];
    [titleLabel setTextColor: [UIColor whiteColor]];
    [titleLabel setText: @"Favorites"];
    [titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview: titleLabel];

    UIView *inputBorder = [[UIView alloc] init];
    CGFloat inputBorderX = [titleLabel frame].origin.x;
    CGFloat inputBorderY = [titleLabel frame].origin.y + [titleLabel frame].size.height;
    CGFloat inputBorderWidth = [titleLabel frame].size.width;
    CGFloat inputBorderHeight = 1;
    [inputBorder setFrame: CGRectMake(inputBorderX, inputBorderY, inputBorderWidth, inputBorderHeight)];
    [inputBorder setBackgroundColor: [UIColor whiteColor]];
    [inputBorder setAlpha: .75];
    [self.view addSubview: inputBorder];

    pageControl = [[UIPageControl alloc] init];
    CGFloat pageControlX = [titleLabel frame].origin.x;
    CGFloat pageControlY = [inputBorder frame].origin.y + [inputBorder frame].size.height + 5;
    CGFloat pageControlWidth = [inputBorder frame].size.width;
    CGFloat pageControlHeight = 30;
    [pageControl setFrame: CGRectMake(pageControlX, pageControlY, pageControlWidth, pageControlHeight)];
    [pageControl setCurrentPage:0];
    [pageControl setNumberOfPages: 2];
    [self.view addSubview: pageControl];

    scrollView = [[UIScrollView alloc] init];
    [scrollView setPagingEnabled: YES];
    [scrollView setBackgroundColor: [UIColor clearColor]];
    CGFloat scrollViewX = 0;
    CGFloat scrollViewY = [pageControl frame].origin.y + [pageControl frame].size.height + 5;
    CGFloat scrollViewWidth = maxWidth;
    CGFloat scrollViewHeight = maxHeight - scrollViewY;
    [scrollView setFrame: CGRectMake(scrollViewX, scrollViewY, scrollViewWidth, scrollViewHeight)];
    [scrollView setContentSize: CGSizeMake([scrollView frame].size.width *2, [scrollView frame].size.height)];
    [scrollView setDelegate: self];
    [self.view addSubview: scrollView];

    CGFloat tableHeight = [scrollView frame].size.height;

    [favsTableView setFrame: CGRectMake(inputBorderX, 0, inputBorderWidth, tableHeight)];
    [favsTableView setBackgroundColor: [UIColor clearColor]];
    [favsTableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    [favsTableView setShowsVerticalScrollIndicator: NO];
    [scrollView addSubview: favsTableView];
    [scrollView setShowsHorizontalScrollIndicator: NO];

    if([[FernSettingsManager sharedManager] appsViewStyle] == 0){
        CGFloat appsTableViewX = [scrollView frame].size.width + titleLabelX;
        [appsTableView setFrame: CGRectMake(appsTableViewX, 0, inputBorderWidth, tableHeight)];
        [appsTableView setBackgroundColor: [UIColor clearColor]];
        [appsTableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
        [appsTableView setShowsVerticalScrollIndicator: NO];
        [scrollView addSubview: appsTableView];
    }
    else if([[FernSettingsManager sharedManager] appsViewStyle] == 1){
        CGFloat appsCollectionViewX = [scrollView frame].size.width + titleLabelX;
        [appsCollectionView setFrame: CGRectMake(appsCollectionViewX, 0, inputBorderWidth, tableHeight)];
        [appsCollectionView setBackgroundColor: [UIColor clearColor]];
        [appsCollectionView setShowsVerticalScrollIndicator: NO];
        [scrollView addSubview: appsCollectionView];
    }

    [self setDefaultPage: [[FernSettingsManager sharedManager] defaultPage]];

}


- (void)setDefaultPage:(NSInteger)num {

    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * num;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];

    if(num == 0)
        [titleLabel setText: @"Favorites"];
    if(num == 1)
        [titleLabel setText: @"Apps"];

    [pageControl setCurrentPage: (int)num];

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
    CGFloat currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/ pageWidth)+1;

    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.duration = 0.35;
    [titleLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];

    if(currentPage == 0)
        [titleLabel setText: @"Favorites"];
    if(currentPage == 1)
        [titleLabel setText: @"Apps"];

    [pageControl setCurrentPage: (int)currentPage];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
  [super dealloc];
}

@end
