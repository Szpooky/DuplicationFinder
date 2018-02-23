//
//  TableViewCellHeader.m
//  DuplicationFinder
//
//  Created by Peter Sipos on 2017. 12. 06..
//  Copyright © 2017. Peter Sipos. All rights reserved.
//

#import "TableViewCellHeader.h"

@interface TableViewCellHeader ()

@property (weak) IBOutlet NSTextField *headerTextField;

@end

@implementation TableViewCellHeader

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    NSBezierPath* bezierPath = [NSBezierPath bezierPathWithRect:dirtyRect];
    
    NSColor* fillColor = [NSColor colorWithRed:0.7 green:0.7 blue:0.5 alpha:1.0];
    
    [fillColor set];
    
    [bezierPath fill];
}

@end
