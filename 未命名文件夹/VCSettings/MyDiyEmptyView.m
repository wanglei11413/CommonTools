//
//  MyDiyEmptyView.m
//  YiCaiTong
//
//  Created by wang on 2018/9/19.
//  Copyright © 2018年 wang. All rights reserved.
//

#import "MyDiyEmptyView.h"

@implementation MyDiyEmptyView

+ (instancetype)diyNoDataEmpty
{
    MyDiyEmptyView *view = [MyDiyEmptyView emptyViewWithImageStr:@"requestNoData"
                                 titleStr:@"暂无相关内容"
                                detailStr:nil];
    view.subViewMargin = FITFRAME(20.0);
    view.contentViewY = FITFRAME(35.0);
    view.titleLabFont = [UIFont systemFontOfSize:kMarginMax];
    view.titleLabTextColor = TextColor_Gray;
    return view;
}

+ (instancetype)diyNoDataEmptyWithBanner
{
    MyDiyEmptyView *view = [MyDiyEmptyView emptyViewWithImageStr:@"requestNoData"
                                                        titleStr:@"暂无相关内容"
                                                       detailStr:nil];
    view.subViewMargin = FITFRAME(20.0);
    view.contentViewY = FITFRAME(370.0);
    view.titleLabFont = [UIFont systemFontOfSize:kMarginMax];
    view.titleLabTextColor = TextColor_Gray;
    return view;
}


+ (instancetype)diyNoNetworkEmptyWithTarget:(id)target action:(SEL)action
{
    MyDiyEmptyView *view = [MyDiyEmptyView emptyActionViewWithImageStr:@"requestNoNetwork"
                                                     titleStr:@"服务器开小差啦"
                                                    detailStr:@"请检查您的网络连接是否正确"
                                                  btnTitleStr:@"重新加载"
                                                       target:target
                                                       action:action];
    view.subViewMargin = FITFRAME(20.0);
    view.titleLabFont = [UIFont systemFontOfSize:kMarginMax];
    view.detailLabFont = [UIFont systemFontOfSize:FITFRAME(13.0)];
    view.actionBtnFont = [UIFont systemFontOfSize:FITFRAME(13.0)];
    view.actionBtnTitleColor = APP_MainColor;
    view.actionBtnBackGroundColor = [UIColor clearColor];
    view.actionBtnHeight = FITFRAME(20.0);
    CGFloat width = FITFRAME(70.0);
    view.imageSize = CGSizeMake(width, width);
    
    return view;
}

+ (instancetype)diyNoNetworkEmptyWithMargin:(CGFloat)margin Target:(id)target action:(SEL)action
{
    MyDiyEmptyView *view = [MyDiyEmptyView emptyActionViewWithImageStr:@"requestNoNetwork"
                                                              titleStr:@"服务器开小差啦"
                                                             detailStr:@"请检查您的网络连接是否正确"
                                                           btnTitleStr:@"重新加载"
                                                                target:target
                                                                action:action];
    view.subViewMargin = FITFRAME(20.0);
    view.contentViewY = margin/2;
    view.titleLabFont = [UIFont systemFontOfSize:kMarginMax];
    view.detailLabFont = [UIFont systemFontOfSize:FITFRAME(13.0)];
    view.actionBtnFont = [UIFont systemFontOfSize:FITFRAME(13.0)];
    view.actionBtnTitleColor = APP_MainColor;
    view.actionBtnBackGroundColor = [UIColor clearColor];
    view.actionBtnHeight = FITFRAME(20.0);
    CGFloat width = FITFRAME(70.0);
    view.imageSize = CGSizeMake(width, width);
    
    return view;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
