//
//  BTAppDelegate.m
//  BathroomTree
//
//  Created by Trung Tran on 1/25/14.
//  Copyright (c) 2014 WillowTreeApps, Inc. All rights reserved.
//

#import "BTAppDelegate.h"
#import "BTViewController.h"
#import "BTStatusItemView.h"
#import "BTHTTPSessionManager.h"

@interface BTAppDelegate ()

@property (nonatomic, readwrite, strong) NSStatusItem *statusItem;
@property (nonatomic, readwrite, strong) IBOutlet BTStatusItemView *statusItemView;
@property (nonatomic, readwrite, strong) IBOutlet NSMenu *menu;
@property (nonatomic, readwrite, strong) IBOutlet NSMenuItem *notify1Item;
@property (nonatomic, readwrite, strong) IBOutlet NSMenuItem *notify2Item;
@property (nonatomic, readwrite, strong) IBOutlet NSMenuItem *notify3Item;
@property (nonatomic, readwrite, strong) IBOutlet NSMenuItem *descriptionItem;
@property (nonatomic, readwrite, strong) IBOutlet NSMenuItem *pollingSubmenu;
@property (nonatomic, readwrite, strong) IBOutlet NSMenuItem *notifySubmenu;
@property (nonatomic, readwrite, strong) NSArray *notifyItems;

@property (nonatomic, readwrite, strong) IBOutlet NSMenuItem *poll5Item;
@property (nonatomic, readwrite, strong) IBOutlet NSMenuItem *poll15Item;
@property (nonatomic, readwrite, strong) IBOutlet NSMenuItem *poll30Item;
@property (nonatomic, readwrite, strong) NSArray *pollItems;

@property (nonatomic, readwrite, strong) BTHTTPSessionManager *sessionManager;
@property (nonatomic, readwrite, strong) NSTimer *timer;
@property (nonatomic, readwrite) NSInteger notifyCount;
@property (nonatomic, readwrite) NSTimeInterval pollSpeed;


@end

@implementation BTAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSURL *baseURL = [NSURL URLWithString:@"http://sapling.willowtreeapps.com/"];
    
    BTHTTPSessionManager *sessionManager = [[BTHTTPSessionManager alloc] initWithBaseURL:baseURL];
    [self setSessionManager:sessionManager];
    
    [self setupPollItems];
    [self setupStatusItem];
    [self setupMenuItemActions];
    
    [self pollItemSelected:[self poll5Item]];
    [self fetchBathrooms];
}

- (void)queueBathroomRequest
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:[self pollSpeed]
                                                      target:self
                                                    selector:@selector(fetchBathrooms)
                                                    userInfo:nil
                                                     repeats:NO];
    [self setTimer:timer];
}

- (void)fetchBathrooms
{
    [[self sessionManager] getBathrooms:^(id response) {
        
        [self success:response];
        [self queueBathroomRequest];
        
    } failure:^(NSError *error) {
        
        [self failure:error];
        [self queueBathroomRequest];
        
    }];
}

- (void)success:(id)response
{
    BOOL toilet1Vacant = [response[@"1"] boolValue];
    BOOL toilet2Vacant = [response[@"2"] boolValue];
    BOOL toilet3Vacant = [response[@"3"] boolValue];
    NSInteger count = toilet1Vacant + toilet2Vacant + toilet3Vacant;
    
    if ([self notifyCount] && count >= [self notifyCount])
    {
        [self setNotifyCount:0];
        [self setNotifyItemsToZero];
        
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"Vacant Bathroom!";
        notification.informativeText = [BTStatusItemView bathroomDescriptionText:count];
        
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
    
    [[self statusItemView] configureWithObject:response];
}

- (void)failure:(NSError *)error
{
    [[self statusItemView] configureWithObject:nil];
    [[self descriptionItem] setTitle:@"Error Connecting to Server"];
}

- (void)setupStatusItem
{
    NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setHighlightMode:YES];
    [statusItem setView:[self statusItemView]];
    [statusItem setMenu:[self menu]];
    [[self statusItemView] setStatusItem:statusItem];
    
    [self setStatusItem:statusItem];
}

- (void)setupPollItems
{
    [self setPollItems:@[[self poll5Item], [self poll15Item], [self poll30Item]]];
    
    for (NSMenuItem *item in [self pollItems])
    {
        [item setTarget:self];
        [item setAction:@selector(pollItemSelected:)];
    }
}

- (void)setupMenuItemActions
{
    [self setNotifyItems:@[[self notify1Item], [self notify2Item], [self notify3Item]]];
    
    for (NSMenuItem *item in [self notifyItems])
    {
        [item setTarget:self];
        [item setAction:@selector(notifyMe:)];
    }
}

- (void)setNotifyItemsToZero
{
    for (NSMenuItem *item in [self notifyItems])
    {
        [item setState:NSOffState];
    }
}

- (void)pollItemSelected:(NSMenuItem *)menuItem
{
    NSInteger oldState = [menuItem state];
    
    if (oldState == NSOffState)
    {
        for (NSMenuItem *item in [self pollItems])
        {
            [item setState:NSOffState];
        }
        [menuItem setState:NSOnState];
        [self setPollSpeed:[menuItem tag]];
    }
}

- (void)notifyMe:(NSMenuItem *)menuItem
{
    NSInteger oldState = [menuItem state];
    
    if (oldState == NSOffState)
    {
        [self setNotifyCount:[menuItem tag]];
        [self setNotifyItemsToZero];
        [menuItem setState:NSOnState];
    }
    else
    {
        [menuItem setState:NSOffState];
    }
}

@end
