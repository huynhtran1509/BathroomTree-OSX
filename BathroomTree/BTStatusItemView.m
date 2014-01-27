//
//  BTStatusItemView.m
//  BathroomTree
//
//  Created by Trung Tran on 1/26/14.
//  Copyright (c) 2014 WillowTreeApps, Inc. All rights reserved.
//

#import "BTStatusItemView.h"
#import "BTBathroomManager.h"
#import "BTBathroom.h"

@interface BTStatusItemView () <NSMenuDelegate>

@property (nonatomic, readwrite, weak) IBOutlet NSImageView *stemView;
@property (nonatomic, readwrite, weak) IBOutlet NSImageView *leaf1View;
@property (nonatomic, readwrite, weak) IBOutlet NSImageView *leaf2View;
@property (nonatomic, readwrite, weak) IBOutlet NSImageView *leaf3View;
@property (nonatomic, readwrite) BOOL selected;

@end

@implementation BTStatusItemView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        BTBathroomManager *manager = [BTBathroomManager defaultManager];
        [self configureWithBathrooms:[manager bathrooms]];
    }
    return self;
}

- (void)configureWithBathrooms:(NSArray *)bathrooms
{
    if ([bathrooms count] != 3)
    {
        [self updateVacantView:[self leaf1View] isVacant:NO];
        [self updateVacantView:[self leaf2View] isVacant:NO];
        [self updateVacantView:[self leaf3View] isVacant:NO];
        [self updateVacantView:[self stemView] isVacant:NO];
        
        NSString *text = [BTStatusItemView bathroomDescriptionText:0];
        [[self descriptionItem] setTitle:text];
        [self setToolTip:text];
    }
    else
    {
        [self updateVacantView:[self leaf1View]
                      isVacant:[bathrooms[0] isAvailable]];
        [self updateVacantView:[self leaf2View]
                      isVacant:[bathrooms[1] isAvailable]];
        [self updateVacantView:[self leaf3View]
                      isVacant:[bathrooms[2] isAvailable]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"available = %@", @(YES)];
        NSArray *availableBathrooms = [bathrooms filteredArrayUsingPredicate:predicate];
        [self updateVacantView:[self stemView]
                      isVacant:([availableBathrooms count])];
        
        NSString *text = [BTStatusItemView bathroomDescriptionText:([availableBathrooms count])];
        [[self descriptionItem] setTitle:text];
        [self setToolTip:text];
    }
}

+ (NSString *)bathroomDescriptionText:(NSInteger)count
{
    NSString *text = @"No Bathrooms are Available";
    
    if (count == 1)
    {
        text = @"1 Bathroom is Available";
    }
    else if (count)
    {
        text = [NSString stringWithFormat:@"%li Bathrooms are Available", (long)count];
    }
    
    return text;
}

- (void)updateVacantView:(NSView *)vacantView isVacant:(BOOL)isVacant
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:1.0];
    
    if (isVacant)
    {
        [[vacantView animator] setAlphaValue:1.0];
    }
    else
    {
        [[vacantView animator] setAlphaValue:0.0];
    }
    
    [NSAnimationContext endGrouping];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [self setSelected:YES];
    [self setNeedsDisplay:YES];
    
    [[self statusItem] popUpStatusItemMenu:[[self statusItem] menu]];
    [[[self statusItem] menu] setDelegate:self];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [self setSelected:NO];
    [self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)menu
{
    [self setSelected:NO];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    
     // set view background color
     if ([self selected])
     {
         [[NSColor selectedMenuItemColor] setFill];
     }
     else
     {
         [[NSColor clearColor] setFill];
     }
     
     NSRectFill(dirtyRect);
}

@end
