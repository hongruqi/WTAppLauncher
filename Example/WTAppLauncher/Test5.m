//
//  Test5.m
//  WTAppLauncher_Example
//
//  Created by hongru on 2018/4/23.
//  Copyright © 2018年 lbrsilva-allin. All rights reserved.
//

#import "Test5.h"

@implementation Test5
+ (void)load
{
    [self register];
}

- (void)start{
    NSLog(@"Test5 start");
}

- (NSInteger)priority
{
    return 5;
}

- (WTLauncherInQueue)inQueue
{
    return WTLauncherInQueue_MainQueue;
}
@end
