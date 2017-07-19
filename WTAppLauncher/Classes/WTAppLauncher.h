//
//  WTAppLauncher.h
//  Pods
//
//  Created by walter on 19/07/2017.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WTAppLauncherType) {
    WTAppLauncherType_XYGroupQueue,
    WTAppLauncherType_MainThread,
    WTAppLauncherType_GrobalQueue,
};

@interface WTAppLauncher : NSObject

- (void)addLauncherWithType:(WTAppLauncherType )type block:(dispatch_block_t) block;

/**
 结束初始化调用函数，必须被调用，确保之前加入的block，在didFinishLaunching函数结束前，全部被执行完。
 */
- (void)endLanuchingWithTimeout:(float)timeout;

@end
