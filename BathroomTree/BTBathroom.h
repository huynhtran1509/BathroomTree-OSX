//
//  BTBathroom.h
//  BathroomTree
//
//  Created by Joel Garrett on 1/27/14.
//  Copyright (c) 2014 WillowTreeApps, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTBathroom : NSObject

@property (nonatomic, assign, getter = isAvailable) BOOL available;
@property (nonatomic, assign) NSInteger roomNumber;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

@end
