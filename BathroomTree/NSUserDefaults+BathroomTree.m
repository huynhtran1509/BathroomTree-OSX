//
//  NSUserDefaults+BathroomTree.m
//  BathroomTree
//
//  Created by Joel Garrett on 1/27/14.
//  Copyright (c) 2014 WillowTreeApps, Inc. All rights reserved.
//

#import "NSUserDefaults+BathroomTree.h"

NSString * const BTUserDefaultsKeyPollingInterval = @"com.willowtreeapps.PollingInterval";
NSString * const BTUserDefaultsKeyNotificationPreference = @"com.willowtreeapps.NotificationPreference";

@implementation NSUserDefaults (BathroomTree)

- (void)registerApplicationDefaults
{
    NSDictionary *defaults = @{BTUserDefaultsKeyPollingInterval: @(5.0),
                               BTUserDefaultsKeyNotificationPreference: @(BTNotificationPreferenceNone)};
    [self registerDefaults:defaults];
}

- (NSTimeInterval)pollingInterval
{
    return [self doubleForKey:BTUserDefaultsKeyPollingInterval];
}

- (void)setPollingInterval:(NSTimeInterval)pollingInterval
{
    [self setDouble:pollingInterval forKey:BTUserDefaultsKeyPollingInterval];
}

- (BTNotificationPreference)notificationPreference
{
    return [self integerForKey:BTUserDefaultsKeyNotificationPreference];
}

- (void)setNotificationPreference:(BTNotificationPreference)notificationPreference
{
    [self setInteger:notificationPreference forKey:BTUserDefaultsKeyNotificationPreference];
}

@end
