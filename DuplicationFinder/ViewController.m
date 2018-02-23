//
//  ViewController.m
//  DuplicationFinder
//
//  Created by Peter Sipos on 2017. 12. 04..
//  Copyright © 2017. Peter Sipos. All rights reserved.
//

#import "ViewController.h"
#import "DuplicationEngine.h"
#import "TableViewCellHeader.h"
#import "TableCellView.h"

@interface ViewController () <NSTableViewDataSource, NSTableViewDelegate, QLPreviewPanelDelegate, QLPreviewPanelDataSource>

@property (weak) IBOutlet NSProgressIndicator *progressBar;

@property (weak) IBOutlet NSButton *startNewButton;

@property (weak) IBOutlet NSButton *addButton;

@property (weak) IBOutlet NSButton *startButton;

@property (weak) IBOutlet NSButton *clearButton;

@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@property (weak) IBOutlet NSTextField *fileCounterTextField;

@property (nonatomic, strong) DuplicationEngine* engine;

@property (weak) IBOutlet NSTableView *tableView;

@property (nonatomic, strong) NSMutableArray* content;

@property (nonatomic, strong) QLPreviewPanel* previewPanel;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    self.content = [NSMutableArray new];
    
    
    self.tableView.delegate = self;
    
    self.tableView.dataSource = self;
    
    [self.tableView setDoubleAction:@selector(doubleClick)];
    
    self.progressIndicator.hidden = YES;
    
    self.engine = [DuplicationEngine new];
    
    DuplicationEngineData *data = [self.engine cancel];
    
    [self reloadDataWithEngineData:data completed:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeFileFromContentAtRow:) name:REMOVE_FILE_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quickLookFileFromContentAtRow:) name:QUICK_LOOK_FILE_NOTIFICATION object:nil];
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

#pragma mark - Actions

- (void)doubleClick
{
    NSInteger row = self.tableView.clickedRow;
    
    if(row > 0)
    {
        id cellContent = self.content[row];
        
        if([cellContent isKindOfClass:[NSURL class]])
        {
            NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
            
            NSString* path = [(NSURL*)cellContent path];
            
            if(path.length)
            {
                [workspace openFile:path];
            }
        }
    }
}

- (void)removeFileFromContentAtRow:(NSNotification*)info
{
    NSInteger row = [info.object integerValue];
    
    if(row > 0)
    {
        id cellContent = self.content[row];
        
        if([cellContent isKindOfClass:[NSURL class]])
        {
            NSString* path = [(NSURL*)cellContent path];
            
            if(path.length)
            {
                [[NSWorkspace sharedWorkspace] recycleURLs:@[cellContent] completionHandler:^(NSDictionary<NSURL *,NSURL *> * _Nonnull newURLs, NSError * _Nullable error) {
                    
                    if(error)
                    {
                        NSLog(@"%@", error);
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self.content removeObject:cellContent];
                            
                            // remove section if neccessary
                            id prevCellContent = (row > 0) ? self.content[row - 1] : nil;
                            
                            id nextCellContent = (row < self.content.count) ? self.content[row] : nil;
                            
                            if(prevCellContent && nextCellContent)
                            {
                                if([prevCellContent isKindOfClass:[NSNumber class]] && [nextCellContent isKindOfClass:[NSNumber class]])
                                {
                                    [self.content removeObject:prevCellContent];
                                }
                            }
                            else if(prevCellContent && [prevCellContent isKindOfClass:[NSNumber class]])
                            {
                                [self.content removeObject:prevCellContent];
                            }
                            else
                            {
                                NSLog(@"If you see that, RUN!");
                            }
                            
                            [self.tableView reloadData];
                        });
                    }
                }];
            }
        }
    }
}

