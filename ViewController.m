//
//  ViewController.m
//  IT07NSRunloopDemo
//
//  Created by Box on 16/7/21.
//  Copyright © 2016年 Box. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIScrollViewDelegate>{
    NSTimer *_timer;
    UIScrollView *_scrollView;
}

@property(nonatomic,strong)NSTimer *timer;

@end

@implementation ViewController

- (void)dealloc {
    [_timer invalidate];
    self.timer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 300)];
    scroll.backgroundColor = [UIColor redColor];
    scroll.delegate = self;
    scroll.contentSize = CGSizeMake(self.view.bounds.size.width * 5, 0);
    scroll.pagingEnabled = YES;
    [self.view addSubview:scroll];
    _scrollView = scroll;
    
    @autoreleasepool {
        for (NSInteger i = 0; i < 5; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.png",i+1]];
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width * i, 0, self.view.bounds.size.width, 300)];
            imageView.image = image;
            [scroll addSubview:imageView];
        }
    }
    
//    [self addTimer];
    
    
    [NSThread detachNewThreadSelector:@selector(observerRunLoop) toTarget:self withObject:nil];
    
    NSLog(@"你好啊~~~~~~~~");

    NSLog(@"no 好~~~~~~~~~~~~~~~~~~");
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observerRunLoop {
    NSLog(@"%s",__FUNCTION__);
    
    [self addTimer1];
    
    NSLog(@"over ::::%s",__FUNCTION__);
}

void myRunLoopObserver(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    
    switch (activity) {
        case kCFRunLoopEntry:
            NSLog(@"kCFRunLoopEntry");
            break;
        case kCFRunLoopExit:
            NSLog(@"kCFRunLoopExit");
            break;
        default:
            break;
    }
    
}

- (void)addTimer2 {
    @autoreleasepool {
        NSRunLoop *myRunLoop = [NSRunLoop currentRunLoop];
        
        //设置当前thread 的观察者的运行环境 上下文
        CFRunLoopObserverContext context = {0,(__bridge void *)(self),NULL,NULL,NULL};
        //创建一个 观察者
        CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &myRunLoopObserver, &context);
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
        
        if (observer) {//增加 观察者模式
            CFRunLoopRef cfRunLoop = [myRunLoop getCFRunLoop];
            CFRunLoopTimerRef cfTime = (__bridge CFRunLoopTimerRef)(self.timer);
            CFRunLoopAddObserver(cfRunLoop, observer, kCFRunLoopCommonModes);
            CFRunLoopAddTimer(cfRunLoop, cfTime, kCFRunLoopCommonModes);
            
            CFRelease(observer);
        }
        
        
        
        do {
            //runUntilDate 就是用来启动 runloop的方法；
            [myRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
        } while (TRUE);
    }
}

- (void)addTimer1 {
    
    @autoreleasepool {
        //先获取当前分线程中的 runloop
        NSRunLoop *myRunLoop = [NSRunLoop currentRunLoop];
        
//        CFRunLoopObserverContext context = {0,(__bridge void *)(self),NULL,NULL,NULL};
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
        
        [myRunLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
        
        
        do {
            [myRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
        } while (TRUE);
        
        
    }
    
    
    
}

- (void)addTimer {
    NSLog(@"%s",__FUNCTION__);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    
    NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
    [currentRunLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    
}

- (void)nextPage {
    NSLog(@"%s",__FUNCTION__);
    static int page = 0;
    CGFloat width = _scrollView.frame.size.width;
    if (5 == page) {
        page = 0;
    }
    [_scrollView setContentOffset:CGPointMake(width*page, 0) animated:YES];
    
    page++;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    [self addTimer];
    [NSThread detachNewThreadSelector:@selector(observerRunLoop) toTarget:self withObject:nil];
}







@end
