//
//  DuplicationEngine.m
//  DuplicationFinder
//
//  Created by Peter Sipos on 2017. 12. 04..
//  Copyright © 2017. Peter Sipos. All rights reserved.
//

#import "DuplicationEngine.h"

@interface DuplicationEngine ()

@property (nonatomic, strong)   NSFileManager*              fileManager;

@property (nonatomic, strong)   NSMutableArray<NSURL*>*     allDirectories;

@property (nonatomic, strong)   NSMutableDictionary*        clasteredFiles;

@property (nonatomic, strong)   DuplicationEngineData*      engineData;

@property (nonatomic)           BOOL                        cancelled;

@property (nonatomic)           dispatch_queue_t            queue;

@end


@implementation DuplicationEngine

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.queue = dispatch_queue_create("[DUPLICATION.FINDER", DISPATCH_QUEUE_SERIAL);
        
        self.engineData = [DuplicationEngineData new];
        
        self.allDirectories = [NSMutableArray array];
        
        self.clasteredFiles = [NSMutableDictionary new];
        
        _searchDirectories = [NSMutableArray array];
        
        self.fileManager = [NSFileManager defaultManager];
        
        self.cancelled = NO;
    }
    return self;
}

- (void)startWithProgressBlock:(void (^)(DuplicationEngineData* data, BOOL completed))progressBlock
{
    dispatch_async(self.queue, ^{
       
        @autoreleasepool {
            
            [self buildFileStructureWithProgressBlock:progressBlock];
            
        }
    });
}

- (DuplicationEngineData*)cancel
{
    self.cancelled = YES;
    
    return self.engineData;
}

- (DuplicationEngineData*)clear
{
    [self.searchDirectories removeAllObjects];
    
    [self.engineData clear];
    
    [self.allDirectories removeAllObjects];
    
    [self.clasteredFiles removeAllObjects];
    
    self.cancelled = NO;
    
    return self.engineData;
}

#pragma mark Private processes

- (void)buildFileStructureWithProgressBlock:(void (^)(DuplicationEngineData* data, BOOL completed))progressBlock
{
    [self.engineData clear];
    
    [self.allDirectories removeAllObjects];
    
    [self.clasteredFiles removeAllObjects];
    
    self.cancelled = NO;
    
    //self.devices = [self.fileManager mountedVolumeURLsIncludingResourceValuesForKeys:@[NSURLFileSizeKey] options:0];
    
    if(progressBlock)
    {
        progressBlock(self.engineData, NO);
    }
    
    
    [self.allDirectories addObjectsFromArray:self.searchDirectories];
    
    self.engineData.numberOfDirectories = [self.allDirectories count];
    
    for(NSUInteger i = 0; i < self.engineData.numberOfDirectories ; i++) // directoryCounter will be changed in all cycle
    {
        if(self.cancelled)
        {
            break;
        }
        
        NSURL* path = self.allDirectories[i];
        
        NSError* error = nil;
        
        NSArray<NSURL*>* content = [self.fileManager contentsOfDirectoryAtURL:path includingPropertiesForKeys:@[NSURLFileSizeKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
        
        if(!error)
        {
            for(NSURL* element in content)
            {
                if(self.cancelled)
                {
                    break;
                }
                
                BOOL isDirectory;
                
                BOOL fileExistsAtPath = [[NSFileManager defaultManager] fileExistsAtPath:element.path isDirectory:&isDirectory];
                
                if(fileExistsAtPath)
                {
                    if(isDirectory)
                    {
                        [self.allDirectories addObject:element];
                        
                        self.engineData.numberOfDirectories++;
                    }
                    else
                    {
                        [self.clasteredFiles addURL:element];
                        
                        self.engineData.numberOfFiles++;
                    }
                }
            }
        }
        else
        {
            //NSLog(@"%@", error);
        }
        
        if(progressBlock)
        {
            progressBlock(self.engineData, NO);
        }
    }
    
    // Searching
    NSMutableArray* result = [NSMutableArray array];
    
    NSArray* allKeys = self.clasteredFiles.allKeys;
    
    NSUInteger clasterCount = 0;
    
    for(NSNumber* fileSize in allKeys)
    {
        if(self.cancelled)
        {
            break;
        }
        
        NSArray* array = self.clasteredFiles[fileSize];
        
        BOOL* duplicatedArray = (BOOL*) malloc (sizeof(BOOL) * array.count);
        
        memset(duplicatedArray, 0, array.count * sizeof(BOOL));
        
        for(NSUInteger i = 0; i < array.count ; i++)
        {
            if(self.cancelled)
            {
                break;
            }
            
            NSURL* firstURL = array[i];
            
            BOOL foundDuplication = NO;
            
            for(NSUInteger j = i + 1; j < array.count ; j++)
            {
                if(self.cancelled)
                {
                    break;
                }
                
                NSURL* secondURL = array[j];
                
                if(!duplicatedArray[j] && [firstURL isFileEqualAtURL:secondURL]) // Expensive method (isFileEqualAtURL)
                {
                    if(!foundDuplication)
                    {
                        foundDuplication = YES;
                        
                        [result addObject:@([firstURL fileSize])];
                        
                        [result addObject:firstURL];
                        
                        duplicatedArray[i] = YES;
                        
                        self.engineData.numberOfDuplications++;
                    }
                    
                    duplicatedArray[j] = YES;
                    
                    [result addObject:secondURL];
                }
            }
            
            self.engineData.percent = (CGFloat)clasterCount / (CGFloat)allKeys.count * 100.0;
            
            self.engineData.result = result;    // The new result
            
            if(progressBlock)
            {
                progressBlock(self.engineData, NO);
            }
        }
        
        if(duplicatedArray) free(duplicatedArray);
        
        clasterCount++;
    }
    
    if(progressBlock)
    {
        progressBlock(self.engineData, YES);
    }
}

@end
