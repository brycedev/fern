#import "FernSettingsManager.h"

@implementation FernSettingsManager

+ (instancetype)sharedManager {
    static dispatch_once_t p = 0;
    __strong static id _sharedSelf = nil;
    dispatch_once(&p, ^{
        _sharedSelf = [[self alloc] init];
    });

    return _sharedSelf;
}

void prefsChanged(CFNotificationCenterRef center, void * observer, CFStringRef name, const void * object, CFDictionaryRef userInfo) {
    [[FernSettingsManager sharedManager] updateSettings];
}

- (id)init {
    if (self = [super init]) {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, prefsChanged, CFSTR("com.brycedev.fern.prefschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        [self updateSettings];
    }

    return self;
}

- (void)updateSettings {
    self.settings = nil;
    CFPreferencesAppSynchronize(CFSTR("com.brycedev.fern"));
    CFStringRef appID = CFSTR("com.brycedev.fern");
    CFArrayRef keyList = CFPreferencesCopyKeyList(appID , kCFPreferencesCurrentUser, kCFPreferencesAnyHost) ?: CFArrayCreate(NULL, NULL, 0, NULL);
    self.settings = (NSDictionary *)CFPreferencesCopyMultiple(keyList, appID , kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFRelease(keyList);
}

- (BOOL)enabled {
    return self.settings[@"enabled"] ? [self.settings[@"enabled"] boolValue] : YES;
}

- (BOOL)blur {
    return self.settings[@"blur"] ? [self.settings[@"blur"] boolValue] : YES;
}

- (NSInteger)defaultPage {
    return self.settings[@"defaultPage"] ? [self.settings[@"defaultPage"] integerValue] : 0;
}

- (NSInteger)appsViewStyle {
    return self.settings[@"appsViewStyle"] ? [self.settings[@"appsViewStyle"] integerValue] : 1;
}

- (NSInteger)darkness {
    return self.settings[@"darkness"] ? [self.settings[@"darkness"] integerValue] : 5;
}

- (BOOL)iconLabels {
    return self.settings[@"iconLabels"] ? [self.settings[@"iconLabels"] boolValue] : YES;
}

- (NSMutableArray *)blacklist {
    return self.settings[@"blacklist"] ? [self.settings[@"blacklist"] mutableCopy] : [NSMutableArray new];
}

- (void)setBlacklist:(NSMutableArray *)blacklist {
    CFStringRef appID = CFSTR("com.brycedev.fern");
    CFPreferencesSetValue(CFSTR("blacklist"), (CFPropertyListRef *)blacklist, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    [self updateSettings];
}

- (NSMutableArray *)favorites {
    return self.settings[@"favorites"] ? [self.settings[@"favorites"] mutableCopy] : [NSMutableArray new];
}

- (void)setFavorites:(NSMutableArray *)favorites {
    CFStringRef appID = CFSTR("com.brycedev.fern");
    CFPreferencesSetValue(CFSTR("favorites"), (CFPropertyListRef *)favorites, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    [self updateSettings];
}

@end
