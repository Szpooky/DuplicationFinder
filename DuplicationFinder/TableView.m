//
//  TableView.m
//  DuplicationFinder
//
//  Created by Peter Sipos on 2017. 12. 06..
//  Copyright © 2017. Peter Sipos. All rights reserved.
//

#import "TableView.h"
@import Cocoa;
@import Quartz; // Quartz framework provides the QLPreviewPanel public API

@implementation TableView

- (void)keyDown:(NSEvent *)theEvent
{
    NSString *key = [theEvent charactersIgnoringModifiers];
    if ([key isEqual:@" "])    // Space key opens the preview panel.
    {
        [self togglePreviewPanel:self];
    }
    else
    {
        [super keyDown:theEvent];
    }
}

- (void)togglePreviewPanel:(id)previewPanel
{
    if ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible])
    {
        [[QLPreviewPanel sharedPreviewPanel] orderOut:nil];
    }
    else
    {
        [[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:nil];
    }
}


@end
