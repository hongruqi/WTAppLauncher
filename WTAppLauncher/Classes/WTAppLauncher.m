//
//  WTAppLauncher.m
//  Pods
//
//  Created by walter on 19/07/2017.
//
//

#import "WTAppLauncher.h"

@interface WTAppLauncher()

@property (nonatomic, strong) dispatch_group_t launchGroup;
@property (nonatomic, strong) dispatch_queue_t launchQueue;
//debug
@property (nonatomic, assign) CFTimeInterval launchTime;

@end


@implementation WTAppLauncher

- (instancetype)init
{
    if (self = [super init]) {
        
        _launchGroup = dispatch_group_create();
        _launchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _launchTime = CACurrentMediaTime();
    }
    
    return self;
}

- (void)addLauncherWithType:(WTAppLauncherType)type block:(dispatch_block_t)block
{
    switch (type) {
        case WTAppLauncherType_MainThread:
            [self asyncRunLaunchInMainThread:block];
            break;
        case WTAppLauncherType_XYGroupQueue:
            [self asyncRunLaunchInXYGroupQueue:block];
            break;
        case WTAppLauncherType_GrobalQueue:
            [self asyncRunLaunchInGlobalQueue:block];
            break;
        default:
            break;
    }
}

- (void)endLanuchingWithTimeout:(float)timeout
{
    dispatch_time_t groupTimeout = dispatch_time(DISPATCH_TIME_NOW, timeout*NSEC_PER_SEC);
    dispatch_group_wait(_launchGroup, groupTimeout);
    NSLog(@"launch app time : %g s", CACurrentMediaTime() - self.launchTime);
}

- (void)asyncRunLaunchInMainThread:(dispatch_block_t) block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}

- (void)asyncRunLaunchInXYGroupQueue:(dispatch_block_t) block
{
    dispatch_group_async(_launchGroup, _launchQueue, ^{
        block();
    });
}

- (void)asyncRunLaunchInGlobalQueue:(dispatch_block_t) block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        block();
    });
}

@end
