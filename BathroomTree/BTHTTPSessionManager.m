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
    self = [super init];
    
    if (self)
    {
        [self setBaseURL:url];
        [self setQueue:[NSOperationQueue new]];
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
    
    path = [[[self baseURL] absoluteString] stringByAppendingString:path];
    
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setResponseSerializer:[AFJSONResponseSerializer serializer]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure(error);
    }];
    
    [[self queue] addOperation:operation];
}
@end
