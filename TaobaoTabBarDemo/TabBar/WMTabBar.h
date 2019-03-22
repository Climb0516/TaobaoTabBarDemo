//
//  WMTabBar.h
//  Micropulse
//
//  Created by Climb 王 on 2019/3/20.
//  Copyright © 2019 iChoice. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WMTabBarDelegate <NSObject>

/** 选中tabbar */
- (void)selectedWMTabBarItemAtIndex:(NSInteger)index;

@end

@interface WMTabBar : UITabBar

@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSArray *selectedImageArray;
@property (nonatomic, weak) id <WMTabBarDelegate> tabBarDelegate;
/** 实例化 */
+ (instancetype)tabBarWithTitleArray:(NSArray *)titleArray imageArray:(NSArray *)imageArray selectedImageArray:(NSArray *)selectedImageArray;

// 外部指定跳转到某个tab时调用
- (void)selectedTabbarAtIndex:(NSNumber *)index;

@end

NS_ASSUME_NONNULL_END
