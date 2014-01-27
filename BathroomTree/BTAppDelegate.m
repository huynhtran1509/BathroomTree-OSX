//
//  BTAppDelegate.m
//  BathroomTree
//
//  Created by Trung Tran on 1/25/14.
//  Copyright (c) 2014 WillowTreeApps, Inc. All rights reserved.
//

#import "BTAppDelegate.h"
#import "NSUserDefaults+BathroomTree.h"
#import "BTStatusItemView.h"
#import "BTBathroomManager.h"

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

@end

@implementation BTAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSUserDefaults standardUserDefaults] registerApplicationDefaults];
    [self setupPollItems];
    [self setupStatusItem];
    [self setupMenuItemActions];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bathroomManagerDidUpdateStateNotification:)
                                                 name:BTBathroomManagerDidUpdateStatusNotification
                                               object:nil];
    
    [[BTBathroomManager defaultManager] startPolling];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [[BTBathroomManager defaultManager] stopPolling];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)bathroomManagerDidUpdateStateNotification:(NSNotification *)notification
{
    BTBathroomManager *manager = [notification object];
    
    if ([manager error])
    {
        [[self descriptionItem] setTitle:@"Error Connecting to Server"];
    }
    else
    {
        NSArray *availableBathrooms = [manager availableBathrooms];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([availableBathrooms count] &&
            [defaults notificationPreference] != BTNotificationPreferenceNone &&
            [availableBathrooms count] >= [defaults notificationPreference])
        {
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = @"Vacant Bathroom!";
            notification.informativeText = [BTStatusItemView bathroomDescriptionText:[availableBathrooms count]];
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
            [defaults setNotificationPreference:BTNotificationPreferenceNone];
            [self setNotifyItemsToZero];
        }
    }
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self setPollItems:@[[self poll5Item], [self poll15Item], [self poll30Item]]];
    
    for (NSMenuItem *item in [self pollItems])
    {
        if ([item tag] == (NSInteger)[defaults pollingInterval])
        {
            [item setState:NSOnState];
        }
        [item setTarget:self];
        [item setAction:@selector(pollItemSelected:)];
    }
}

- (void)setupMenuItemActions
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self setNotifyItems:@[[self notify1Item], [self notify2Item], [self notify3Item]]];
    
    for (NSMenuItem *item in [self notifyItems])
    {
        if ([item tag] == (NSInteger)[defaults notificationPreference])
        {
            [item setState:NSOnState];
        }
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
        [[BTBathroomManager defaultManager] setPollingInterval:[menuItem tag]];
    }
}

- (void)notifyMe:(NSMenuItem *)menuItem
{
    NSInteger oldState = [menuItem state];
    
    if (oldState == NSOffState)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setNotificationPreference:[menuItem tag]];
        [self setNotifyItemsToZero];
        [menuItem setState:NSOnState];
    }
    else
    {
        [menuItem setState:NSOffState];
    }
}

@end
