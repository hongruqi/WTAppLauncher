//
//  WTLauncherCenter.h
//  Pods
//
//  Created by walter on 19/07/2017.
//
//

#import <Foundation/Foundation.h>
#import "WTLauncher.h"

@interface WTLauncherCenter : NSObject

+ (instancetype)defaultCenter;

- (void)startAll;

- (void)addLauncher:(Class)lancher;

@end
