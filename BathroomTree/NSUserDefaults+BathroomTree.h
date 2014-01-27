//
//  NSUserDefaults+BathroomTree.h
//  BathroomTree
//
//  Created by Joel Garrett on 1/27/14.
//  Copyright (c) 2014 WillowTreeApps, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const BTUserDefaultsKeyPollingInterval;
FOUNDATION_EXPORT NSString * const BTUserDefaultsKeyNotificationPreference;

typedef NS_ENUM(NSInteger, BTNotificationPreference)
{
    BTNotificationPreferenceNone,
    BTNotificationPreferenceOneAvailable,
    BTNotificationPreferenceTwoAvailable,
    BTNotificationPreferenceAllAvailable,
};

@interface NSUserDefaults (BathroomTree)

@property (nonatomic, assign) NSTimeInterval pollingInterval;
@property (nonatomic, assign) BTNotificationPreference notificationPreference;

- (void)registerApplicationDefaults;

@end
