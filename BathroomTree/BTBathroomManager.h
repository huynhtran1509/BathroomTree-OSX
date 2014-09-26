//
//  BTBathroomManager.h
//  BathroomTree
//
//  Created by Trung Tran on 1/26/14.
//  Copyright (c) 2014 WillowTreeApps, Inc. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperationManager.h>

FOUNDATION_EXPORT NSString * const BTBathroomManagerDidUpdateStatusNotification;

@class BTBathroom;

@interface BTBathroomManager : NSObject

@property (nonatomic, strong, readonly) NSArray *bathrooms;
@property (nonatomic, strong, readonly) NSArray *availableBathrooms;
@property (nonatomic, strong, readonly) NSError *error;

+ (instancetype)defaultManager;

- (void)getBathrooms;

@end
