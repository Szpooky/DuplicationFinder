//
//  CofirmButton.m
//  DuplicationFinder
//
//  Created by Peter Sipos on 2018. 02. 25..
//  Copyright © 2018. Peter Sipos. All rights reserved.
//

#import "ConfirmButton.h"

@interface ConfirmButton()

@property (nonatomic, strong) NSString* tempString;

@property (nonatomic, strong) NSTimer* confirmButtonTimer;

@property (nonatomic) NSControlStateValue confirmState;

@property (nonatomic) NSInteger timeCounter;

@end


@implementation ConfirmButton

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.confirmState = NSControlStateValueOff;
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.confirmState = NSControlStateValueOff;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        self.confirmState = NSControlStateValueOff;
    }
    return self;
}

- (void)click
{
    [self.confirmButtonTimer invalidate];
    
    self.confirmButtonTimer = nil;
    
    self.timeCounter = 6;
    
    if(self.confirmState == NSControlStateValueOff)
    {
        self.confirmState = NSControlStateValueOn;
        
        self.tempString = self.title;
        
        self.title = [NSString stringWithFormat:@"%@ %@", self.confirmString, @(self.timeCounter > 0 ? self.timeCounter : 0)];
        
        self.confirmButtonTimer = [NSTimer scheduledTimerWithTimeInterval:0.6 repeats:YES block:^(NSTimer * _Nonnull timer) {
            
            self.timeCounter--;
            
            if(self.timeCounter == 0)
            {
                self.confirmState = NSControlStateValueOff;
                
                self.title = self.tempString;
                
                [self.confirmButtonTimer invalidate];
                
                self.confirmButtonTimer = nil;
                
                self.timeCounter = 6;
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.title = [NSString stringWithFormat:@"%@ %@", self.confirmString, @(self.timeCounter)];
                    
                });
            }
        }];
        
        [self.confirmButtonTimer fire];
    }
    else if(self.confirmState == NSControlStateValueOn)
    {
        self.confirmState = NSControlStateValueOff;
        
        self.title = self.tempString;
        
        if(self.confirmationSuccessBlock)
        {
            self.confirmationSuccessBlock();
        }
    }
}

@end
