//
//  DuplicationEngineData.h
//  DuplicationFinder
//
//  Created by Peter Sipos on 2017. 12. 05..
//  Copyright © 2017. Peter Sipos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DuplicationEngineData : NSObject

@property (nonatomic) CGFloat percent;

@property (nonatomic) NSUInteger numberOfDuplications;

@property (nonatomic) NSUInteger numberOfDirectories;

@property (nonatomic) NSUInteger numberOfFiles;

@property (nonatomic, strong)   NSMutableArray<NSMutableArray*>* result;

- (void)clear;

@end

