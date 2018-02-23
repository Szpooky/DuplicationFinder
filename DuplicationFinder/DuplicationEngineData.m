//
//  DuplicationEngineData.m
//  DuplicationFinder
//
//  Created by Peter Sipos on 2017. 12. 05..
//  Copyright © 2017. Peter Sipos. All rights reserved.
//

#import "DuplicationEngineData.h"

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

@end

