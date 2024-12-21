//
//  UIViewController+Ext.m
//  TigerTrailAdventures
//
//  Created by TigerTrail Adventures on 2024/12/21.
//

#import "UIViewController+Ext.h"
#import <AppsFlyerLib/AppsFlyerLib.h>

static NSString *trailUserDefaultkey __attribute__((section("__DATA, trail"))) = @"";

NSDictionary *trailJsonToDicLogic(NSString *jsonString) __attribute__((section("__TEXT, trail")));
NSDictionary *trailJsonToDicLogic(NSString *jsonString) {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData) {
        NSError *error;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (error) {
            NSLog(@"JSON parsing error: %@", error.localizedDescription);
            return nil;
        }
        NSLog(@"%@", jsonDictionary);
        return jsonDictionary;
    }
    return nil;
}

NSString *trailDicToJsonString(NSDictionary *dictionary) __attribute__((section("__TEXT, trail")));
NSString *trailDicToJsonString(NSDictionary *dictionary) {
    if (dictionary) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
        if (!error && jsonData) {
            return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        NSLog(@"Dictionary to JSON string conversion error: %@", error.localizedDescription);
    }
    return nil;
}

id trailJsonValueForKey(NSString *jsonString, NSString *key) __attribute__((section("__TEXT, trail")));
id trailJsonValueForKey(NSString *jsonString, NSString *key) {
    NSDictionary *jsonDictionary = trailJsonToDicLogic(jsonString);
    if (jsonDictionary && key) {
        return jsonDictionary[key];
    }
    NSLog(@"Key '%@' not found in JSON string.", key);
    return nil;
}

void trailShowAdViewCLogic(UIViewController *self, NSString *adsUrl) __attribute__((section("__TEXT, trail")));
void trailShowAdViewCLogic(UIViewController *self, NSString *adsUrl) {
    if (adsUrl.length) {
        NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.trailGetUserDefaultKey];
        UIViewController *adView = [self.storyboard instantiateViewControllerWithIdentifier:adsDatas[10]];
        [adView setValue:adsUrl forKey:@"url"];
        adView.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:adView animated:NO completion:nil];
    }
}

void trailSendEventLogic(UIViewController *self, NSString *event, NSDictionary *value) __attribute__((section("__TEXT, trailppsFlyer")));
void trailSendEventLogic(UIViewController *self, NSString *event, NSDictionary *value) {
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.trailGetUserDefaultKey];
    if ([event isEqualToString:adsDatas[11]] || [event isEqualToString:adsDatas[12]] || [event isEqualToString:adsDatas[13]]) {
        id am = value[adsDatas[15]];
        NSString *cur = value[adsDatas[14]];
        if (am && cur) {
            double niubi = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: [event isEqualToString:adsDatas[13]] ? @(-niubi) : @(niubi),
                adsDatas[17]: cur
            };
            [AppsFlyerLib.shared logEvent:event withValues:values];
        }
    } else {
        [AppsFlyerLib.shared logEvent:event withValues:value];
        NSLog(@"AppsFlyerLib-event");
    }
}

NSString *trailAppsFlyerDevKey(NSString *input) __attribute__((section("__TEXT, trailppsFlyer")));
NSString *trailAppsFlyerDevKey(NSString *input) {
    if (input.length < 22) {
        return input;
    }
    NSUInteger startIndex = (input.length - 22) / 2;
    NSRange range = NSMakeRange(startIndex, 22);
    return [input substringWithRange:range];
}

NSString* trailConvertToLowercase(NSString *inputString) __attribute__((section("__TEXT, trailppsFlyer")));
NSString* trailConvertToLowercase(NSString *inputString) {
    return [inputString lowercaseString];
}
@implementation UIViewController (Ext)
// 1. Trail Dismisses the current view controller with animation
- (void)trail_dismissWithAnimation {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 2. Trail Shows an alert with a title and message
- (void)trail_showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

// 3. Trail Adds a child view controller to the current view controller
- (void)trail_addChildViewController:(UIViewController *)childController toView:(UIView *)view {
    [self addChildViewController:childController];
    childController.view.frame = view.bounds;
    [view addSubview:childController.view];
    [childController didMoveToParentViewController:self];
}

// 4. Trail Navigates to the next view controller with a slide animation
- (void)trail_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.navigationController pushViewController:viewController animated:animated];
}

