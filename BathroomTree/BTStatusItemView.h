//
//  BTStatusItemView.h
//  BathroomTree
//
//  Created by Trung Tran on 1/26/14.
//  Copyright (c) 2014 WillowTreeApps, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BTStatusItemView : NSView

@property (nonatomic, readwrite, strong) NSStatusItem *statusItem;
@property (nonatomic, readwrite, strong) IBOutlet NSMenuItem *descriptionItem;

- (void)configureWithBathrooms:(NSArray *)bathrooms;
+ (NSString *)bathroomDescriptionText:(NSInteger)count;

@end
