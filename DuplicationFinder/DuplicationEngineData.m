//
//  DuplicationEngineData.m
//  DuplicationFinder
//
//  Created by Peter Sipos on 2017. 12. 05..
//  Copyright © 2017. Peter Sipos. All rights reserved.
//

#import "DuplicationEngineData.h"
#import "NSURL+Duplication.h"

@implementation DuplicationEngineData

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self clear];
    }
    return self;
}

- (void)clear
{
    self.percent = 0;
    
    self.numberOfDuplications = 0;
    
    self.numberOfDirectories = 0;
    
    self.numberOfFiles = 0;
    
    self.result = [NSMutableArray array];
}

- (void)sortingResult
{
    NSMutableArray* tempResult = [NSMutableArray array];
    
    NSMutableArray<NSURL*>* section = nil;
    
    for(id element in self.result)
    {
        if([element isKindOfClass:[NSNumber class]])
        {
            section = [NSMutableArray array];
            
            [tempResult addObject:section];
        }
        else if([element isKindOfClass:[NSURL class]])
        {
            [section addObject:element];
        }
    }
    
    [tempResult sortUsingComparator:^NSComparisonResult(NSMutableArray<NSURL*>*  _Nonnull obj1, NSMutableArray<NSURL*>*  _Nonnull obj2) {
        
        NSComparisonResult retValue = NSOrderedAscending;
        
        if([[obj1 firstObject] fileSize] == [[obj2 firstObject] fileSize])
        {
            retValue = NSOrderedSame;
        }
        if([[obj1 firstObject] fileSize] < [[obj2 firstObject] fileSize])
        {
            retValue = NSOrderedDescending;
        }
        
        return retValue;
    }];
    
    self.result = [NSMutableArray new];
    
    for(NSMutableArray<NSURL*>* array in tempResult)
    {
        [self.result addObject:@([[array firstObject] fileSize])];
        
        for(NSURL* url in array)
        {
            [self.result addObject:url];
        }
    }
}

@end
