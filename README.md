# IOS App 启动优化
## 技术调研

### 启动时间计算公式

```
App总启动时间 = t1(main()之前的加载时间) + t2(main()之后的加载时间)。

```

> t1 = 系统dylib(动态链接库)和自身App可执行文件的加载； 

> t2 = main方法执行之后到AppDelegate类中的- (BOOL)Application:(UIApplication *)Application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions方法执行结束前这段时间，主要是构建第一个界面，并完成渲染展示。

### 启动流程

#### main()调用之前加载过程
exec() 是一个系统调用。系统内核把应用映射到新的地址空间，且每次起始位置都是随机的（因为使用 ASLR）。并将起始位置到 0x000000 这段范围的进程权限都标记为不可读写不可执行。如果是 32 位进程，这个范围至少是 4KB；对于 64 位进程则至少是 4GB。NULL 指针引用和指针截断误差都是会被它捕获。

#### dylib loading
从主执行文件的 header 获取到需要加载的所依赖动态库列表，而 header 早就被内核映射过。然后它需要找到每个 dylib，然后打开文件读取文件起始位置，确保它是 Mach-O 文件。接着会找到代码签名并将其注册到内核。然后在 dylib 文件的每个 segment 上调用 mmap()。应用所依赖的 dylib 文件可能会再依赖其他 dylib，所以 dyld 所需要加载的是动态库列表一个递归依赖的集合。一般应用会加载 100 到 400 个 dylib 文件，但大部分都是系统 dylib，它们会被预先计算和缓存起来，加载速度很快。

#### rebase/bind
由于ASLR(address space layout randomization)的存在，可执行文件和动态链接库在虚拟内存中的加载地址每次启动都不固定，所以需要这2步来修复镜像中的资源指针，来指向正确的地址。 rebase修复的是指向当前镜像内部的资源指针； 而bind指向的是镜像外部的资源指针。 
rebase步骤先进行，需要把镜像读入内存，并以page为单位进行加密验证，保证不会被篡改，所以这一步的瓶颈在IO。bind在其后进行，由于要查询符号表，来指向跨镜像的资源，加上在rebase阶段，镜像已被读入和加密验证，所以这一步的瓶颈在于CPU计算。 
通过命令行可以查看相关的资源指针:

xcrun dyldinfo -rebase -bind -lazy_bind myApp.App/myApp

优化该阶段的关键在于减少__DATA segment中的指针数量。我们可以优化的点有：

1. 减少Objc类数量， 减少selector数量
2. 减少C++虚函数数量
3. 转而使用swift struct（其实本质上就是为了减少符号的数量）

#### Objc Runtime
这一步主要工作是:

1. 注册Objc类 (class registration)
2. 把category的定义插入方法列表 (category registration)
3. 保证每一个selector唯一 (selctor uniquing)

由于之前2步骤的优化，这一步实际上没有什么可做的。

#### initializers

以上三步属于静态调整(fix-up)，都是在修改__DATA segment中的内容，而这里则开始动态调整，开始在堆和堆栈中写入内容。 在这里的工作有：

1. Objc的+load()函数,使用 +initialize 来替代 +load
2. C++的构造函数属性函数 形如attribute((constructor)) void DoSomeInitializationWork()
3. 非基本类型的C++静态全局变量的创建(通常是类或结构体)(non-trivial initializer) 比如一个全局静态结构体的构建，如果在构造函数中有繁重的工作，那么会拖慢启动速度

Objc的load函数和C++的静态构造函数采用由底向上的方式执行，来保证每个执行的方法，都可以找到所依赖的动态库。


### main()调用之后的加载时间

在main()被调用之后，App的主要工作就是初始化必要的服务，显示首页内容等。而我们的优化也是围绕如何能够快速展现首页来开展。 App通常在AppDelegate类中的- (BOOL)Application:(UIApplication *)Application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions方法中创建首页需要展示的view，然后在当前runloop的末尾，主动调用CA::Transaction::commit完成视图的渲染。 
而视图的渲染主要涉及三个阶段：

准备阶段 这里主要是图片的解码
布局阶段 首页所有UIView的- (void)layoutSubViews()运行
绘制阶段 首页所有UIView的- (void)drawRect:(CGRect)rect运行 
再加上启动之后必要服务的启动、必要数据的创建和读取，这些就是我们可以尝试优化的地方

因此，main()函数调用之前我们可以优化的点有：

- 不使用xib，直接视用代码加载首页视图。
- NSUserDefaults实际上是在Library文件夹下会生产一个plist文件，如果文件太大的话一次能读取到内存中可能很耗时，这个影响需要评估，如果耗时很大的话需要拆分(需考虑老版本覆盖安装兼容问题)。
- 每次用NSLog方式打印会隐式的创建一个Calendar, 仅仅针对内测版输出log。
- 梳理应用启动时发送的所有网络请求，统一在异步线程请求。
- 并行初始化各个业务。

###优化犯案

### main()调用之前加载过程,优化内容
1. 减少framework引用
2. 删除无用类，无用函数
3. 减少+load 函数使用

### main()调用之后, 优化内容
####思路
- 将需要执行的处理，放入不同的block内，并发到不同的queue中进行。
- 提供串行队列，执行有依赖的逻辑
- 提供group，对彼此依赖不明确，但需要整天执行完成后，进行处理的业务，提供dispatch_group功能满足需求。
- 对于MainThread有需要的业务，提供mainThread 支持。 
#### 提供四个type选项执行启动block
- WTAppLauncherType_WTGroupQueue 自定义group
- WTAppLauncherType_MainThread 主线程async 执行 block
- WTAppLauncherType_GlobalQueue global queue 执行block
- WTAppLauncherType_SerialQueue sync 执行 block

> ```Objc
typedef NS_ENUM(NSUInteger, WTAppLauncherType) {
    WTAppLauncherType_WTGroupQueue,
    WTAppLauncherType_MainThread,
    WTAppLauncherType_GlobalQueue,
    WTAppLauncherType_SerialQueue // 串行队列，放入有执行顺序的block
};
```
#### WTAppLauncher 提供功能
> 将业务相关的启动block 放入对应的Type内进行。

> 最后在wait 全部执行后，进行splash 页面。
> 业务不相关的放入全局global_queue 内进行初始化。

```
- (void)addLauncherWithType:(WTAppLauncherType )type block:(dispatch_block_t) block;

/**
 add Group Queue notification
 添加group notification 监听group 之前的block 执行完成。
 如果有业务需要依赖之前的block 执行完， 可以调用这个api 进行处理。
 @param block run block
 */
- (void)addNotificationGroupQueue:(dispatch_block_t) block; 
/**
 结束初始化调用函数，必须被调用，确保之前加入的block，在didFinishLaunching函数结束前，全部被执行完。
 */
- (void)endLanuchingWithTimeout:(float)timeout;

```

- [今日头条iOS客户端启动速度优化](https://techblog.toutiao.com/2017/01/17/iosspeed/)
- [苹果广告视频](https://developer.apple.com/videos/play/wwdc2016/406/)



