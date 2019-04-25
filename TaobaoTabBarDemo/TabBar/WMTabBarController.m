//
//  WMTabBarController.m
//  Micropulse
//
//  Created by Climb 王 on 2019/3/20.
//  Copyright © 2019 iChoice. All rights reserved.
//

#import "WMTabBarController.h"

#import "WMTabBar.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "FourViewController.h"
#import "FifthViewController.h"

@interface WMTabBarController ()<WMTabBarDelegate>

@property (nonatomic, strong) FirstViewController  *homePageController;
@property (nonatomic, strong) SecondViewController *seeDoctorController;
@property (nonatomic, strong) ThirdViewController *knowledgeController;
@property (nonatomic, strong) FourViewController  *mallController;
@property (nonatomic, strong) FifthViewController *mineController;
@property (nonatomic, strong) NSMutableArray *controllersArray;
@property (nonatomic, strong) WMTabBar *wmTabBar;

@end

@implementation WMTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.controllersArray = [NSMutableArray new];
    [self createControllers];
}

- (void)createControllers {
    self.homePageController  = [FirstViewController new];
    self.seeDoctorController = [SecondViewController new];
    self.knowledgeController = [ThirdViewController new];
    self.mallController = [FourViewController new];
    self.mineController = [FifthViewController new];
    
    NSArray *childVCArray = @[self.homePageController, self.seeDoctorController, self.knowledgeController, self.mallController, self.mineController];
    NSArray *titleArray   = @[@"首页", @"发现", @"知识", @"商城", @"我的"];
    NSArray *imageArray   = @[@"tabbar_home_normal", @"tabbar_find_normal", @"tabbar_knowledge_normal", @"tabbar_mall_normal", @"tabbar_mine_normal"];
    NSArray *selectedImageArray = @[@"tabbar_home_selectedBg", @"tabbar_find_selected", @"tabbar_knowledge_selected", @"tabbar_mall_selected", @"tabbar_mine_selected"];
    //添加子模块
    [self creatTabBarWithChildVCArray: childVCArray
                           titleArray: titleArray
                           imageArray: imageArray
                   selectedImageArray: selectedImageArray];
}

//添加子模块
- (void)creatTabBarWithChildVCArray:(NSArray *)childVCArray
                         titleArray:(NSArray *)titleArray
                         imageArray:(NSArray *)imageArray
                 selectedImageArray:(NSArray *)selectedImageArray {
    
    for (UIViewController *viewController in childVCArray) {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [self.controllersArray addObject:navigationController];
    }
    
    self.wmTabBar = [WMTabBar tabBarWithTitleArray:titleArray
                                      imageArray:imageArray
                              selectedImageArray:selectedImageArray];
    self.wmTabBar.tabBarDelegate = self;
    [self setValue:self.wmTabBar forKeyPath:@"tabBar"];
    self.viewControllers = self.controllersArray;
}

// 重写tabbar的frame，改变tabbar高度
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect frame = self.tabBar.frame;
    if (frame.size.height != 56) {
        frame.size.height = 56;
        frame.origin.y = self.view.frame.size.height - frame.size.height;
        self.tabBar.frame = frame;
    }
}

#pragma mark ----------- tabbarDelegate -------------

- (void)selectedWMTabBarItemAtIndex:(NSInteger)index {
    self.selectedIndex = index;
}


#pragma mark ----------- publick Mothed -------------

- (void)changeTabBarAtIndex:(NSInteger)index {
    self.selectedIndex = index;
    [self.wmTabBar selectedTabbarAtIndex:@(index)];
}

// 暴露外部的切换动画logo和火箭的方法
- (void)pushHomeTabBarAnimationType:(anmationDirection)anmationDirection {
    [self.wmTabBar pushHomeTabBarAnimationType:anmationDirection];
}

@end
