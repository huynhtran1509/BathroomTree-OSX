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
@property (nonatomic, readwrite, strong) IBOutlet NSMenuItem *versionItem;
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
@property (nonatomic, readwrite, strong) IBOutlet NSMenuItem *startLoginItem;
@property (nonatomic, readwrite, strong) NSArray *pollItems;

@end

@implementation BTAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSUserDefaults standardUserDefaults] registerApplicationDefaults];
    [self setupStatusItem];
    [self setupMenuItemActions];
    [self setupLoginItemAction];
    [self setupVersionItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bathroomManagerDidUpdateStateNotification:)
                                                 name:BTBathroomManagerDidUpdateStatusNotification
                                               object:nil];
    
    [[BTBathroomManager defaultManager] getBathrooms];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setupVersionItem
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [[self versionItem] setTitle:version];
}

- (void)setupLoginItemAction
{
    [[self startLoginItem] setTarget:self];
    [[self startLoginItem] setAction:@selector(toggleStartLoginItem:)];
    
    if ([self appIsLoginItem])
    {
        [[self startLoginItem] setState:NSOnState];
    }
}

- (void)toggleStartLoginItem:(NSMenuItem *)item
{
    switch ((NSCellStateValue)[item state])
    {
        case NSOffState:
            [self addAppAsLoginItem];
            [item setState:NSOnState];
            break;
            
        case NSOnState:
            [self deleteAppFromLoginItem];
            [item setState:NSOffState];
            break;
            
        default:
            break;
    }
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
    [statusItem setView:[self statusItemView]];
    [statusItem setMenu:[self menu]];
    [[self statusItemView] setStatusItem:statusItem];
    
    [self setStatusItem:statusItem];
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

- (void)addAppAsLoginItem
{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    
	// Create a reference to the shared file list.
    // We are adding it to the current user only.
    // If we want to add it all users, use
    // kLSSharedFileListGlobalLoginItems instead of
    //kLSSharedFileListSessionLoginItems
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems)
    {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, NULL, NULL);
		if (item)
        {
			CFRelease(item);
        }
	}
    
	CFRelease(loginItems);
}

- (BOOL)appIsLoginItem
{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems,
                                                            NULL);
    
	if (loginItems)
    {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
		for(int i = 0; i < [loginItemsArray count]; i++)
        {
			LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray
                                                                                 objectAtIndex:i];
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr)
            {
				NSString * urlPath = [(__bridge NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame)
                {
                    return YES;
				}
			}
		}
	}
    
    return NO;
}

- (void)deleteAppFromLoginItem
{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems,
                                                            NULL);
    
	if (loginItems)
    {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
		for(int i = 0; i < [loginItemsArray count]; i++)
        {
			LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray
                                                                        objectAtIndex:i];
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr)
            {
				NSString * urlPath = [(__bridge NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame)
                {
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
	}
}

@end
