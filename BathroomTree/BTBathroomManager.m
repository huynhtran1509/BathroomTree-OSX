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

@interface BTBathroomManager () <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (nonatomic, readwrite, strong) NSTimer *pollingTimer;
@property (nonatomic, strong, readwrite) NSArray *bathrooms;
@property (nonatomic, strong, readwrite) NSURLConnection *urlConnection;
@property (nonatomic, strong, readwrite) NSError *error;

@end

@implementation BTBathroomManager

- (instancetype)init
{
    self = [super init];
    if (self) {
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

- (void)queueGetBathrooms
{
    if ([self pollingTimer] == nil)
    {
        NSLog(@"Queuing get bathrooms in 30 seconds.");
        [self setPollingTimer:[NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(getBathrooms) userInfo:nil repeats:NO]];
    }
}

- (void)getBathrooms
{
    [[self pollingTimer] invalidate];
    [self setPollingTimer:nil];
    
    NSLog(@"Getting bathroom statuses");
    
    NSURL *url = [NSURL URLWithString:@"https://api.spark.io/v1/devices/53ff6a065075535133131687/doors?access_token=8053e8e058b8f06fa88081e4922f7bd21fe6400a"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *result = [self parseJSONString:string];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                [self failure:error];
            }
            else
            {
                NSString *dataString = result[@"result"];
                
                if (dataString == nil)
                {
                    [self failure:[NSError errorWithDomain:@"bathroomtree" code:-999 userInfo:@{}]];
                }
                else
                {
                    NSArray *bathroomsArray = [self parseJSONString:dataString];
                    
                    [self success:bathroomsArray];
                    [self longPollBathrooms];
                }
            }
            
            [self setPollingTimer:nil];
            [self queueGetBathrooms];
        });
    });
}

- (void)longPollBathrooms
{
    if ([self urlConnection] == nil)
    {
        NSLog(@"Setting up long polling for bathroom statuses.");
        
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        NSURL* requestUrl = [NSURL URLWithString:@"https://api.spark.io/v1/events/bathroom-tree"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];
        [request setValue:@"Bearer 8053e8e058b8f06fa88081e4922f7bd21fe6400a" forHTTPHeaderField:@"Authorization"];
        
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
        [self setUrlConnection:connection];
        [connection start];
    }
}

- (id)parseJSONString:(NSString *)string
{
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    return result;
}

#pragma mark - Completion

- (void)success:(id)response
{
    [self setError:nil];
    if ([response isKindOfClass:[NSArray class]] && [response count] == 3)
    {
        NSMutableArray *bathrooms = [NSMutableArray new];
        for (NSInteger i = 0; i < [response count]; i++)
        {
            NSDictionary *bathroomDictionary = response[i];
            BTBathroom *bathroom = [BTBathroom new];
            [bathroom setRoomNumber:i];
            [bathroom setAvailable:[bathroomDictionary[@"occupied"] boolValue] == NO];
            [bathrooms addObject:bathroom];
        }
        
        [self setBathrooms:bathrooms];
        
        NSLog(@"Received bathroom data: %@ %@ %@",
              response[0][@"occupied"],
              response[1][@"occupied"],
              response[2][@"occupied"]);
    }
}

- (void)failure:(NSError *)error
{
    [self setError:error];
    [self setBathrooms:@[]];
    NSLog(@"Bathrooms failed");
    [self queueGetBathrooms];
}

#pragma mark - NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"Long poll received data.");
    
    [self setError:nil];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSInteger location = [string rangeOfString:@"{\"data\":\""].location;
    
    if (location != NSNotFound)
    {
        NSString *jsonString = [string substringFromIndex:location];
        NSDictionary *rootDictionary = [self parseJSONString:jsonString];
        NSString *dataString = rootDictionary[@"data"];
        
        if (rootDictionary && [rootDictionary isKindOfClass:[NSDictionary class]] && dataString)
        {
            NSArray *result = [self parseJSONString:dataString];
            
            if (rootDictionary && result)
            {
                [self success:result];
            }
        }
        else
        {
            NSLog(@"Bad response: %@", string);
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self setUrlConnection:nil];
    [self failure:error];
}

@end
