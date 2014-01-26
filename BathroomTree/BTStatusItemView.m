//
//  BTStatusItemView.m
//  BathroomTree
//
//  Created by Trung Tran on 1/26/14.
//  Copyright (c) 2014 WillowTreeApps, Inc. All rights reserved.
//

#import "BTStatusItemView.h"

@interface BTStatusItemView () <NSMenuDelegate>

@property (nonatomic, readwrite, weak) IBOutlet NSImageView *toiletVacantView;
@property (nonatomic, readwrite, weak) IBOutlet NSImageView *toiletOccupiedView;

@property (nonatomic, readwrite, weak) IBOutlet NSImageView *toilet1OccupiedView;
@property (nonatomic, readwrite, weak) IBOutlet NSImageView *toilet2OccupiedView;
@property (nonatomic, readwrite, weak) IBOutlet NSImageView *toilet3OccupiedView;

@property (nonatomic, readwrite, weak) IBOutlet NSImageView *toilet1VacantView;
@property (nonatomic, readwrite, weak) IBOutlet NSImageView *toilet2VacantView;
@property (nonatomic, readwrite, weak) IBOutlet NSImageView *toilet3VacantView;
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
    BOOL toilet1Vacant = [object[@"1"] boolValue];
    BOOL toilet2Vacant = [object[@"2"] boolValue];
    BOOL toilet3Vacant = [object[@"3"] boolValue];
    
    BOOL anyToiletVacant = toilet1Vacant | toilet2Vacant | toilet3Vacant;
    
    [self updateVacantView:[self toilet1VacantView] occupiedView:[self toilet1OccupiedView] isVacant:toilet1Vacant];
    [self updateVacantView:[self toilet2VacantView] occupiedView:[self toilet2OccupiedView] isVacant:toilet2Vacant];
    [self updateVacantView:[self toilet3VacantView] occupiedView:[self toilet3OccupiedView] isVacant:toilet3Vacant];
    
    [self updateVacantView:[self toiletVacantView] occupiedView:[self toiletOccupiedView] isVacant:anyToiletVacant];
    
    NSInteger count = toilet1Vacant + toilet2Vacant + toilet3Vacant;
    NSString *text = [BTStatusItemView bathroomDescriptionText:count];
    
    [[self descriptionItem] setTitle:text];
    [self setToolTip:text];
}

+ (NSString *)bathroomDescriptionText:(NSInteger)count
{
    NSString *text = @"No Bathrooms Available";
    
    if (count == 1)
    {
        text = @"1 Bathroom Available";
    }
    else if (count)
    {
        text = [NSString stringWithFormat:@"%li Bathrooms Available", (long)count];
    }
    
    return text;
}

- (void)updateVacantView:(NSView *)vacantView occupiedView:(NSView *)occupiedView isVacant:(BOOL)isVacant
{
    if (isVacant)
    {
        [vacantView setHidden:NO];
        [occupiedView setHidden:YES];
    }
    else
    {
        [vacantView setHidden:YES];
        [occupiedView setHidden:NO];
    }
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
    
    
    /*
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
     */
}

@end
