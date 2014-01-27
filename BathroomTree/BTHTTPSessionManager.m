//
//  BTHTTPSessionManager.m
//  BathroomTree
//
//  Created by Trung Tran on 1/26/14.
//  Copyright (c) 2014 WillowTreeApps, Inc. All rights reserved.
//

#import "BTHTTPSessionManager.h"
#import "BTAppDelegate.h"

@implementation BTHTTPSessionManager

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self)
    {
        [self setResponseSerializer:[AFJSONResponseSerializer serializer]];
    }
    
    return self;
}

- (void)getBathrooms:(void(^)(id response))success failure:(void(^)(NSError *error))failure
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
#ifndef DEBUG_SERVER
    NSString *path = @"bathroom/";
#else
    NSString *path = @"bathrooms.json";
#endif
    
    [self GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        success(responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        failure(error);
        
    }];
}
@end
