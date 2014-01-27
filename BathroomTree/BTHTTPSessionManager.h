//
//  BTHTTPSessionManager.h
//  BathroomTree
//
//  Created by Trung Tran on 1/26/14.
//  Copyright (c) 2014 WillowTreeApps, Inc. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperation.h>

@interface BTHTTPSessionManager : NSObject

@property (nonatomic, readwrite) NSURL *baseURL;
@property (nonatomic, readwrite) NSOperationQueue *queue;

- (void)getBathrooms:(void(^)(id response))success failure:(void(^)(NSError *error))failure;
- (id)initWithBaseURL:(NSURL *)url;

@end
