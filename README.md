# 仿淘宝tabBar点击及滑动时logo和火箭🚀切换动画

##  仿淘宝tabBar点击及滑动时logo和火箭🚀切换动画


最近项目改版里，产品设计重新设计了tabbar动画，旨在提升app的逼格。。。 
设计图是借鉴淘宝的tabBar：

![](https://ws2.sinaimg.cn/large/006tNc79ly1g2v2ucnju7g30bi0owhe7.gif)



找资料查找下，还没有相关开源的代码，好吧，那就自己开干吧。

## 先拆解功能点：
- 自定义tabBar，高度56
- tab显示：首页tab在选中时是大logo 无文字，未选中时是图片文字 ；其他tab未选中和选中都是图片文字
- tab切换：tab之间相互点击切换选中时的缩小放大的动画
- 当首页滑动到一定距离时，首页tab的大logo和小火箭执行切换动画：`手势上滑 - logo向下切换到小火箭； 手势下滑 - 小火箭向上切换到logo；`

## 开始各个击破吧
### 1. 自定义tabBar，高度56
删除系统tabBar，创建自定义tabBar，
```
@implementation WMTabBar

// 删除系统tabbar的UITabBarButton
- (void)layoutSubviews {
    [super layoutSubviews];
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [view removeFromSuperview];
        }
    }
}

// 根据配置信息创建自定义tabBar
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
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tabBarItemClickAction:)];
        [tabBarItem addGestureRecognizer:tap];
        [self addSubview:tabBarItem];
        [self.itemArray addObject:tabBarItem];
    }
    // 记录选中index， 在其setter方法里重写逻辑
    self.selectedIndex = 0;
}

<!-- 选中index 重写setter方法，在里面做tabBar的item的内容动态配置 -->
- (void)setSelectedIndex:(NSInteger )selectedIndex {
    _selectedIndex = selectedIndex;
    [self.itemArray enumerateObjectsUsingBlock:^(WMTabBarItem *tabBarItem, NSUInteger idx, BOOL * _Nonnull stop) {
        // 当遍历的idx=selectedIndex时，记录选中状态
        BOOL selected = (idx == selectedIndex);
        // 配置tabBarItem的内容信息
        [tabBarItem configTitle:self.titleArray[idx] normalImage:self.imageArray[idx] selectedImage:self.selectedImageArray[idx] index:idx selected:selected lastSelectIndex:self.lastSelectIndex];
        // 当遍历到最后一个时，赋值lastSelectIndex
        if (idx == (self.itemArray.count-1)) {
            self.lastSelectIndex = selectedIndex;
        }
    }];
}
```
在WMTabBar里仿照系统tabBar的点击方法，添加两个wmTabBar代理方法，以满足项目里tabBar点击选中或点击tabBar时根据登录状态进行是否选中等操作：
```
@protocol WMTabBarDelegate <NSObject>

/** 选中tabbar */
- (void)wmtabBar:(WMTabBar *)wmTabBar selectedWMTabBarItemAtIndex:(NSInteger)index;
/** 是否可选tabbar */
- (BOOL)wmtabBar:(WMTabBar *)wmTabBar shouldSelectedWMTabBarItemAtIndex:(NSInteger)index;

@end
```
在WMTabBarController里设置tabBar
```
// 重写tabbar的frame，改变tabbar高度
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect frame = self.tabBar.frame;
    if (frame.size.height != kTABBARHEIGHT) {
        frame.size.height = kTABBARHEIGHT;
        frame.origin.y = self.view.frame.size.height - frame.size.height;
        self.tabBar.frame = frame;
    }
}

//添加子模块
- (void)creatTabBarWithChildVCArray:(NSArray *)childVCArray
                         titleArray:(NSArray *)titleArray
                         imageArray:(NSArray *)imageArray
                 selectedImageArray:(NSArray *)selectedImageArray {
    
    for (UIViewController *viewController in childVCArray) {
        MPNavigationController *navigationController = [[MPNavigationController alloc] initWithRootViewController:viewController];
        [self.controllersArray addObject:navigationController];
    }
    
    self.wmTabBar = [WMTabBar tabBarWithTitleArray:titleArray
                                      imageArray:imageArray
                              selectedImageArray:selectedImageArray];
    self.wmTabBar.tabBarDelegate = self;
    [self setValue:self.wmTabBar forKeyPath:@"tabBar"];
    self.viewControllers = self.controllersArray;
}
```

### 2. tab显示：首页tab在选中时是大logo 无文字，未选中时是图片文字 ；其他tab未选中和选中都是图片文字

##### 在tabBarItem里创建显示UI

```
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
```
##### 在tab点击事件里处理：

```

// 当点击tab的item时，执行
- (void)configTitle:(NSString *)title normalImage:(NSString *)normalImage selectedImage:(NSString *)selectedImage index:(NSInteger)index selected:(BOOL)selected lastSelectIndex:(NSInteger )lastSelectIndex {
    self.titleLabel.text = title;
    // 当index == 0, 即首页tab
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
                if (self.flag) {
                    // 如果已经是火箭状态，则点击切换logo，且发通知 让首页滑到顶部
                    [self pushHomeTabAnimationDown];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPushDownAnimationScrollTopNotification" object:nil];
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
        // 其他tab
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
```
就是在tab点击事件里做处理：
- 当index==0 即首页tab时，根据是否是seleted状态 来判断显示是大logo控件还是正常文字图片控件。
- 其他tab时，隐藏大logo控件，只显示图片文字控件，再根据是否是seleted状态 来判断选中和未选中时的图片及文字颜色配置。


### 3.tab切换：tab之间相互点击切换选中时的缩小放大的动画

tab在相互点击切换选中时的缩小放大动画，通过CABasicAnimation来实现：

```
/** 
 * tab之间切换动画 
 */
// 首页tab缩小放大动画 
- (void)animationForHomeTab {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration  = 0.2f;
    animation.fromValue = [NSNumber numberWithFloat:0.5f];
    animation.toValue   = [NSNumber numberWithFloat:1.f];
    [self.homeTabSelectedBgView.layer addAnimation:animation forKey:nil];
}

// 其他tab缩小放大动画
- (void)animationForNormalTab {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration  = 0.25f;
    animation.fromValue = [NSNumber numberWithFloat:0.5f];
    animation.toValue   = [NSNumber numberWithFloat:1.f];
    [self.imageView.layer  addAnimation:animation forKey:nil];
    [self.titleLabel.layer addAnimation:animation forKey:nil];
}

```
效果如下：
![](https://ws2.sinaimg.cn/large/006tNc79ly1g2uuor58sbg30c80lrqv5.gif)

### 4.当首页滑动到一定距离时，首页tab的大logo和小火箭执行切换动画


##### 观察设计图，可以得出根据首页的滑动偏移量及滑动手势，来确定滑动动画方案：

`在一次滑动行为中：当偏移量>阈值,且手势上滑 - logo向下切换到小火箭；当偏移量<阈值,且手势下滑 - 小火箭向上切换到logo；`

##### 首页里滑动代理实现：
```
// tabBar动画 - 判断滑动手势，再根据手势,偏移量 判断动画类型
- (void)tabBarAnimateWithScrollView:(UIScrollView *)scrollView {
    CGFloat currentPostionOffsetY = scrollView.contentOffset.y;
    if (currentPostionOffsetY > self.lastPositionOffestY) {
        NSLog(@"手势上滑");
        // tabBar动画
        if (self.tabAnimateOnceScrollFlag) {
            // 在一次滑动中，且currentPostionOffsetY>456，执行logo切换火箭🚀动画
            if ((currentPostionOffsetY > 456.f)) {
                NSLog(@"执行-切换火箭");
                [[AppLoginHandle sharedInstance].tabBarController pushHomeTabBarAnimationType:anmationDirectionUp];
                self.tabAnimateOnceScrollFlag = NO;
            }
        }
    }else {
        NSLog(@"手势下滑");
        // tabBar动画
         if (self.tabAnimateOnceScrollFlag) {
             // 在一次滑动中，下滑手势, 且currentPostionOffsetY<456，执行火箭🚀切换logo动画
             if ((currentPostionOffsetY < 456.f)) {
                 NSLog(@"触发-切换logo");
                 [[AppLoginHandle sharedInstance].tabBarController pushHomeTabBarAnimationType:anmationDirectionDown];
                 self.tabAnimateOnceScrollFlag = NO;
             }
         }
    }
}

// 当开始滚动视图时，执行该方法。一次有效滑动（开始滑动，滑动一小段距离，只要手指不松开，只算一次滑动），只执行一次。
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.collectionView]) {
        self.tabAnimateOnceScrollFlag = YES;
        self.lastPositionOffestY = scrollView.contentOffset.y;
    }
}

```
##### WMTabBar里暴露出外部调用切换动画的方法如下：
```
// logo和火箭切换动画的枚举anmationDirection
typedef NS_ENUM(NSUInteger, anmationDirection) {
    anmationDirectionUp,//push动画，火箭头出来，logo下去
    anmationDirectionDown,//push动画，火箭头下去，logo出来
};
@class WMTabBar;
@protocol WMTabBarDelegate <NSObject>

/** 选中tabbar */
- (void)wmtabBar:(WMTabBar *)wmTabBar didSelectWMTabBarItemAtIndex:(NSInteger)index;
/** 是否可选tabbar */
- (BOOL)wmtabBar:(WMTabBar *)wmTabBar shouldSelectWMTabBarItemAtIndex:(NSInteger)index;

@end

@interface WMTabBar : UITabBar

@property (nonatomic, weak) id <WMTabBarDelegate> tabBarDelegate;
@property (nonatomic, assign) anmationDirection anmationDirection;
/** 实例化 */
+ (instancetype)tabBarWithTitleArray:(NSArray *)titleArray imageArray:(NSArray *)imageArray selectedImageArray:(NSArray *)selectedImageArray;

// 外部指定跳转到某个tab时调用
- (void)selectedTabbarAtIndex:(NSNumber *)index;
// 暴露外部的切换动画logo和火箭的方法
- (void)pushHomeTabBarAnimationType:(anmationDirection )anmationDirection;

@end
```
##### WMTabBarItem里实现首页tab的小火箭和logo之间切换动画
###### 这里写了两种方法，第一种是最开始尝试的，通过CATransition的push动画，来达到一个imageView控件的两个图片切换，如下:

- 第一种方案 push动画方案：
```
// push动画，火箭头出来
-(void)pushHomeTabAnimationUp {
    self.flag = YES;
    //    /** 第一种方案 */
    //    [self.homeTabAnimateImageView setImage:[UIImage imageNamed:@"tabbar_home_selecetedPush"]];
    //    CATransition *animation = [CATransition animation];
    //    animation.type = kCATransitionPush;//设置动画的类型
    //    animation.subtype = kCATransitionFromTop; //设置动画的方向
    //    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //    animation.duration = 0.25f;
    //    [self.homeTabAnimateImageView.layer addAnimation:animation forKey:@"pushAnimation"];
}

// push动画，火箭头落下
-(void)pushHomeTabAnimationDown {
    self.flag = NO;
    //    /** 第一种方案 */
    //    [self.homeTabAnimateImageView setImage:[UIImage imageNamed:@"tabbar_home_selecetedLogo"]];
    //    CATransition *animation = [CATransition animation];
    //    animation.type = kCATransitionPush;//设置动画的类型
    //    animation.subtype = kCATransitionFromBottom; //设置动画的方向
    //    animation.duration = 0.25f;
    //    [self.homeTabAnimateImageView.layer addAnimation:animation forKey:@"pushAnimation"];
}
```
效果如下：

![](https://ws2.sinaimg.cn/large/006tNc79ly1g2uuq8uf8rg30hs0vmu0z.gif)


 虽然能实现功能，但在切换过程中，会有残留效果，这显示是不太美好的，再想想有没有更好的实现方法。


 然后就想到了collectionView了。

- 第二种方案 collection滑动item方案：

###### 把collectionView设置成首页tab大小，通过让collection的cell的scrollToItem方法， 即滑动到第n个item来达到切换动画效果，如下：
```
// push动画，火箭头出来
-(void)pushHomeTabAnimationUp {
    self.flag = YES;
    /** 第二种方案 */
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
}

// push动画，火箭头落下
-(void)pushHomeTabAnimationDown {
    self.flag = NO;
    /** 第二种方案 */
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
}
```

![](https://ws4.sinaimg.cn/large/006tNc79ly1g2uv0hs2e9g30hs0vm4qu.gif)

漂亮！


到此，新版tabBar实现就完成了！




