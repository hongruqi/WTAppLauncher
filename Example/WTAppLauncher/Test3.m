//
//  Test3.m
//  WTAppLauncher_Example
//
//  Created by hongru on 2018/4/23.
//  Copyright © 2018年 lbrsilva-allin. All rights reserved.
//

#import "Test3.h"

@implementation Test3
+ (void)load
{
    [self register];
}

- (void)start{
    NSLog(@"Test3 start");
}

- (NSInteger)priority
{
    return 3;
}

- (WTLauncherInQueue)inQueue
{
    return WTLauncherInQueue_MainQueue;
}
@end
