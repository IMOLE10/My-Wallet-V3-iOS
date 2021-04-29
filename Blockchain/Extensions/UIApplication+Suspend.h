// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import <UIKit/UIKit.h>

@interface UIApplication (Suspend)

/**
 Suspends the current UIApplication. Used mainly by legacy code and using this
 should be avoided if possible.
 */
- (void)suspendApp;

@end
