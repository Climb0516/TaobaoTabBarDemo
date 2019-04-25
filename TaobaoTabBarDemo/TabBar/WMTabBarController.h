//
//  WMTabBarController.h
//  Micropulse
//
//  Created by Climb 王 on 2019/3/20.
//  Copyright © 2019 iChoice. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WMTabBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMTabBarController : UITabBarController

// 切换指定index的tabbar，用该方法
- (void)changeTabBarAtIndex:(NSInteger )index;

// 暴露外部的切换动画logo和火箭的方法
- (void)pushHomeTabBarAnimationType:(anmationDirection )anmationDirection;

@end

NS_ASSUME_NONNULL_END
