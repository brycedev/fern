@interface UIApplication (Private)
    - (void) launchApplicationWithIdentifier: (NSString*)identifier suspended: (BOOL)suspended;
@end

@interface UITapticEngine : NSObject
- (void)actuateFeedback:(int)feedbackType;
@end

@interface UIDevice (Private)
- (UITapticEngine *)_tapticEngine;
@end
