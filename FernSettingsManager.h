@interface FernSettingsManager : NSObject

@property (nonatomic, copy) NSDictionary *settings;

@property (nonatomic, readonly) BOOL enabled;
@property (nonatomic, readonly) BOOL blur;
@property (nonatomic, readonly) NSInteger defaultPage;
@property (nonatomic, readonly) NSInteger appsViewStyle;
@property (nonatomic, readonly) NSInteger darkness;
@property (nonatomic, readonly) BOOL iconLabels;
@property (nonatomic, copy) NSMutableArray *blacklist;
@property (nonatomic, copy) NSMutableArray *favorites;

+ (instancetype)sharedManager;
- (void)updateSettings;

@end
