//
//  FirstViewController.m
//  TaobaoTabBarDemo
//
//  Created by Climb 王 on 2019/3/22.
//  Copyright © 2019 Climb 王. All rights reserved.
//

#import "FirstViewController.h"

#import "AppDelegate.h"

@interface FirstViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
/** 动画相关 */
@property (nonatomic, assign) BOOL tabAnimateOnceScrollFlag;//tabBar动画实现的一次滑动的标志，用来区分t不松手的一次滑行中调用多次s切换动画问题
@property (nonatomic, assign) CGFloat lastPositionOffestY; //记录上次偏移量，用以比对上滑/下滑/滑动范围等操作

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"首页";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    // 点击火箭🚀tab执行的滑动到顶部通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollTopAction) name:@"kPushDownAnimationScrollTopNotification" object:nil];
}


#pragma mark ----------- tableViewDelegate -------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellId"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellId"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"TaoBao淘宝%ld", indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}


#pragma mark ----------- Action -------------

// 点击tab火箭🚀 界面滑到顶部事件
- (void)scrollTopAction {
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}


#pragma mark ----------- scrollviewDelegate -------------

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual: self.tableView]) {
        CGFloat currentPostionOffsetY = scrollView.contentOffset.y;
//        // 限制向下偏移量
//        if (currentPostionOffsetY < -120) {
//            self.tableView.contentOffset = CGPointMake(0, -120.f);
//        }
        if (currentPostionOffsetY > self.lastPositionOffestY) {
            NSLog(@"手势上滑");
            // tabBar动画
            if (self.tabAnimateOnceScrollFlag) {
                // 上一次lastPositionOffestY<300.f, 且currentPostionOffsetY>300.f
                if ((self.lastPositionOffestY < 300.f) && (currentPostionOffsetY > 300.f)) {
                    NSLog(@"发送通知，切换火箭");
                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [appDelegate.wmTabBar pushHomeTabBarAnimationType:anmationDirectionUp];
                    self.tabAnimateOnceScrollFlag = NO;
                }
            }
        }else {
            NSLog(@"手势下滑");
            // tabBar动画
            if (self.tabAnimateOnceScrollFlag) {
                if ((self.lastPositionOffestY >= 300.f) && (currentPostionOffsetY < 300.f)) {
                    NSLog(@"发送通知，切换logo");
                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [appDelegate.wmTabBar pushHomeTabBarAnimationType:anmationDirectionDown];
                    self.tabAnimateOnceScrollFlag = NO;
                }
            }
            
        }
    }
}

// 当开始滚动视图时，执行该方法。一次有效滑动（开始滑动，滑动一小段距离，只要手指不松开，只算一次滑动），只执行一次。
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.tableView]) {
        self.tabAnimateOnceScrollFlag = YES;
        self.lastPositionOffestY = scrollView.contentOffset.y;
    }
}

@end
