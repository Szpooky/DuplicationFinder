//
//  DirectoryCell.m
//  DuplicationFinder
//
//  Created by Peter Sipos on 2018. 02. 25..
//  Copyright © 2018. Peter Sipos. All rights reserved.
//

#import "DirectoryCell.h"

@implementation DirectoryCell

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
    self.layer.borderColor = [NSColor grayColor].CGColor;
    
    self.layer.borderWidth = 1.0;
}

@end
