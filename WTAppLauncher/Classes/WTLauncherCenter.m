//
//  WTLauncherCenter.m
//  Pods
//
//  Created by walter on 19/07/2017.
//
//

#import "WTLauncherCenter.h"

@interface WTLauncherCenter(){
     CFBinaryHeapRef _launchers;
}

@property (nonatomic, strong) dispatch_queue_t launchQueue;
@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue;

@end


static const void *WTLauncherPriorityRetain(CFAllocatorRef allocator, const void *ptr) {
    return CFRetain(ptr);
}

static void WTLauncherPriorityRelease(CFAllocatorRef allocator, const void *ptr) {
    CFRelease(ptr);
}

static CFComparisonResult WTModuleItemPriorityCompare(const void *ptr1, const void *ptr2, void *info)
{
    WTLauncher *item1 = (__bridge WTLauncher *)ptr1;
    WTLauncher *item2 = (__bridge WTLauncher *)ptr2;
    
    if ([item1 priority] < [item2 priority]) {  // greator first
        return kCFCompareLessThan;
    }
    
    if ([item1 priority] > [item2 priority]) {
        return kCFCompareGreaterThan;
    }
    
    return kCFCompareEqualTo;
}

@implementation WTLauncherCenter
static WTLauncherCenter *_center = nil;

+(instancetype)defaultCenter{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _center = [[WTLauncherCenter alloc] init];
    });
    return _center;
}

- (instancetype)init
{
    if (self = [super init]) {
        _launchQueue = dispatch_queue_create("com.wtlauncher.group.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
        _serialQueue = dispatch_queue_create("com.wtlauncher.serial.queue", NULL);
        _concurrentQueue = dispatch_queue_create("com.wtlauncher.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
        CFBinaryHeapCallBacks callbacks = (CFBinaryHeapCallBacks) {
            .version = 0,
            .retain = &WTLauncherPriorityRetain,
            .release = &WTLauncherPriorityRelease,
            .copyDescription = &CFCopyDescription,
            .compare = &WTModuleItemPriorityCompare
        };
        
        _launchers = CFBinaryHeapCreate(kCFAllocatorDefault, 0, &callbacks, NULL);
        
    }
    
    return self;
}

- (void)addLauncher:(Class)lancher
{
    WTLauncher *temp = [[lancher alloc] init];
    if ([temp isKindOfClass:[WTLauncher class]]) {
        CFBinaryHeapAddValue(_launchers, (__bridge const void *)(temp));
    }
}

- (void)startAll{
    CFIndex count = CFBinaryHeapGetCount(_launchers);
    const void **list = calloc(count, sizeof(const void *));
    CFBinaryHeapGetValues(_launchers, list);
    
    CFArrayRef objects = CFArrayCreate(kCFAllocatorDefault, list, count, &kCFTypeArrayCallBacks);
    
    NSArray *items = (__bridge_transfer NSArray *)objects;
    
    [items enumerateObjectsWithOptions:NSEnumerationReverse
                            usingBlock:^(WTLauncher * _Nonnull launcher, NSUInteger idx, BOOL * _Nonnull stop) {
                                switch ([launcher inQueue]) {
                                    case WTLauncherInQueue_MainQueue:{
                                        [self asyncRunLaunchInMainThread:^{
                                            [launcher start];
                                        }];
                                        break;
                                    }
                                    case WTLauncherInQueue_SerialQueue:{
                                        [self syncRunLaunchInSerialQueue:^{
                                            [launcher start];
                                        }];
                                        break;
                                    }
                                    case WTLauncherInQueue_ConcurrentQueue:{
                                        [self asyncRunLaunchInConcurrentQueue:^{
                                            [launcher start];
                                        }];
                                        break;
                                    }
                                    default:
                                        break;
                                }
                            }];
}

- (void)asyncRunLaunchInMainThread:(dispatch_block_t) block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CFTimeInterval start = CACurrentMediaTime();
        block();
        NSLog(@"launch asyncRunLaunchInMainThread time : %g s", CACurrentMediaTime() - start);
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

- (void)syncRunLaunchInSerialQueue:(dispatch_block_t) block
{
    dispatch_sync(_serialQueue, ^{
        CFTimeInterval start = CACurrentMediaTime();
        block();
        NSLog(@"launch syncRunLaunchInSerialQueue time : %g s", CACurrentMediaTime() - start);
    });
}

@end
