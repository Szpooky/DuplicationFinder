//
//  DuplicationEngine.h
//  DuplicationFinder
//
//  Created by Peter Sipos on 2017. 12. 04..
//  Copyright © 2017. Peter Sipos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSURL+Duplication.h"
#import "NSMutableDictionary+Duplication.h"
#import "DuplicationEngineData.h"

@interface DuplicationEngine : NSObject

@property (nonatomic, readonly)   NSMutableArray<NSURL*>* searchDirectories;    // Fill up to use

- (void)startWithProgressBlock:(void (^)(DuplicationEngineData* data, BOOL completed))progressBlock;

- (BOOL)isRunning;

- (DuplicationEngineData*)cancel;

- (DuplicationEngineData*)clear;

@end
