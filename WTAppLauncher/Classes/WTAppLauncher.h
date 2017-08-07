//
//  WTAppLauncher.h
//  Pods
//
//  Created by walter on 19/07/2017.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WTAppLauncherType) {
    WTAppLauncherType_GroupQueue,
    WTAppLauncherType_MainThread,
    WTAppLauncherType_ConcurrentQueue, //并行队列
    WTAppLauncherType_SerialQueue // 串行队列，放入有执行顺序的block
};

@interface WTAppLauncher : NSObject

- (void)addLauncherWithType:(WTAppLauncherType )type block:(dispatch_block_t) block;

/**
 等待barrier之前的ConcurrentQueue中的block操作执行完毕后，barrier中的block执行，并且在barrier函数执行之后,barrier函数之后的操作才会得到执行
 满足一些需要之前业务逻辑
 @param block run block
 */
- (void)barrierAsyncRunLaunchInConcurrentQueue:(dispatch_block_t) block;

/**
 add Group Queue notifiacition
 添加group nitification 监听group 之前的block 执行完成。
 如果有业务需要依赖之前的block 执行完， 可以调用这个api 进行处理。
 @param block run block
 */
- (void)addNotificationGroupQueue:(dispatch_block_t) block;

/**
 结束初始化调用函数，必须被调用，确保之前加入的block，在didFinishLaunching函数结束前，全部被执行完。
 */
- (void)endLanuchingWithTimeout:(float)timeout;

@end
