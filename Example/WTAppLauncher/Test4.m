//
//  Test4.m
//  WTAppLauncher_Example
//
//  Created by hongru on 2018/4/23.
//  Copyright © 2018年 lbrsilva-allin. All rights reserved.
//

#import "Test4.h"

@implementation Test4
+ (void)load
{
    [self register];
}

- (void)start{
    NSLog(@"Test4 start");
}

- (NSInteger)priority
{
    return 4;
}

- (WTLauncherInQueue)inQueue
{
    return WTLauncherInQueue_ConcurrentQueue;
}
@end
