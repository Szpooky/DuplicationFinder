//
//  NSMutableDictionary+Duplication.m
//  DuplicationFinder
//
//  Created by Szpooky on 2018. 02. 23..
//  Copyright © 2018. Peter Sipos. All rights reserved.
//

#import "NSMutableDictionary+Duplication.h"
#import "NSURL+Duplication.h"

@implementation NSMutableDictionary (Duplication)

- (void)addURL:(NSURL*)url
{
    NSNumber* key = [NSNumber numberWithUnsignedInteger:[url fileSize]];
    
    NSMutableArray* array = self[key];
    
    if(!array)
    {
        array = [NSMutableArray array];
        
        self[key] = array;
    }
    
    [array addObject:url];
}

- (NSMutableArray*)allFiles
{
    NSMutableArray* retVal = [NSMutableArray array];
    
    for(NSNumber* fileSize in self.allKeys)
    {
        NSArray* array = self[fileSize];
        
        if(array.count > 0)
        {
            [retVal addObjectsFromArray:array];
        }
    }
    
    [retVal sortUsingComparator:^NSComparisonResult(NSURL*  _Nonnull obj1, NSURL*  _Nonnull obj2) {
        
        NSComparisonResult retValue = NSOrderedAscending;
        
        if([obj1 fileSize] == [obj2 fileSize])
        {
            retValue = NSOrderedSame;
        }
        if([obj1 fileSize] < [obj2 fileSize])
        {
            retValue = NSOrderedDescending;
        }
        
        return retValue;
    }];
    
    return retVal;
}

@end
