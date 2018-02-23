//
//  NSTableCellView.m
//  DuplicationFinder
//
//  Created by Peter Sipos on 2017. 12. 06..
//  Copyright © 2017. Peter Sipos. All rights reserved.
//

#import "TableCellView.h"

@implementation TableCellView

- (IBAction)trashButtonPushed:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:REMOVE_FILE_NOTIFICATION object:@(self.row)];
}

- (IBAction)quickLookButtonPushed:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:QUICK_LOOK_FILE_NOTIFICATION object:@(self.row)];
}

@end
