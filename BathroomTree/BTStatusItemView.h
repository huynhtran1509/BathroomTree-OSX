//
//  BTStatusItemView.h
//  BathroomTree
//
//  Created by Trung Tran on 1/26/14.
//  Copyright (c) 2014 WillowTreeApps, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BTStatusItemView : NSView

@property (nonatomic, readwrite, weak) NSStatusItem *statusItem;
@property (nonatomic, readwrite, strong) IBOutlet NSMenuItem *descriptionItem;
@property (nonatomic, readwrite, strong) IBOutlet NSMenuItem *lastUpdatedItem;
@property (nonatomic, readwrite, strong) NSDateFormatter *dateFormatter;

- (void)configureWithBathrooms:(NSArray *)bathrooms;
+ (NSString *)bathroomDescriptionText:(NSInteger)count;

@end
