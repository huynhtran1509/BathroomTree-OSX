//
//  BTBathroom.m
//  BathroomTree
//
//  Created by Joel Garrett on 1/27/14.
//  Copyright (c) 2014 WillowTreeApps, Inc. All rights reserved.
//

#import "BTBathroom.h"

@implementation BTBathroom

- (instancetype)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    if (self)
    {
        [self setAvailable:[attributes[@"available"] boolValue]];
        [self setRoomNumber:[attributes[@"room"] integerValue]];
    }
    return self;
}

@end
