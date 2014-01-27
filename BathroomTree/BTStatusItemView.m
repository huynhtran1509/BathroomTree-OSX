//
//  BTStatusItemView.m
//  BathroomTree
//
//  Created by Trung Tran on 1/26/14.
//  Copyright (c) 2014 WillowTreeApps, Inc. All rights reserved.
//

#import "BTStatusItemView.h"

@interface BTStatusItemView () <NSMenuDelegate>

@property (nonatomic, readwrite, weak) IBOutlet NSImageView *stemView;
@property (nonatomic, readwrite, weak) IBOutlet NSImageView *leaf1View;
@property (nonatomic, readwrite, weak) IBOutlet NSImageView *leaf2View;
@property (nonatomic, readwrite, weak) IBOutlet NSImageView *leaf3View;
@property (nonatomic, readwrite) BOOL selected;

@end

@implementation BTStatusItemView

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];

    if (self)
    {
        
     
    }
    
    return  self;
}

- (void)awakeFromNib
{
    [self configureWithObject:nil];
}

- (void)configureWithObject:(id)object
{
    BOOL toilet1Vacant = NO;
    BOOL toilet2Vacant = NO;
    BOOL toilet3Vacant = NO;
    
    if ([object count])
    {
        toilet1Vacant = [object[0][@"available"] boolValue];
        toilet2Vacant = [object[1][@"available"] boolValue];
        toilet3Vacant = [object[2][@"available"] boolValue];
    }
    
    BOOL anyToiletVacant = toilet1Vacant | toilet2Vacant | toilet3Vacant;
    
    [self updateVacantView:[self leaf1View] isVacant:toilet1Vacant];
    [self updateVacantView:[self leaf2View] isVacant:toilet2Vacant];
    [self updateVacantView:[self leaf3View] isVacant:toilet3Vacant];
    
    [self updateVacantView:[self stemView] isVacant:anyToiletVacant];
    
    NSInteger count = toilet1Vacant + toilet2Vacant + toilet3Vacant;
    NSString *text = [BTStatusItemView bathroomDescriptionText:count];
    
    [[self descriptionItem] setTitle:text];
    [self setToolTip:text];
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
}

@end
