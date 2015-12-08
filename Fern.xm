#import "Interfaces.h"
#import "FernSettingsManager.h"
#import "FernViewController.h"
#import <libactivator/libactivator.h>

static FernViewController *fvc;
static UIView *fern;
static UIWindow *frontWindow;
static CGFloat originalWindowLevel;

@interface FernInstance : NSObject <LAListener>
@end

@implementation FernInstance

- (BOOL)dismiss {
    if (fvc) {
        [UIView animateWithDuration:0.35 animations:^{fern.alpha = 0.0;} completion:^(BOOL finished){
           for(UIView *view in [fvc.view subviews]){
               view = nil;
           }
           [fvc release];
           fvc = nil;
           [fern removeFromSuperview];
           [frontWindow setWindowLevel: originalWindowLevel];
        }];

		return YES;
	}
	return NO;
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
    if (![self dismiss] && [[FernSettingsManager sharedManager] enabled]) {

        frontWindow = [[UIApplication sharedApplication] keyWindow];
        originalWindowLevel = [frontWindow windowLevel];

        fvc = [[FernViewController alloc] init];
        fern = fvc.view;
        [fern setAlpha: 0];

        [frontWindow addSubview: fern];
        [frontWindow setWindowLevel: UIWindowLevelAlert];

        [UIView beginAnimations:@"fadeInView" context:nil];
        [UIView setAnimationDuration: 0.35];
        [fern setAlpha: 1];
        [UIView commitAnimations];

        [event setHandled:YES];
    }
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
    [self dismiss];
}

- (void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event{
    [self dismiss];
}

- (void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event{
    if ([self dismiss])
		[event setHandled:YES];
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
	return @"Fern";
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
	return @"Display the Fern Launcher";
}

- (NSArray *)activator:(LAActivator *)activator requiresCompatibleEventModesForListenerWithName:(NSString *)listenerName {
	return [NSArray arrayWithObjects:@"springboard", @"lockscreen", @"application", nil];
}

- (NSData *)dataForActivatorImageWithScale:(CGFloat)scale {
	NSData *data;
    NSBundle *bundle = [[[NSBundle alloc] initWithPath:@"/Library/Application Support/Fern/com.brycedev.fern.bundle"] autorelease];
	if(scale < 2){
        NSString *path = [bundle pathForResource:@"activatoricon" ofType:@"png"];
		data = [[NSFileManager defaultManager] contentsAtPath:path];
	}else if (scale==2){
        NSString *path = [bundle pathForResource:@"activatoricon@2x" ofType:@"png"];
		data = [[NSFileManager defaultManager] contentsAtPath:path];
	}else{
        NSString *path = [bundle pathForResource:@"activatoricon@3x" ofType:@"png"];
		data = [[NSFileManager defaultManager] contentsAtPath:path];
	}
	return data;
}

- (NSData *)activator:(LAActivator *)activator requiresIconDataForListenerName:(NSString *)listenerName scale:(CGFloat *)scale{
	return [self dataForActivatorImageWithScale:*scale];
}

- (NSData *)activator:(LAActivator *)activator requiresSmallIconDataForListenerName:(NSString *)listenerName scale:(CGFloat *)scale{
	return [self dataForActivatorImageWithScale:*scale];
}

static void removeFernNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    if(fvc){
        [fvc release];
        fvc = nil;
        if(fern)
            [fern removeFromSuperview];
        [frontWindow setWindowLevel: originalWindowLevel];
    }
}

static void phoneDidlock(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    if(fvc){
        [fvc release];
        fvc = nil;
        if(fern)
            [fern removeFromSuperview];
        [frontWindow setWindowLevel: originalWindowLevel];
    }
}

static void updateFavorites(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    if(fvc){
        [fvc.favsController fetchFavorites];
        [fvc.favsController.tableView reloadData];
    }
}

+ (void)load {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                NULL,
                                removeFernNotification,
                                CFSTR("com.brycedev.fern.removefern"),
                                NULL,
                                CFNotificationSuspensionBehaviorCoalesce);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                NULL,
                                phoneDidlock,
                                CFSTR("com.apple.springboard.lockcomplete"),
                                NULL,
                                CFNotificationSuspensionBehaviorCoalesce);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                NULL,
                                updateFavorites,
                                CFSTR("com.brycedev.fern.modifiedfavorite"),
                                NULL,
                                CFNotificationSuspensionBehaviorCoalesce);

    if ([LASharedActivator isRunningInsideSpringBoard] && [[FernSettingsManager sharedManager] enabled])
        [[%c(LAActivator) sharedInstance] registerListener:[self new] forName:@"com.brycedev.fern.listener"];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [fvc release];
    [super dealloc];
}

@end

%ctor{
    [FernSettingsManager sharedManager];
}