- (void)quickLookFileFromContentAtRow:(NSNotification*)info
{
    NSInteger row = [info.object integerValue];
    
    if(row > 0)
    {
        id cellContent = self.content[row];
        
        if([cellContent isKindOfClass:[NSURL class]])
        {
            NSString* path = [(NSURL*)cellContent path];
            
            if(path.length)
            {
                [[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:@""];
            }
        }
    }
}

#pragma mark - Button Actions

- (IBAction)startNewButtonAction:(id)sender
{
    [self cancel];
    
    DuplicationEngineData *data = [self.engine clear];
    
    [self reloadDataWithEngineData:data completed:YES];
    
    [self.engine.searchDirectories removeAllObjects];
    
    [self.progressIndicator stopAnimation:nil];
    
    self.progressIndicator.hidden = YES;
    
    self.progressBar.doubleValue = 0.0;
}

- (IBAction)addButtonAction:(id)sender
{
    [self cancel];
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    openPanel.directoryURL = [NSURL URLWithString:@"file:/Volumes/"];
    
    openPanel.canChooseFiles = YES;
    
    openPanel.allowsMultipleSelection = YES;
    
    openPanel.canChooseDirectories = YES;
    
    if([openPanel runModal] == NSFileHandlingPanelOKButton)
    {
        [self.engine.searchDirectories addObjectsFromArray:[openPanel URLs]];
    }
}

- (IBAction)startButtonAction:(id)sender
{
    if(![self.engine isRunning])
    {
        self.progressIndicator.hidden = NO;
        
        [self.progressIndicator startAnimation:nil];
        
        [self.startButton setImage:[NSImage imageNamed:@"stop"]];
        
        [self.engine startWithProgressBlock:^(DuplicationEngineData *data, BOOL completed) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self reloadDataWithEngineData:data completed:completed];
                
            });
        }];
    }
    else
    {
        [self cancel];
    }
}

- (IBAction)clearButtonAction:(id)sender
{
    [self cancel];
    
    DuplicationEngineData *data = [self.engine clear];
    
    [self reloadDataWithEngineData:data completed:YES];
    
    [self.progressIndicator stopAnimation:nil];
    
    self.progressIndicator.hidden = YES;

    self.progressBar.doubleValue = 0.0;
}

- (void)cancel
{
    [self.startButton setImage:[NSImage imageNamed:@"play"]];
    
    DuplicationEngineData *data = [self.engine cancel];
    
    [self reloadDataWithEngineData:data completed:YES];
    
    [self.progressIndicator stopAnimation:nil];
    
    self.progressIndicator.hidden = YES;
}

#pragma mark - Presenter

- (void)reloadDataWithEngineData:(DuplicationEngineData*)data completed:(BOOL)completed
{
    self.fileCounterTextField.stringValue = [NSString stringWithFormat:@"Directories: %lu Files: %lu Duplications: %lu", data.numberOfDirectories, data.numberOfFiles, data.numberOfDuplications];
    
    self.progressBar.doubleValue = data.percent;
    
    if(completed)
    {
        [data sortingResult];
        
        // Create text version of result
        /*NSMutableString* resultString = [NSMutableString string];
        
        for(id item in data.result)
        {
            if([item isKindOfClass:[NSURL class]])
            {
                [resultString appendFormat:@"%@\n", [(NSURL*)item path]];
            }
        }
        
        [resultString appendFormat:@"\n"];*/
        
        [self.startButton setImage:[NSImage imageNamed:@"play"]];
        
        [self.engine cancel];
        
        [self.progressIndicator stopAnimation:nil];
        
        self.progressIndicator.hidden = YES;
        
        self.content = data.result;
        
        [self.tableView reloadData];
    }
}

#pragma mark - TableView Datasource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.content.count;
}

