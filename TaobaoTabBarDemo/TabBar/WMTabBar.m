//
//  WMTabBar.m
//  Micropulse
//
//  Created by Climb 王 on 2019/3/20.
//  Copyright © 2019 iChoice. All rights reserved.
//

#import "WMTabBar.h"

#import "WMTabBarItem.h"

#define kScreen_height [[UIScreen mainScreen] bounds].size.height
#define kScreen_width [[UIScreen mainScreen] bounds].size.width

@interface WMTabBar ()

@property (nonatomic, assign) NSInteger lastSelectIndex;//记录上一次点击index
@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation WMTabBar

//删除系统tabbar的UITabBarButton
- (void)layoutSubviews {
    [super layoutSubviews];
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [view removeFromSuperview];
        }
    }
}


+ (instancetype)tabBarWithTitleArray:(NSArray *)titleArray imageArray:(NSArray *)imageArray selectedImageArray:(NSArray *)selectedImageArray {
    WMTabBar *tabBar = [[WMTabBar alloc] init];
    tabBar.titleArray = titleArray;
    tabBar.imageArray = imageArray;
    tabBar.selectedImageArray = selectedImageArray;
    [tabBar setupUI];
    return tabBar;
}

- (void)setupUI {
    self.lastSelectIndex = 100;//默认为100
    self.backgroundColor = [UIColor whiteColor];
    for (int i = 0; i < self.titleArray.count; i++) {
        CGFloat itemWidth = (kScreen_width/self.titleArray.count);
        CGRect frame = CGRectMake(i*itemWidth, 0, itemWidth, 56);
        WMTabBarItem *tabBarItem = [[WMTabBarItem alloc] initWithFrame:frame index:i];
        tabBarItem.tag = i ;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectTabBarItemAction:)];
        [tabBarItem addGestureRecognizer:tap];
        [self addSubview:tabBarItem];
        [self.itemArray addObject:tabBarItem];
    }
    self.selectedIndex = 0;
}

- (void)selectTabBarItemAction:(UITapGestureRecognizer *)sender {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(selectedTabbarAtIndex:) object:@(sender.view.tag)];
    [self performSelector:@selector(selectedTabbarAtIndex:) withObject:@(sender.view.tag) afterDelay:0.15f];
}

- (void)selectedTabbarAtIndex:(NSNumber *)index {
    self.selectedIndex = [index integerValue];
    if ([self.tabBarDelegate respondsToSelector:@selector(selectedWMTabBarItemAtIndex:)]) {
        [self.tabBarDelegate selectedWMTabBarItemAtIndex:[index integerValue]];
    }
}

- (void)setSelectedIndex:(NSInteger )selectedIndex {
    _selectedIndex = selectedIndex;
    [self.itemArray enumerateObjectsUsingBlock:^(WMTabBarItem *tabBarItem, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL selected = (idx == selectedIndex);
        [tabBarItem configTitle:self.titleArray[idx] normalImage:self.imageArray[idx] selectedImage:self.selectedImageArray[idx] index:idx selected:selected lastSelectIndex:self.lastSelectIndex];
        if (idx == (self.itemArray.count-1)) {
            self.lastSelectIndex = selectedIndex;
        }
    }];
}

// 暴露外部的切换动画logo和火箭的方法
- (void)pushHomeTabBarAnimationType:(anmationDirection )anmationDirection {
    if (self.itemArray.count > 0) {
        WMTabBarItem *tabBarItem = self.itemArray[0];
        if (anmationDirection == anmationDirectionUp) {
            [tabBarItem pushHomeTabAnimationUp];
        }else {
            [tabBarItem pushHomeTabAnimationDown];
        }
    }
}

#pragma mark - lazy
- (NSMutableArray *)itemArray {
    if (!_itemArray) {
        _itemArray = [NSMutableArray array];
    }
    return _itemArray;
}

- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = [NSArray array];
    }
    return _titleArray;
}

- (NSArray *)imageArray {
    if (!_imageArray) {
        _imageArray = [NSArray array];
    }
    return _imageArray;
}

- (NSArray *)selectedImageArray {
    if (!_selectedImageArray) {
        _selectedImageArray = [NSArray array];
    }
    return _selectedImageArray;
}

@end
