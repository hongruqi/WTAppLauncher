//
//  Test2.m
//  WTAppLauncher_Example
//
//  Created by hongru on 2018/4/23.
//  Copyright © 2018年 lbrsilva-allin. All rights reserved.
//

#import "Test2.h"

@implementation Test2
+ (void)load
{
    [self register];
}

- (void)start{
    NSLog(@"Test2 start");
}

- (NSInteger)priority
{
    return 2;
}

- (WTLauncherInQueue)inQueue
{
    return WTLauncherInQueue_ConcurrentQueue;
}
@end
