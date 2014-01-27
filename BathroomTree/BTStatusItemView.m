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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    BTBathroomManager *manager = [BTBathroomManager defaultManager];
    [self configureWithBathrooms:[manager bathrooms]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bathroomManagerDidUpdateStateNotification:)
                                                 name:BTBathroomManagerDidUpdateStatusNotification
                                               object:nil];
}

- (void)bathroomManagerDidUpdateStateNotification:(NSNotification *)notification
{
    BTBathroomManager *manager = [notification object];
    [self configureWithBathrooms:[manager bathrooms]];
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
    CGFloat alpha = (isVacant) ? 1.0 : 0.0;
    if (isVacant)
    {
        [vacantView setHidden:NO];
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:1.0];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        
        [vacantView setHidden:!isVacant];
        
    }];
    
    [[vacantView animator] setAlphaValue:alpha];

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
    [[self statusItem] drawStatusBarBackgroundInRect:dirtyRect
                                       withHighlight:[self selected]];
}

@end
