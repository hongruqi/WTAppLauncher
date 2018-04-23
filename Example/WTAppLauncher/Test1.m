//
//  Test1.m
//  WTAppLauncher_Example
//
//  Created by hongru on 2018/4/23.
//  Copyright © 2018年 lbrsilva-allin. All rights reserved.
//

#import "Test1.h"

@implementation Test1

+ (void)load
{
    [self register];
}

- (void)start{
    NSLog(@"Test1 start");
}

- (NSInteger)priority
{
    return 0;
}

- (WTLauncherInQueue)inQueue
{
    return WTLauncherInQueue_MainQueue;
}

@end
