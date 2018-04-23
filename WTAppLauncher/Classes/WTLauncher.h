//
//  WTLauncherItem.h
//  WTAppLauncher
//
//  Created by hongru on 2018/4/23.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WTLauncherInQueue) {
    WTLauncherInQueue_MainQueue,
    WTLauncherInQueue_ConcurrentQueue, //并行队列
    WTLauncherInQueue_SerialQueue // 串行队列，放入有执行顺序的block
};


@interface WTLauncher : NSObject

+ (void)register;

- (void)start;

- (NSInteger)priority;

- (WTLauncherInQueue)inQueue;

@end
