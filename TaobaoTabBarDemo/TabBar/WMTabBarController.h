//
//  WMTabBarController.h
//  Micropulse
//
//  Created by Climb 王 on 2019/3/20.
//  Copyright © 2019 iChoice. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface WMTabBarController : UITabBarController

// 切换指定index的tabbar，用该方法
- (void)changeTabBarAtIndex:(NSInteger )index;

@end

NS_ASSUME_NONNULL_END