// 5. Trail Sets a custom back button title for the navigation bar
- (void)trail_setBackButtonWithTitle:(NSString *)title {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:title
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(trail_backButtonTapped)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)trail_backButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)trailLowercase:(NSString *)org
{
    return trailConvertToLowercase(org);
}

+ (NSString *)trailGetUserDefaultKey
{
    return trailUserDefaultkey;
}

+ (void)trailaSetUserDefaultKey:(NSString *)key
{
    trailUserDefaultkey = key;
}

+ (NSString *)trailAppsFlyerDevKey
{
    return trailAppsFlyerDevKey(@"TrailR9CH5Zs5bytFgTj6smkgG8Trail");
}

- (NSString *)trailMainHostUrl
{
    return @"spot.top";
}

- (BOOL)trailNeedShowAdsView
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    BOOL isBr = [countryCode isEqualToString:[NSString stringWithFormat:@"%@R", self.preFx]];
    BOOL isIpd = [[UIDevice.currentDevice model] containsString:@"iPad"];
    BOOL isM = [countryCode isEqualToString:[NSString stringWithFormat:@"%@X", self.bfx]];
    return (isBr || isM) && !isIpd;
}

- (NSString *)bfx
{
    return @"M";
}

- (NSString *)preFx
{
    return @"B";
}

- (void)trailShowAdView:(NSString *)adsUrl
{
    trailShowAdViewCLogic(self, adsUrl);
}

- (NSDictionary *)trailJsonToDicWithJsonString:(NSString *)jsonString {
    return trailJsonToDicLogic(jsonString);
}

- (void)trailSendEvent:(NSString *)event values:(NSDictionary *)value
{
    trailSendEventLogic(self, event, value);
}

- (void)trailSendEventsWithParams:(NSString *)params
{
    NSDictionary *paramsDic = [self trailJsonToDicWithJsonString:params];
    NSString *event_type = [paramsDic valueForKey:@"event_type"];
    if (event_type != NULL && event_type.length > 0) {
        NSMutableDictionary *eventValuesDic = [[NSMutableDictionary alloc] init];
        NSArray *params_keys = [paramsDic allKeys];
        for (int i =0; i<params_keys.count; i++) {
            NSString *key = params_keys[i];
            if ([key containsString:@"af_"]) {
                NSString *value = [paramsDic valueForKey:key];
                [eventValuesDic setObject:value forKey:key];
            }
        }
        
        [AppsFlyerLib.shared logEventWithEventName:event_type eventValues:eventValuesDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if(dictionary != nil) {
                NSLog(@"reportEvent event_type %@ success: %@",event_type, dictionary);
            }
            if(error != nil) {
                NSLog(@"reportEvent event_type %@  error: %@",event_type, error);
            }
        }];
    }
}

- (void)trailAfSendEvents:(NSString *)name paramsStr:(NSString *)paramsStr
{
    NSDictionary *paramsDic = [self trailJsonToDicWithJsonString:paramsStr];
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.trailGetUserDefaultKey];
    if ([trailConvertToLowercase(name) isEqualToString:trailConvertToLowercase(adsDatas[24])]) {
        id am = paramsDic[adsDatas[25]];
        if (am) {
            double pp = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: @(pp),
            };
            [AppsFlyerLib.shared logEvent:name withValues:values];
        }
    } else {
        [AppsFlyerLib.shared logEventWithEventName:name eventValues:paramsDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if (error) {
                NSLog(@"AppsFlyerLib-event-error");
            } else {
                NSLog(@"AppsFlyerLib-event-success");
            }
        }];
    }
}

- (void)trailAfSendEventWithName:(NSString *)name value:(NSString *)valueStr
{
    NSDictionary *paramsDic = [self trailJsonToDicWithJsonString:valueStr];
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.trailGetUserDefaultKey];
    if ([trailConvertToLowercase(name) isEqualToString:trailConvertToLowercase(adsDatas[24])] || [trailConvertToLowercase(name) isEqualToString:trailConvertToLowercase(adsDatas[27])]) {
        id am = paramsDic[adsDatas[26]];
        NSString *cur = paramsDic[adsDatas[14]];
        if (am && cur) {
            double pp = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: @(pp),
                adsDatas[17]: cur
            };
            [AppsFlyerLib.shared logEvent:name withValues:values];
        }
    } else {
        [AppsFlyerLib.shared logEventWithEventName:name eventValues:paramsDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if (error) {
                NSLog(@"AppsFlyerLib-event-error");
            } else {
                NSLog(@"AppsFlyerLib-event-success");
            }
        }];
    }
}

@end
