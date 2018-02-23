//
//  NSURL+Duplication.h
//  DuplicationFinder
//
//  Created by Peter Sipos on 2017. 12. 05..
//  Copyright © 2017. Peter Sipos. All rights reserved.
//

@import Cocoa;
@import Quartz; // Quartz framework provides the QLPreviewPanel public API

@interface IconLoaderOperation : NSOperation

@property (nonatomic, strong)   NSURL*      url;

@property (nonatomic, strong)   NSImage*    quickIcon;

@property (nonatomic, strong)   NSImage*    betterIcon;

@property (copy) void(^completion)(IconLoaderOperation* iconLoaderOperation);

@end


@interface NSURL (Duplication) <QLPreviewItem>

- (NSUInteger)fileSize;

- (NSString *)displayName;

- (IconLoaderOperation *)iconImageWithCompletionBlock:(void (^)(IconLoaderOperation* iconLoaderOperation))completionBlock;

- (BOOL)isFileEqualAtURL:(NSURL*)otherURL;

- (BOOL)isFileEqualSlowAtURL:(NSURL*)otherURL;

@end
