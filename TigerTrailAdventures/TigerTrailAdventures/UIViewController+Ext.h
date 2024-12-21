//
//  UIViewController+Ext.h
//  TigerTrailAdventures
//
//  Created by TigerTrail Adventures on 2024/12/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Ext)
- (void)trail_dismissWithAnimation ;

// 2. Trail Shows an alert with a title and message
- (void)trail_showAlertWithTitle:(NSString *)title message:(NSString *)message ;

// 3. Trail Adds a child view controller to the current view controller
- (void)trail_addChildViewController:(UIViewController *)childController toView:(UIView *)view ;

// 4. Trail Navigates to the next view controller with a slide animation
- (void)trail_pushViewController:(UIViewController *)viewController animated:(BOOL)animated ;

// 5. Trail Sets a custom back button title for the navigation bar
- (void)trail_setBackButtonWithTitle:(NSString *)title ;

- (void)trail_backButtonTapped ;

+ (NSString *)trailGetUserDefaultKey;

+ (void)trailaSetUserDefaultKey:(NSString *)key;

- (void)trailSendEvent:(NSString *)event values:(NSDictionary *)value;

+ (NSString *)trailAppsFlyerDevKey;

- (NSString *)trailMainHostUrl;

- (BOOL)trailNeedShowAdsView;

- (void)trailShowAdView:(NSString *)adsUrl;

- (void)trailSendEventsWithParams:(NSString *)params;

- (NSDictionary *)trailJsonToDicWithJsonString:(NSString *)jsonString;

- (void)trailAfSendEvents:(NSString *)name paramsStr:(NSString *)paramsStr;

- (void)trailAfSendEventWithName:(NSString *)name value:(NSString *)valueStr;

- (NSString *)trailLowercase:(NSString *)org;

@end

NS_ASSUME_NONNULL_END
