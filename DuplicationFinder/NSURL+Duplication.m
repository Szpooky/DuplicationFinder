//
//  NSURL+Duplication.m
//  DuplicationFinder
//
//  Created by Peter Sipos on 2017. 12. 05..
//  Copyright © 2017. Peter Sipos. All rights reserved.
//

#import "NSURL+Duplication.h"

#define ICON_SIZE 48.0

static NSOperationQueue *createIconQueue = nil;

@implementation IconLoaderOperation

- (void)main
{
    if(!self.isCancelled && self.completion && self.url)
    {
        CGImageRef quickLookIcon = QLThumbnailImageCreate(NULL, (__bridge CFURLRef)self.url, CGSizeMake(ICON_SIZE, ICON_SIZE), (__bridge CFDictionaryRef)@{(id)kQLThumbnailOptionIconModeKey: (id)kCFBooleanTrue});
        
        if (quickLookIcon != NULL)
        {
            self.betterIcon = [[NSImage alloc] initWithCGImage:quickLookIcon size:NSMakeSize(ICON_SIZE, ICON_SIZE)];
            
            if(!self.isCancelled && self.completion)
            {
                self.completion(self);
            }
            
            CFRelease(quickLookIcon);
        }
    }
}

- (void)cancel
{
    [super cancel];
    
    self.completion = nil;
}

@end


@implementation NSURL (Duplication)

- (NSUInteger)fileSize
{
    NSUInteger retVal = 0;
    
    NSNumber* sizeObject;
    NSError* error;
    
    
    if([self getResourceValue:&sizeObject forKey:NSURLFileSizeKey error:&error])
    {
        if(!error)
        {
            retVal = [sizeObject unsignedIntegerValue];
        }
        else
        {
            NSLog(@"error: %@", error);
        }
    }
    
    return retVal;
}

- (BOOL)isFileEqualAtURL:(NSURL*)otherURL
{
    BOOL retVal = NO;
    
    if(self != otherURL)
    {
        NSUInteger size = [self fileSize];
        
        NSUInteger otherSize = [otherURL fileSize];
        
        if(size == otherSize)
        {
            NSUInteger minSize = 0.0; //1048576; // 1 MB
            
            if(size >= minSize)
            {
                retVal = [self contentsEqualToURL:otherURL];
            }
            else
            {
                // Skip. Ignorance. Silent brutality.
            }
        }
    }
    
    return retVal;
}

- (BOOL)isFileEqualSlowAtURL:(NSURL*)otherURL // Softly DEPRECATED
{
    BOOL retVal = NO;
    
    if(self != otherURL)
    {
        NSUInteger size = [self fileSize];
        
        NSUInteger otherSize = [otherURL fileSize];
        
        NSUInteger minimumSize = 0;
        
        if(size == otherSize && size >= minimumSize && otherSize >= minimumSize)
        {
            if([[NSFileManager defaultManager] contentsEqualAtPath:self.path andPath:otherURL.path])
            {
                retVal = YES;
            }
        }
    }
    
    return retVal;
}

- (IconLoaderOperation*)iconImageWithCompletionBlock:(void (^)(IconLoaderOperation* iconLoaderOperation))completionBlock
{
    IconLoaderOperation* retVal = [IconLoaderOperation new];
    
    retVal.url = self;
    
    retVal.quickIcon = [[NSWorkspace sharedWorkspace] iconForFile:[self path]];
    
    [retVal.quickIcon setSize:NSMakeSize(ICON_SIZE, ICON_SIZE)];
    
    retVal.completion = completionBlock;
    
    
    if(completionBlock)
    {
        if (!createIconQueue)
        {
            createIconQueue = [[NSOperationQueue alloc] init];
            [createIconQueue setMaxConcurrentOperationCount:1];
        }
        
        [createIconQueue addOperation:retVal];
    }
    
    return retVal;
}

- (NSString*)displayName
{
    return [[self path] lastPathComponent];
}

#pragma mark Helper Methods

- (BOOL)contentsEqualToURL:(NSURL*)url
{
    BOOL retVal = NO;
    
    FILE* file1 = fopen(self.path.UTF8String, "r");
    
    FILE* file2 = fopen(url.path.UTF8String, "r");
    
    
    if(file1 && file2 && url)
    {
        NSUInteger fileSize = [self fileSize];
        
        NSUInteger minimumFileSize = 4096;
        
        if(fileSize < minimumFileSize)
        {
            unsigned char* buffer1 = (unsigned char*) malloc (sizeof(unsigned char) * fileSize);
            
            unsigned char* buffer2 = (unsigned char*) malloc (sizeof(unsigned char) * fileSize);
            
            memset(buffer1, 0, fileSize * sizeof(unsigned char));
            
            memset(buffer2, 0, fileSize * sizeof(unsigned char));
            
            fread(buffer1, fileSize, sizeof(unsigned char), file1);
            
            fread(buffer2, fileSize, sizeof(unsigned char), file2);
            
            BOOL found = NO;
            
            for(NSUInteger i = 0 ; i < fileSize ; i++)
            {
                if(buffer1[i] != buffer2[i])
                {
                    found = YES;
                    break;
                }
            }
            
            if(!found)
            {
                retVal = YES;
            }
            
            free(buffer1);
            
            free(buffer2);
        }
        else
        {
            long footprintInBytes = 16;
            
            NSUInteger allSteps = (NSUInteger)sqrt((double)fileSize);
            
            NSUInteger bufferSizeInBytes = footprintInBytes * allSteps;
            
            unsigned char* buffer1 = (unsigned char*) malloc (sizeof(unsigned char) * bufferSizeInBytes);
            
            unsigned char* buffer2 = (unsigned char*) malloc (sizeof(unsigned char) * bufferSizeInBytes);
            
            memset(buffer1, 0, bufferSizeInBytes * sizeof(unsigned char));
            
            memset(buffer2, 0, bufferSizeInBytes * sizeof(unsigned char));
            
            for(long i = 0 ; i < allSteps ; i ++)
            {
                if (fseek(file1, i * footprintInBytes, SEEK_SET) == 0)
                {
                    fread(&buffer1[i * footprintInBytes], footprintInBytes, sizeof(unsigned char), file1);
                }
                
                if((i + 1) * footprintInBytes * sizeof(unsigned char) >= fileSize)
                {
                    break;
                }
            }
            
            for(long i = 0 ; i < allSteps ; i ++)
            {
                if (fseek(file2, i * footprintInBytes, SEEK_SET) == 0)
                {
                    fread(&buffer2[i * footprintInBytes], footprintInBytes, sizeof(unsigned char), file2);
                }
                
                if((i + 1) * footprintInBytes * sizeof(unsigned char) >= fileSize)
                {
                    break;
                }
            }
            
            BOOL found = NO;
            
            for(NSUInteger i = 0 ; i < bufferSizeInBytes ; i++)
            {
                if(buffer1[i] != buffer2[i])
                {
                    found = YES;
                    break;
                }
            }
            
            if(!found)
            {
                retVal = YES;
            }
            
            free(buffer1);
            
            free(buffer2);
        }
    }
    
    if(file1) fclose(file1);
    
    if(file2) fclose(file2);
    
    return retVal;
}

#pragma mark QLPreviewItem delegate

- (NSURL*)previewItemURL
{
    return self;
}

- (NSString*)previewItemTitle
{
    return [self displayName];
}

@end
