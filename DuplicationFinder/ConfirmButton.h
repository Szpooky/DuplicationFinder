//
//  CofirmButton.h
//  DuplicationFinder
//
//  Created by Peter Sipos on 2018. 02. 25..
//  Copyright © 2018. Peter Sipos. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ConfirmButton : NSButton

@property (nonatomic, strong) NSString* confirmString;

@property (nonatomic, readonly) NSControlStateValue confirmState; // NSControlStateValueOff

@property (copy) void (^confirmationSuccessBlock)(void);

- (void)click;

@end
