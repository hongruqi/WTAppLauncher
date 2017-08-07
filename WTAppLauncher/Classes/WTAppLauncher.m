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
@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue;

//debug
@property (nonatomic, assign) CFTimeInterval launchTime;

@end


@implementation WTAppLauncher

- (instancetype)init
{
    if (self = [super init]) {
        _launchGroup = dispatch_group_create();
        _launchQueue = dispatch_queue_create("com.wtlauncher.group.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
        _serialQueue = dispatch_queue_create("com.wtlauncher.serial.queue", NULL);
        _concurrentQueue = dispatch_queue_create("com.wtlauncher.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
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
        case WTAppLauncherType_GroupQueue:
            [self asyncRunLaunchInGroupQueue:block];
            break;
        case WTAppLauncherType_ConcurrentQueue:
            [self asyncRunLaunchInConcurrentQueue:block];
            break;
        case WTAppLauncherType_SerialQueue:
            [self syncRunLaunchInSerialQueue:block];
            break;
        default:
            break;
    }
}

- (void)endLanuchingWithTimeout:(float)timeout
{
    dispatch_time_t groupTimeout = dispatch_time(DISPATCH_TIME_NOW, timeout*NSEC_PER_SEC);
    dispatch_group_wait(_launchGroup, groupTimeout);
    NSLog(@"launch app end time : %g s", CACurrentMediaTime() - self.launchTime);
}

- (void)asyncRunLaunchInMainThread:(dispatch_block_t) block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CFTimeInterval start = CACurrentMediaTime();
        block();
        NSLog(@"launch asyncRunLaunchInMainThread time : %g s", CACurrentMediaTime() - start);
    });
}

- (void)asyncRunLaunchInGroupQueue:(dispatch_block_t) block
{
    dispatch_group_async(_launchGroup, _launchQueue, ^{
        CFTimeInterval start = CACurrentMediaTime();
        block();
        NSLog(@"launch asyncRunLaunchInGroupQueue time : %g s", CACurrentMediaTime() - start);
    });
}

- (void)asyncRunLaunchInConcurrentQueue:(dispatch_block_t) block
{
    dispatch_async(_concurrentQueue, ^{
        CFTimeInterval start = CACurrentMediaTime();
        block();
        NSLog(@"launch asyncRunLaunchInConcurrentQueue time : %g s", CACurrentMediaTime() - start);
    });
}

- (void)barrierAsyncRunLaunchInConcurrentQueue:(dispatch_block_t) block
{
    dispatch_barrier_async(_concurrentQueue, ^{
        CFTimeInterval start = CACurrentMediaTime();
        block();
        NSLog(@"launch asyncRunLaunchInConcurrentQueue time : %g s", CACurrentMediaTime() - start);
    });
}

- (void)syncRunLaunchInSerialQueue:(dispatch_block_t) block
{
    dispatch_sync(_serialQueue, ^{
        CFTimeInterval start = CACurrentMediaTime();
        block();
        NSLog(@"launch syncRunLaunchInSerialQueue time : %g s", CACurrentMediaTime() - start);
    });
}

- (void)addNotificationGroupQueue:(dispatch_block_t) block
{
    dispatch_group_notify(_launchGroup, _launchQueue, ^{
        CFTimeInterval start = CACurrentMediaTime();
        block();
        NSLog(@"launch addNotificationGroupQueue time : %g s", CACurrentMediaTime() - start);
    });
}

@end
