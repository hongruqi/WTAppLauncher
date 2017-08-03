//
//  WTAppDelegate.m
//  WTAppLauncher
//
//  Created by lbrsilva-allin on 07/19/2017.
//  Copyright (c) 2017 lbrsilva-allin. All rights reserved.
//

#import "WTAppDelegate.h"
#import "WTAppLauncher.h"

@implementation WTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    WTAppLauncher *launcher = [[WTAppLauncher alloc] init];
    [launcher addLauncherWithType:WTAppLauncherType_SerialQueue block:^{
         NSLog(@"WTAppLauncherType_SerialQueue 1");
    }];
    
    [launcher addLauncherWithType:WTAppLauncherType_GroupQueue block:^{
        sleep(3);
        NSLog(@"WTAppLauncherType_WTGroupQueue 1");
    }];
    
    [launcher addLauncherWithType:WTAppLauncherType_SerialQueue block:^{
        NSLog(@"WTAppLauncherType_SerialQueue 2 ");
    }];
    
    [launcher addLauncherWithType:WTAppLauncherType_MainThread block:^{
        NSLog(@"WTAppLauncherType_MainThread");
    }];
    
    [launcher addLauncherWithType:WTAppLauncherType_GlobalQueue block:^{
        NSLog(@"WTAppLauncherType_GrobalQueue");
    }];
    
    [launcher addLauncherWithType:WTAppLauncherType_GroupQueue block:^{
         NSLog(@"WTAppLauncherType_WTGroupQueue 2");
    }];
    
    [launcher addLauncherWithType:WTAppLauncherType_SerialQueue block:^{
        NSLog(@"WTAppLauncherType_SerialQueue 3 ");
    }];
    
    [launcher addNotificationGroupQueue:^{
         NSLog(@"addNotificaitonGroupQueue");
    }];
    
    [launcher endLanuchingWithTimeout:10];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