#pragma mark tableView delegate
- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    id item = self.content[row];
               
    if([item isKindOfClass:[NSURL class]])
    {
        static NSString * const cellViewIdentifier = @"cell";
        
        TableCellView* cell = (TableCellView*)[tableView makeViewWithIdentifier:cellViewIdentifier owner:nil];
        
        cell.row = row;
        
        cell.pathTextField.stringValue = [(NSURL*)item path];
        
        [cell.iconLoaderOperation cancel];
        
        cell.iconLoaderOperation = [(NSURL*)item iconImageWithCompletionBlock:^(IconLoaderOperation* iconLoaderOperation) {
            
            if(iconLoaderOperation.betterIcon)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    cell.iconImageView.image = iconLoaderOperation.betterIcon;
                    
                });
            }
        }];
        
        cell.iconImageView.image = cell.iconLoaderOperation.quickIcon;
        
        return cell;
    }
    else// header
    {
        static NSString * const cellViewIdentifier = @"header";
        
        TableViewCellHeader* cell = (TableViewCellHeader*)[tableView makeViewWithIdentifier:cellViewIdentifier owner:nil];
        
        double sizeDouble = (double)[item integerValue];
        
        NSString* amount = @"byte";
        
        if(sizeDouble / 1024.0 > 1.0)
        {
            sizeDouble /= 1024.0;
            
            amount = @"KB";
        }
        
        if(sizeDouble / 1024.0 > 1.0)
        {
            sizeDouble /= 1024.0;
            
            amount = @"MB";
        }
        
        if(sizeDouble / 1024.0 > 1.0)
        {
            sizeDouble /= 1024.0;
            
            amount = @"GB";
        }
        
        if(sizeDouble / 1024.0 > 1.0)
        {
            sizeDouble /= 1024.0;
            
            amount = @"TB";
        }
        
        cell.headerTextField.stringValue = [NSString stringWithFormat:@"%.2f %@", sizeDouble, amount];
        
        return cell;
    }
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    CGFloat retVal = 30; // header
    if([self.content[row] isKindOfClass:[NSURL class]])
    {
        retVal = 70;
    }
    
    return retVal;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    BOOL retVal = NO;
    
    if([self.content[row] isKindOfClass:[NSURL class]])
    {
        if ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible])
        {
            [[QLPreviewPanel sharedPreviewPanel] reloadData];
        }
        
        retVal = YES;
    }
    
    return retVal;
}

#pragma mark - Quick Look panel support

- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel
{
    return YES;
}

- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel
{
    // This document is now responsible of the preview panel
    // It is allowed to set the delegate, data source and refresh panel.
    //
    self.previewPanel = panel;
    panel.delegate = self;
    panel.dataSource = self;
}

- (void)endPreviewPanelControl:(QLPreviewPanel *)panel
{
    // This document loses its responsisibility on the preview panel
    // Until the next call to -beginPreviewPanelControl: it must not
    // change the panel's delegate, data source or refresh it.
    //
    self.previewPanel = nil;
}


#pragma mark - QLPreviewPanelDataSource

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel
{
    return 1;
}

- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index
{
    id <QLPreviewItem> retVal = nil;
    
    NSInteger row = self.tableView.selectedRow;
    
    if(row > 0 && row < self.content.count)
    {
        id cellContent = self.content[row];
        
        if([cellContent isKindOfClass:[NSURL class]])
        {
            retVal = cellContent;
        }
    }
    
    return retVal;
}


#pragma mark - QLPreviewPanelDelegate

- (BOOL)previewPanel:(QLPreviewPanel *)panel handleEvent:(NSEvent *)event
{
    // redirect all key down events to the table view
    if ([event type] == NSEventTypeKeyDown)
    {
        [self.tableView keyDown:event];
        return YES;
    }
    return NO;
}

// This delegate method provides the rect on screen from which the panel will zoom.
- (NSRect)previewPanel:(QLPreviewPanel *)panel sourceFrameOnScreenForPreviewItem:(id <QLPreviewItem>)item
{
    NSRect returnIconRect = NSZeroRect;
    NSInteger index = [self.content indexOfObject:item];
    if (index != NSNotFound)
    {
        NSRect iconRect = [self.tableView frameOfCellAtColumn:0 row:index];
        
        iconRect = CGRectMake(iconRect.origin.x, iconRect.origin.y, iconRect.size.height, iconRect.size.height);
        
        // Check that the icon rect is visible on screen.
        NSRect visibleRect = [self.tableView visibleRect];
        
        if (NSIntersectsRect(visibleRect, iconRect))
        {
            // Convert icon rect to screen coordinates.
            NSRect convertedRect = [self.tableView convertRect:iconRect toView:nil];
            convertedRect.origin = [self.tableView.window convertRectToScreen:convertedRect].origin;
            returnIconRect = convertedRect;
        }
    }
    return returnIconRect;
}

// this delegate method provides a transition image between the table view and the preview panel
//
- (id)previewPanel:(QLPreviewPanel *)panel transitionImageForPreviewItem:(id <QLPreviewItem>)item contentRect:(NSRect *)contentRect
{
    if([item isKindOfClass:[NSURL class]])
    {
        return [((NSURL*)item) iconImageWithCompletionBlock:nil].quickIcon;
    }
    else
    {
        return nil;
    }
}

@end
