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
@property (nonatomic, readwrite, getter = isPolling) BOOL polling;
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

- (void)getBathrooms
{
    NSLog(@"Getting bathroom statuses");
    
    NSURL *url = [NSURL URLWithString:@"https://api.spark.io/v1/devices/53ff6a065075535133131687/doors?access_token=db04e1b5a6b6b0e2341d89369a49c15bd6b1b414"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *result = [self parseJSONString:string];
    
    if (error)
    {
        [self failure:error];
    }
    else
    {
        NSString *dataString = result[@"result"];
        NSArray *bathroomsArray = [self parseJSONString:dataString];
        
        [self success:bathroomsArray];
        [self pollBathrooms];
    }
}

- (void)pollBathrooms
{
    NSLog(@"Setting up long polling for bathroom statuses.");
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSURL* requestUrl = [NSURL URLWithString:@"https://api.spark.io/v1/events/bathroom-tree"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];
    [request setValue:@"Bearer db04e1b5a6b6b0e2341d89369a49c15bd6b1b414" forHTTPHeaderField:@"Authorization"];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [self setUrlConnection:connection];
    [connection start];
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
    NSLog(@"Bathrooms failed, restarting in 10 seconds");
    [self performSelector:@selector(getBathrooms) withObject:nil afterDelay:10.0];
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
        NSArray *result = [self parseJSONString:dataString];
        
        
        if (rootDictionary && result)
        {
            [self success:result];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self failure:error];
}

@end
