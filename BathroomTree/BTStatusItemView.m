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

@property (nonatomic, readwrite, weak) IBOutlet NSImageView *bgView;
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
    [super awakeFromNib];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"M/dd/yy h:mm:ss a"];
    [self setDateFormatter:dateFormatter];
    
    BTBathroomManager *manager = [BTBathroomManager defaultManager];
    [self configureWithBathrooms:[manager bathrooms]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bathroomManagerDidUpdateStateNotification:)
                                                 name:BTBathroomManagerDidUpdateStatusNotification
                                               object:nil];
    
    [self updateImageViewsForLightOrDarkMode];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(updateImageViewsForLightOrDarkMode) name:@"AppleInterfaceThemeChangedNotification" object:nil];
}

- (void)updateImageViewsForLightOrDarkMode
{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:NSGlobalDomain];
    id style = [dict objectForKey:@"AppleInterfaceStyle"];
    BOOL darkModeOn = ( style && [style isKindOfClass:[NSString class]] && NSOrderedSame == [style caseInsensitiveCompare:@"dark"]);
    
    if (darkModeOn)
    {
        [[self bgView] setImage:[NSImage imageNamed:@"tree_background_dark"]];
        [[self leaf1View] setImage:[NSImage imageNamed:@"leaf_1_dark"]];
        [[self leaf2View] setImage:[NSImage imageNamed:@"leaf_2_dark"]];
        [[self leaf3View] setImage:[NSImage imageNamed:@"leaf_3_dark"]];
    }
    else
    {
        [[self bgView] setImage:[NSImage imageNamed:@"tree_background"]];
        [[self leaf1View] setImage:[NSImage imageNamed:@"leaf_1"]];
        [[self leaf2View] setImage:[NSImage imageNamed:@"leaf_2"]];
        [[self leaf3View] setImage:[NSImage imageNamed:@"leaf_3"]];
    }
}

- (void)bathroomManagerDidUpdateStateNotification:(NSNotification *)notification
{
    [[self lastUpdatedItem] setTitle:[NSString stringWithFormat:@"Updated %@", [[self dateFormatter] stringFromDate:[NSDate date]]]];
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

@end
