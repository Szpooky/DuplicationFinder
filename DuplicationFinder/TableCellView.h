//
//  NSTableCellView.h
//  DuplicationFinder
//
//  Created by Peter Sipos on 2017. 12. 06..
//  Copyright © 2017. Peter Sipos. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define REMOVE_FILE_NOTIFICATION @"REMOVE_FILE_NOTIFICATION"

#define QUICK_LOOK_FILE_NOTIFICATION @"QUICK_LOOK_FILE_NOTIFICATION"

@class IconLoaderOperation;

@interface TableCellView : NSTableCellView

@property (weak) IBOutlet NSImageView *iconImageView;

@property (weak) IBOutlet NSTextField *pathTextField;

@property (weak) IBOutlet NSButton *trashButton;

@property (nonatomic, weak) IconLoaderOperation* iconLoaderOperation;

@property (nonatomic) NSUInteger row;

@end
