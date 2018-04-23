//
//  WTLauncherItem.m
//  WTAppLauncher
//
//  Created by hongru on 2018/4/23.
//

#import "WTLauncher.h"
#import "WTLauncherCenter.h"
@implementation WTLauncher

+ (void)register{
    [[WTLauncherCenter defaultCenter] addLauncher:self.class];
}

- (void)start{
    // sub class implementation
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
