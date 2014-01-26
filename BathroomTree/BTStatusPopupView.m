//
//  BTStatusPopupView.m
//  BathroomTree
//
//  Created by Trung Tran on 1/25/14.
//  Copyright (c) 2014 WillowTreeApps, Inc. All rights reserved.
//

#import "BTStatusPopupView.h"

@interface BTStatusPopupView ()

@property (nonatomic, readwrite, strong) NSStatusItem *statusItem;
@property (nonatomic, readwrite, strong) NSImage *image;
@property (nonatomic, readwrite, strong) NSImage *alternateImage;
@property (nonatomic, readwrite, strong) NSImageView *imageView;
@property (nonatomic, readwrite) BOOL active;
@property (nonatomic, readwrite, strong) NSTimer *timer;
@property (nonatomic, readwrite) BOOL occupied;

@end

@implementation BTStatusPopupView


- (id)initWithViewController:(NSViewController *)controller
                        menu:(NSMenu *)menu
{
    CGFloat height = [NSStatusBar systemStatusBar].thickness;
    CGFloat width = 22.0;
    
    self = [super initWithFrame:NSMakeRect(0, 0, width, height)];
    
    if (self)
    {
        NSImage *image = [NSImage imageNamed:@"occupied"];
        
        self.image = image;
        
        _imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, width, height)];
        [_imageView setImage:image];
        [self addSubview:_imageView];
        
        NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        [statusItem setHighlightMode:YES];
        [statusItem setView:self];
        [statusItem setMenu:menu];
        [self setStatusItem:statusItem];
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(test) userInfo:nil repeats:YES];
        [self setTimer:timer];
    }
    
    return self;
}

- (void)test
{
    _occupied = ![self occupied];
    
    if ([self occupied])
    {
        [self setImage:[NSImage imageNamed:@"occupied"]];
    }
    else
    {
        [self setImage:[NSImage imageNamed:@"vacant"]];
    }
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // set view background color
    if (_active) {
        [[NSColor selectedMenuItemColor] setFill];
    } else {
        [[NSColor clearColor] setFill];
    }
    NSRectFill(dirtyRect);
    
    // set image
    NSImage *image = _image;
    _imageView.image = image;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [self setActive:![self active]];
    [self setNeedsDisplay:YES];
    
    [_statusItem popUpStatusItemMenu:[_statusItem menu]];
}

@end
