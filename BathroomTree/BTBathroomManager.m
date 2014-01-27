//
//  BTHTTPSessionManager.m
//  BathroomTree
//
//  Created by Trung Tran on 1/26/14.
//  Copyright (c) 2014 WillowTreeApps, Inc. All rights reserved.
//

#import "BTBathroomManager.h"
#import "BTBathroom.h"
#import "BTAppDelegate.h"
#import "NSUserDefaults+BathroomTree.h"

NSString * const BTBathroomManagerDidUpdateStatusNotification = @"com.willowtreeapps.ManagerDidUpdateStatus";

@interface BTBathroomManager ()

@property (nonatomic, readwrite, strong) NSTimer *pollingTimer;
@property (nonatomic, readwrite, getter = isPolling) BOOL polling;
@property (nonatomic, strong, readwrite) NSArray *bathrooms;
@property (nonatomic, strong, readwrite) NSError *error;

@end

@implementation BTBathroomManager

- (instancetype)init
{
#ifndef DEBUG_SERVER
    NSURL *baseURL = [NSURL URLWithString:@"http://sapling.willowtreeapps.com/"];
#else
    NSURL *baseURL = [NSURL URLWithString:@"http://localhost:8000/"];
#endif
    self = [super initWithBaseURL:baseURL];
    if (self)
    {
        // Init
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [self setPollingInterval:[defaults pollingInterval]];
    }
    return self;
}

+ (instancetype)defaultManager
{
    static BTBathroomManager *_defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultManager = [BTBathroomManager new];
    });
    return _defaultManager;
}

- (void)startPolling
{
    if (![self isPolling])
    {
        [self queueBathroomRequest];
    }
}

- (void)stopPolling
{
    [self setPolling:NO];
    [[self pollingTimer] invalidate];
    [self setPollingTimer:nil];
}

- (void)setPollingInterval:(NSTimeInterval)pollingInterval
{
    _pollingInterval = pollingInterval;
    [[NSUserDefaults standardUserDefaults] setPollingInterval:pollingInterval];
}

- (void)setBathrooms:(NSArray *)bathrooms
{
    [self willChangeValueForKey:@"bathrooms"];
    _bathrooms = bathrooms;
    [self didChangeValueForKey:@"bathrooms"];
    NSNotification *notification = [NSNotification notificationWithName:BTBathroomManagerDidUpdateStatusNotification
                                                                 object:self];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (NSArray *)availableBathrooms
{
    if ([[self bathrooms] count])
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"available = %@", @(YES)];
        return [[self bathrooms] filteredArrayUsingPredicate:predicate];
    }
    return @[];
}

- (void)queueBathroomRequest
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:[self pollingInterval]
                                                      target:self
                                                    selector:@selector(fetchBathrooms:)
                                                    userInfo:nil
                                                     repeats:NO];
    [self setPollingTimer:timer];
}

- (void)fetchBathrooms:(NSTimer *)timer
{
    __weak BTBathroomManager *__weak_self = self;
    [self getBathrooms:^(id response) {
        
        [__weak_self success:response];
        [__weak_self queueBathroomRequest];
        
    } failure:^(NSError *error) {
        
        [__weak_self failure:error];
        [__weak_self queueBathroomRequest];
        
    }];
}

- (void)success:(id)response
{
    [self setError:nil];
    if ([response isKindOfClass:[NSArray class]])
    {
        NSMutableArray *bathrooms = [NSMutableArray new];
        for (NSDictionary *attributes in response)
        {
            BTBathroom *bathroom = [[BTBathroom alloc] initWithAttributes:attributes];
            [bathrooms addObject:bathroom];
        }
        [self setBathrooms:bathrooms];
    }
}

- (void)failure:(NSError *)error
{
    [self setError:error];
    [self setBathrooms:@[]];
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
    
    [self GET:path
   parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          
          success(responseObject);
          
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          
          failure(error);
      }];
}
@end
