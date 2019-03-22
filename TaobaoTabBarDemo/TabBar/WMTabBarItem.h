//
//  WMTabBarItem.h
//  Micropulse
//
//  Created by Climb 王 on 2019/3/20.
//  Copyright © 2019 iChoice. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WMTabBarItem : UIView

- (instancetype)initWithFrame:(CGRect)frame index:(NSInteger )index;

- (void)configTitle:(NSString *)title normalImage:(NSString *)normalImage selectedImage:(NSString *)selectedImage index:(NSInteger)index selected:(BOOL)selected lastSelectIndex:(NSInteger )lastSelectIndex;

@end

NS_ASSUME_NONNULL_END
