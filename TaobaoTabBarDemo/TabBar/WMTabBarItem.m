//
//  WMTabBarItem.m
//  Micropulse
//
//  Created by Climb 王 on 2019/3/20.
//  Copyright © 2019 iChoice. All rights reserved.
//

#import "WMTabBarItem.h"

#import "WMTabBarItemCell.h"

@interface WMTabBarItem ()<UICollectionViewDelegate, UICollectionViewDataSource>

/** tabbar的文字title */
@property (nonatomic, strong) UILabel *titleLabel;
/** tabbar的图片 */
@property (nonatomic, strong) UIImageView *imageView;

/*
 *  index=0时，即首页tababr 选中时的背景图片
 *  效果图细节：背景原图片没有变化，只是背景图片上的火箭🚀和logo 两个切换动画，
 *  所以: 隔离开背景部分和动画部分
 */
@property (nonatomic, strong) UIImageView *homeTabSelectedBgView;
/*
 *  动画部分
 *  第一种方案，用的是ImageView,进行kCATransitionPush向上或向下的动画
 *  优点： 布局省事
 *  缺点： 当火箭🚀向上动画时，大logo会有残影，且也算明显
 */
@property (nonatomic, strong) UIImageView *homeTabAnimateImageView;
/*
 *  动画部分
 *  第二种方案，用的是collectionView, 通过滑动到某个item进行动画
 *  结果：完美实现功能
 */
@property (nonatomic, strong) UICollectionView *collectionView;


/*
 *  调试用的flag，用以点击首页tabbar时 logo和火箭切换，h实际项目里根据滑动偏移量通知做具体动画即可
 */
@property (nonatomic, assign) BOOL tempFlag;

@end

@implementation WMTabBarItem

- (instancetype)initWithFrame:(CGRect)frame index:(NSInteger )index {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.imageView];
        [self addSubview:self.homeTabSelectedBgView];
        
        self.imageView.frame  = CGRectMake(self.bounds.size.width/2-14, 7, 28, 28);
        self.titleLabel.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame)+2, self.bounds.size.width, 14);
        self.homeTabSelectedBgView.frame = CGRectMake(self.bounds.size.width/2-21, 7, 42, 42);

        if (index == 0) {
            // 当为首页tab时，加上以下内容
            [self addSubview:self.homeTabSelectedBgView];
            
//            /** 第一种方案 */
//            [self.homeTabSelectedBgView addSubview:self.homeTabAnimateImageView];
//            self.homeTabAnimateImageView.frame  = CGRectMake(0, 0, 32, 32);
//            self.homeTabAnimateImageView.center = CGPointMake(self.homeTabSelectedBgView.frame.size.width/2, self.homeTabSelectedBgView.frame.size.height/2);
            
            /** 第二种方案 */
            [self.homeTabSelectedBgView addSubview:self.collectionView];
            self.homeTabSelectedBgView.frame  = CGRectMake(self.bounds.size.width/2-21, 7, 42, 42);
            self.collectionView.frame  = CGRectMake(0, 0, 42, 42);
            self.collectionView.center = CGPointMake(self.homeTabSelectedBgView.frame.size.width/2, self.homeTabSelectedBgView.frame.size.height/2);

            [self.collectionView registerClass:[WMTabBarItemCell class]
                    forCellWithReuseIdentifier:NSStringFromClass([WMTabBarItemCell class])];
        }
    }
    return self;
}

#pragma mark - collectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 2;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WMTabBarItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([WMTabBarItemCell class]) forIndexPath:indexPath];
    NSString *imageStr = (indexPath.item == 0) ? @"tabbar_home_selecetedLogo" : @"tabbar_home_selecetedPush";
    [cell configItemImageString:imageStr];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark ----------- Action -------------

// 当点击tab时，执行
- (void)configTitle:(NSString *)title normalImage:(NSString *)normalImage selectedImage:(NSString *)selectedImage index:(NSInteger)index selected:(BOOL)selected lastSelectIndex:(NSInteger )lastSelectIndex {
    self.titleLabel.text = title;
    if (index == 0) {
        if (selected) {
            [self.homeTabSelectedBgView setImage:[UIImage imageNamed:@"tabbar_home_selecetedBg"]];
            self.homeTabSelectedBgView.hidden = NO;
             YES;self.imageView.hidden = self.titleLabel.hidden = YES;
            
//            /** 第一种方案 */
//            [self.homeTabAnimateImageView setImage:[UIImage imageNamed:@"tabbar_home_selecetedLogo"]];
//            /** 第二种方案 默认显示第一个cell 所以不用在这里设置图片 */
            
            // 如果本次点击和上次是同一个tab 都是第0个，则执行push动画，否则执行放大缩小动画
            if (lastSelectIndex == index) {
                if (self.tempFlag) {
                    [self pushReverseAnimationWithHomeTab];
                }else {
                    [self pushAnimationWithHomeTab];
                }
            }else {
                [self animationWithHomeTab];
            }
        }else {
            [self.imageView setImage:[UIImage imageNamed:normalImage]];
            self.homeTabSelectedBgView.hidden = YES;
            self.imageView.hidden = self.titleLabel.hidden = NO;
        }
    }else {
        self.homeTabSelectedBgView.hidden = YES;
        self.imageView.hidden = self.titleLabel.hidden = NO;
        if (selected) {
            [self.imageView setImage:[UIImage imageNamed:selectedImage]];
            self.titleLabel.textColor = [self colorFromHexRGB:@"18A2FF"];
            // 如果本次点击和上次是同一个tab 则无反应，否则执行放大缩小动画
            if (lastSelectIndex != index) {
                [self animationWithNormalTab];
            }
        }else {
            [self.imageView setImage:[UIImage imageNamed:normalImage]];
            self.titleLabel.textColor = [self colorFromHexRGB:@"575D66"];
        }
    }
}

