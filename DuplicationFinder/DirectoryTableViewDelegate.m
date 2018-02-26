//
//  DirectoryTableViewDelegate.m
//  DuplicationFinder
//
//  Created by Peter Sipos on 2018. 02. 25..
//  Copyright © 2018. Peter Sipos. All rights reserved.
//

#import "DirectoryTableViewDelegate.h"
#import "DuplicationEngine.h"
#import "DirectoryCell.h"
#import "AddDirectoryCell.h"

@interface DirectoryTableViewDelegate ()

@end

@implementation DirectoryTableViewDelegate

- (void)addDirectory
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    openPanel.directoryURL = [NSURL URLWithString:@"file:/Volumes/"];
    
    openPanel.canChooseFiles = YES;
    
    openPanel.allowsMultipleSelection = YES;
    
    openPanel.canChooseDirectories = YES;
    
    if([openPanel runModal] == NSFileHandlingPanelOKButton)
    {
        // avoid duplications in the search directories
        NSArray* array = [openPanel URLs];
        
        for(NSURL* url in array)
        {
            BOOL found = NO;
            
            for(NSURL* existingURL in self.engine.searchDirectories)
            {
                if([[url absoluteString] isEqualToString:[existingURL absoluteString]])
                {
                    found = YES;
                    
                    break;
                }
            }
            
            if(!found)
            {
                [self.engine.searchDirectories addObject:url];
            }
        }
    }
    
    [self.tableView reloadData];
}

- (void)clear
{
    [self.engine.searchDirectories removeAllObjects];
    
    [self.tableView reloadData];
}

#pragma mark - TableView Datasource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.engine.searchDirectories.count + 1;
}

#pragma mark tableView delegate
- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    if(row == 0)
    {
        static NSString * const cellViewIdentifier = @"addCell";
        
        AddDirectoryCell* cell = (AddDirectoryCell*)[tableView makeViewWithIdentifier:cellViewIdentifier owner:nil];
        
        return cell;
    }
    else
    {
        DirectoryCell* cell = nil;
        
        id item = self.engine.searchDirectories[row - 1];
        
        if([item isKindOfClass:[NSURL class]])
        {
            NSURL* url = (NSURL*)item;
            
            static NSString * const directoryCellViewIdentifier = @"directoryCell";
            
            cell = (DirectoryCell*)[tableView makeViewWithIdentifier:directoryCellViewIdentifier owner:nil];
            
            cell.textField.stringValue = [url absoluteString];
        }
        
        return cell;
    }
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 17.0;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    if(row == 0)
    {
        [self addDirectory];
    }
    else
    {
        [self.engine.searchDirectories removeObjectAtIndex:(row - 1)];
        
        [self.tableView reloadData];
    }
    
    return NO;
}

@end
