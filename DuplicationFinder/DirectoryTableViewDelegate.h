//
//  DirectoryTableViewDelegate.h
//  DuplicationFinder
//
//  Created by Peter Sipos on 2018. 02. 25..
//  Copyright © 2018. Peter Sipos. All rights reserved.
//

@import Cocoa;

@class DuplicationEngine;

@interface DirectoryTableViewDelegate : NSObject <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) DuplicationEngine* engine;

@property (nonatomic, weak) NSTableView* tableView;

- (void)addDirectory;

- (void)clear;

@end
