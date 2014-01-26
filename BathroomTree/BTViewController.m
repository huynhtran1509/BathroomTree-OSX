//
//  BTViewController.m
//  BathroomTree
//
//  Created by Trung Tran on 1/25/14.
//  Copyright (c) 2014 WillowTreeApps, Inc. All rights reserved.
//

#import "BTViewController.h"
#import "BTStatusItemView.h"

@interface BTViewController ()

@property (nonatomic, readwrite, strong) NSStatusItem *statusItem;
@property (nonatomic, readwrite, strong) NSUserNotification *notification;
@property (nonatomic, readwrite, strong) IBOutlet BTStatusItemView *statusItemView;
@property (nonatomic, readwrite, strong) IBOutlet NSMenu *menu;

@end

@implementation BTViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
    }
    
    return self;
}

- (void)loadView
{
    [super loadView];

}

- (void)setMenu:(NSMenu *)menu
{
    _menu = menu;
    [[self statusItem] setMenu:menu];
}

@end
