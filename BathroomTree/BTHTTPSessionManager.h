//
//  BTHTTPSessionManager.h
//  BathroomTree
//
//  Created by Trung Tran on 1/26/14.
//  Copyright (c) 2014 WillowTreeApps, Inc. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface BTHTTPSessionManager : AFHTTPSessionManager

- (void)getBathrooms:(void(^)(id response))success failure:(void(^)(NSError *error))failure;

@end
