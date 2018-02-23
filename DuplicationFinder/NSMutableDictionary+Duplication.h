//
//  NSMutableDictionary+Duplication.h
//  DuplicationFinder
//
//  Created by Szpooky on 2018. 02. 23..
//  Copyright © 2018. Peter Sipos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Duplication)

- (void)addURL:(NSURL*)url;

- (NSMutableArray*)allFiles;

@end

/*
 Duplication Dictionary Format:
 - key: NSNumber (fileSize)
 - object: NSMutableArray<NSURL*>*
*/