/** 动画 */
- (void)animationWithHomeTab {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration  = 0.2f;
    animation.fromValue = [NSNumber numberWithFloat:0.5f];
    animation.toValue   = [NSNumber numberWithFloat:1.f];
    [self.homeTabSelectedBgView.layer addAnimation:animation forKey:nil];
}

- (void)animationWithNormalTab {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration  = 0.25f;
    animation.fromValue = [NSNumber numberWithFloat:0.5f];
    animation.toValue   = [NSNumber numberWithFloat:1.f];
    [self.imageView.layer  addAnimation:animation forKey:nil];
    [self.titleLabel.layer addAnimation:animation forKey:nil];
}

// push动画，火箭头出来
-(void)pushAnimationWithHomeTab {
    self.tempFlag = YES;
    
//    /** 第一种方案 */
//    [self.homeTabAnimateImageView setImage:[UIImage imageNamed:@"tabbar_home_selecetedPush"]];
//    CATransition *animation = [CATransition animation];
//    animation.type = kCATransitionPush;//设置动画的类型
//    animation.subtype = kCATransitionFromTop; //设置动画的方向
//    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    animation.duration = 0.25f;
//    [self.homeTabAnimateImageView.layer addAnimation:animation forKey:@"pushAnimation"];
    
    /** 第二种方案 */
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
}

// push动画，火箭头落下
-(void)pushReverseAnimationWithHomeTab {
    self.tempFlag = NO;
    
//    /** 第一种方案 */
//    [self.homeTabAnimateImageView setImage:[UIImage imageNamed:@"tabbar_home_selecetedLogo"]];
//    CATransition *animation = [CATransition animation];
//    animation.type = kCATransitionPush;//设置动画的类型
//    animation.subtype = kCATransitionFromBottom; //设置动画的方向
//    animation.duration = 0.25f;
//    [self.homeTabAnimateImageView.layer addAnimation:animation forKey:@"pushAnimation"];
    
    /** 第二种方案 */
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
}


#pragma mark ----------- lazy Load -------------

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:10];
        _titleLabel.textColor = [self colorFromHexRGB:@"575D66"];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}

- (UIImageView *)homeTabAnimateImageView {
    if (!_homeTabAnimateImageView) {
        _homeTabAnimateImageView = [[UIImageView alloc] init];
        _homeTabAnimateImageView.userInteractionEnabled = YES;
    }
    return _homeTabAnimateImageView;
}

- (UIView *)homeTabSelectedBgView {
    if (!_homeTabSelectedBgView) {
        _homeTabSelectedBgView = [UIImageView new];
        _homeTabSelectedBgView.userInteractionEnabled = YES;
        _homeTabSelectedBgView.hidden = YES;
    }
    return _homeTabSelectedBgView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(42.f, 42.f);
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.delegate   = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.pagingEnabled = YES;
        _collectionView.scrollEnabled = NO;
    }
    return _collectionView;
}


// 16进制颜色
- (UIColor *) colorFromHexRGB:(NSString *) inColorString {
    //删除字符串中的空格
    NSString *cString = [[inColorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor blackColor];
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    
    if ([cString length] != 6&&[cString length] != 8) return [UIColor blackColor];
    
    if([cString length] == 8){
        NSRange range;
        range.location = 0;
        range.length = 2;
        NSString *rString = [cString substringWithRange:range];
        
        range.location = 2;
        NSString *gString = [cString substringWithRange:range];
        
        range.location = 4;
        NSString *bString = [cString substringWithRange:range];
        
        range.location = 6;
        NSString *aString = [cString substringWithRange:range];
        
        // Scan values
        unsigned int r, g, b, a;
        [[NSScanner scannerWithString:rString] scanHexInt:&r];
        [[NSScanner scannerWithString:gString] scanHexInt:&g];
        [[NSScanner scannerWithString:bString] scanHexInt:&b];
        [[NSScanner scannerWithString:aString] scanHexInt:&a];
        return [UIColor colorWithRed:((float) r / 255.0f)
                               green:((float) g / 255.0f)
                                blue:((float) b / 255.0f)
                               alpha:((float) a / 255.0f)];
    }
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

@end
