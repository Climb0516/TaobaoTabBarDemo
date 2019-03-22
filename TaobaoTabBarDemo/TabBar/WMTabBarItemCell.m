//
//  WMTabBarItemCell.m
//  Micropulse
//
//  Created by Climb 王 on 2019/3/20.
//  Copyright © 2019 iChoice. All rights reserved.
//

#import "WMTabBarItemCell.h"

@interface WMTabBarItemCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation WMTabBarItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.imageView = [UIImageView new];
        [self.contentView addSubview:self.imageView];
        self.imageView.frame = CGRectMake(0, 0, 42.f, 42.f);
        self.imageView.contentMode = UIViewContentModeCenter;
    }
    return self;
}

- (void)configItemImageString:(NSString *)imgString {
    [self.imageView setImage:[UIImage imageNamed:imgString]];
}

@end
