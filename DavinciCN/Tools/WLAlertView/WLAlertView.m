//
//  WLAlertView.m
//  WLAlertViewDemo
//
//  Created by yaowei on 2018/8/28.
//  Copyright © 2018年 yaowei. All rights reserved.
//

#import "WLAlertView.h"
#import <GKCover.h>

@interface WLAlertView ()
{
    CGFloat _alterWidth;
    //装lineView的集合(包括所有的lineView)
    NSMutableArray *_lineList;
    //装body上下的两个lineView;
    NSMutableArray *_bodyLineList;
    //alertView的背景view
    UIImageView *_backgroundAlterView;
    
    UIColor *_backgroundColor;
    
    /** 0-默认，1-要重新更新约束，2-约束已经生效了 */
    NSInteger _setFrame;
    
    NSLayoutConstraint *_layAlertHeight;//方便后期扩展自定义高度

    NSMutableAttributedString *_msg;//记录第一次初始化message，用判断是否加\r\n
    NSMutableAttributedString *_title;//记录第一次初始化title，用判断是否加\r\n

}
//alter的容器
@property (nonatomic, strong) UIView *alertView;
//蒙层
@property (nonatomic, strong) UIView *maskView;
//高斯模糊的背景图
@property (nonatomic, strong) UIImageView *gaussianBlurOnMaskView;
//标题的view
@property (nonatomic, strong) UIView *titleView;
//标题
@property (nonatomic, strong) UILabel *titleLabel;
//描述的容器
@property (nonatomic, strong) UIView *messageContainerView;
//描述
@property (nonatomic, strong) UILabel *messageLabel;
//按钮的容器
@property (nonatomic, strong) UIView *btnContainerView;
//取消按钮
@property (nonatomic, strong) UIButton *cancelBtn;
//按钮的集合
@property (nonatomic, strong) NSMutableArray *buttionList;

@property (nonatomic, copy) void(^handler)(NSInteger buttonIndex,id value);

@end

@implementation WLAlertView

- (id<WLAlertViewProtocol>)alertViewWithIsLand:(BOOL)isLand
                                         image:(UIImage *)image
                                         title:(id)title
                                       message:(NSString *)message
                             cancelButtonTitle:(NSString *)cancelButtonTitle
                             otherButtonTitles:(NSArray *)otherButtonTitles handler:(void (^)(NSInteger, id _Nullable))handler
{
//    __weak typeof(self) weakSelf = self;
    // title
    // 如果是富文本，那么直接显示富文本
    NSMutableAttributedString *titleAStr = [[NSMutableAttributedString alloc] init];
    if ([title isKindOfClass:[NSMutableAttributedString class]]) {
        titleAStr = title;
    } else {
        NSMutableParagraphStyle *titleStyle  = [[NSMutableParagraphStyle alloc] init];
        titleStyle.alignment                 = NSTextAlignmentCenter;
        titleStyle.lineSpacing               = 5.0;
        titleAStr                            = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName: WLAlertTextDarkColor, NSFontAttributeName: [UIFont boldSystemFontOfSize:18], NSParagraphStyleAttributeName: titleStyle}];
        // message
        NSMutableAttributedString *detailAStr = [[NSMutableAttributedString alloc] init];
        if (message) {
            //
            NSMutableParagraphStyle *detailStyle  = [[NSMutableParagraphStyle alloc] init];
            detailStyle.alignment                 = NSTextAlignmentCenter;
            detailStyle.lineSpacing               = 21 - WLAlertTextFontMid.lineHeight;
            //
            NSDictionary *dic = @{NSForegroundColorAttributeName: WLAlertTextDarkColor, NSFontAttributeName: WLAlertTextFontMid, NSParagraphStyleAttributeName: detailStyle};
            // 计算有几行
            CGFloat textH = [message boundingRectWithSize:CGSizeMake(250, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size.height;
            CGFloat lineHeight = WLAlertTextFontMid.lineHeight;
            NSInteger lineCount = textH / lineHeight;
            if (lineCount > 2) {
                detailStyle.alignment = NSTextAlignmentLeft;
            }
            dic = @{NSForegroundColorAttributeName: WLAlertTextDarkColor, NSFontAttributeName: WLAlertTextFontMid, NSParagraphStyleAttributeName: detailStyle};
            detailAStr = [[NSMutableAttributedString alloc] initWithString:message?message:@"" attributes:dic];
            _msg = detailAStr;
        }
    }
    // 如果有图片
    if (image) {
        NSAttributedString *aStr    = [[NSAttributedString alloc] initWithString:@"\n\n"];
        [titleAStr insertAttributedString:aStr atIndex:0];
        NSTextAttachment *attach    = [[NSTextAttachment alloc] init];
        attach.image                = image;
        attach.bounds               = CGRectMake(0, 0, image.size.width, image.size.height);
        NSAttributedString *imgAStr = [NSAttributedString attributedStringWithAttachment:attach];
        [titleAStr insertAttributedString:imgAStr atIndex:0];
    }
    _title                               = titleAStr;
    // 其余设置
    UIView *currentView = [UIApplication sharedApplication].keyWindow;
    _lineList           = @[].mutableCopy;
    _bodyLineList       = @[].mutableCopy;
    _handler            = handler;
    _backgroundColor    = [UIColor whiteColor];
    _alterWidth         = isLand ? 450 : 290.0;
    self.maskView.frame = currentView.frame;
    [self addSubview:_maskView];
    self.gaussianBlurOnMaskView.frame = currentView.frame;
    [_maskView addSubview:self.gaussianBlurOnMaskView];
    
    [self onPrepareTitle:_title
                 message:_msg
       cancelButtonTitle:cancelButtonTitle
       otherButtonTitles:otherButtonTitles];
    return self;
}

//MARK:-- 显示
- (void)show
{
    if ([GKCover hasCover]) return;
    
    UIWindow *keWLindows = [UIApplication sharedApplication].keyWindow;
    [GKCover coverFrom:keWLindows
           contentView:self
                 style:GKCoverStyleTranslucent
             showStyle:GKCoverShowStyleCenter
         showAnimStyle:GKCoverShowAnimStyleNone
         hideAnimStyle:GKCoverHideAnimStyleNone
              notClick:YES];
    [self addConstraint:NSLayoutAttributeLeft equalTo:keWLindows offset:0];
    [self addConstraint:NSLayoutAttributeRight equalTo:keWLindows offset:0];
    [self addConstraint:NSLayoutAttributeTop equalTo:keWLindows offset:0];
    [self addConstraint:NSLayoutAttributeBottom equalTo:keWLindows offset:0];
    
    if (_setFrame == 0) {
        [self layoutIfNeeded];
    }else if (_setFrame == 1){
        
    }else if (_setFrame ==2){
        
    }
//    __weak typeof(self)weakSelf = self;
//    [UIView animateWithDuration:0.25 animations:^{
//        weakSelf.maskView.backgroundColor = [UIColor colorWithRed:10 / 255.0 green:10 / 255.0 blue:10 / 255.0 alpha:0.4];
//        weakSelf.maskView.alpha           = 1;
//        weakSelf.alertView.alpha          = 1;
//    }];
    
}

- (void)hiddenAlertView
{
    [GKCover hideCover];
//    __weak typeof(self)weakSelf = self;

//    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.8 options:0 animations:^{
//        weakSelf.maskView.alpha  = 0.0f;
//        weakSelf.alertView.alpha = 0.0f;
//    } completion:^(BOOL finished) {
//        [weakSelf removeFromSuperview];
//    }];
}

#pragma mark - action methods -

- (void)buttionClick:(UIButton *)btn
{
    [GKCover hideCover];
    [self hiddenAlertView];
    if (_handler) {
        _handler(btn.tag - 100, btn.titleLabel.text);
    }
}

#pragma mark - privite methods -
//准备布局
- (void)onPrepareTitle:(nullable NSMutableAttributedString *)title
                 message:(nullable NSMutableAttributedString *)message
       cancelButtonTitle:(nullable NSString *)cancelButtonTitle
       otherButtonTitles:(nullable NSArray <NSString *> *)otherButtonTitles
{
    CGFloat x                 = (KScreenW - _alterWidth)/2;
    UIView *alert             = [[UIView alloc] initWithFrame:CGRectMake(x, (KScreenH-300)/2, _alterWidth , 500)];
    alert.backgroundColor     = [UIColor whiteColor];
    alert.layer.cornerRadius  = 8.0;
    alert.layer.masksToBounds = YES;
    [self addSubview:alert];
    _alertView                = alert;

    UIImageView *bgIV    = [UIImageView new];
    bgIV.contentMode     = UIViewContentModeScaleAspectFill;
    bgIV.backgroundColor = [UIColor redColor];
    bgIV.hidden          = YES;
    [alert addSubview:bgIV];
    _backgroundAlterView = bgIV;

    // titleView
    UIView *titleView = self.titleView;
    [alert addSubview:titleView];
    
    [titleView addConstraint:NSLayoutAttributeLeft equalTo:alert offset:0];
    [titleView addConstraint:NSLayoutAttributeRight equalTo:alert offset:0];
    [titleView addConstraint:NSLayoutAttributeTop equalTo:alert offset:0];
    
    if (title && title.length > 0) {
        
        [titleView addSubview:self.titleLabel];
        self.titleLabel.attributedText = title;
        [self getDefalutTitle:titleView offset:30];
        [titleView addConstraint:NSLayoutAttributeHeight equalTo:self.titleLabel offset:60];
    } else {
        
        [titleView addSubview:self.titleLabel];
        [self getDefalutTitle:titleView offset:0];
    }

    // BodyView
    UIView *bodyView         = [[UIView alloc] init];
    bodyView.backgroundColor = DefaultTranslucenceColor;
    [alert addSubview:bodyView];
    _messageContainerView    = bodyView;

    [bodyView addConstraint:NSLayoutAttributeLeft equalTo:alert offset:0];
    [bodyView addConstraint:NSLayoutAttributeRight equalTo:alert offset:0];
    [bodyView addConstraint:NSLayoutAttributeTop equalTo:titleView toAttribute:NSLayoutAttributeBottom  offset:0];
    
    if (message && message.length > 0) {
      
        UIView *lineBoad = ({
            lineBoad = [UIView new];
            lineBoad.backgroundColor = DefaultLineTranslucenceColor;
            [bodyView addSubview:lineBoad];
            lineBoad;
        });
        [_bodyLineList addObject:lineBoad];
      
        [lineBoad addConstraint:NSLayoutAttributeLeft equalTo:bodyView offset:0];
        [lineBoad addConstraint:NSLayoutAttributeRight equalTo:bodyView offset:0];
        [lineBoad addConstraint:NSLayoutAttributeBottom equalTo:bodyView offset:0];
        [lineBoad addConstraint:NSLayoutAttributeHeight equalTo:nil offset:1];
      
        if (!title || title.length <= 0) {

            [self getDefalutBody:bodyView text:message value:30];

            [bodyView addConstraint:NSLayoutAttributeHeight equalTo:self.messageLabel offset:57];
          
        } else {
            [self getDefalutBody:bodyView text:message value:-10];
          
            [bodyView addConstraint:NSLayoutAttributeHeight equalTo:self.messageLabel offset:20];
        }
      
    } else {
        //测试代码
        [self getDefalutBody:bodyView text:message value:0];
        [bodyView addConstraint:NSLayoutAttributeHeight equalTo:self.messageLabel offset:0];
        
        UIView *lineBoad = ({
            lineBoad = [UIView new];
            lineBoad.backgroundColor = DefaultLineTranslucenceColor;
            [bodyView addSubview:lineBoad];
            lineBoad;
        });
        [_bodyLineList addObject:lineBoad];
      
        [lineBoad addConstraint:NSLayoutAttributeLeft equalTo:bodyView offset:10];
        [lineBoad addConstraint:NSLayoutAttributeRight equalTo:bodyView offset:10];
        [lineBoad addConstraint:NSLayoutAttributeBottom equalTo:bodyView offset:0];
        [lineBoad addConstraint:NSLayoutAttributeHeight equalTo:nil offset:1];
    }
    
    // BodyView
    UIView *btnView         = [[UIView alloc] init];
    btnView.backgroundColor = DefaultTranslucenceColor;

    [alert addSubview:btnView];
    _btnContainerView       = btnView;
    
    [btnView addConstraint:NSLayoutAttributeLeft equalTo:alert offset:0];
    [btnView addConstraint:NSLayoutAttributeRight equalTo:alert offset:0];
    [btnView addConstraint:NSLayoutAttributeTop equalTo:bodyView toAttribute:NSLayoutAttributeBottom offset:0];
    [self getDefalutFootView:otherButtonTitles cancelButtonTitle:cancelButtonTitle];
    
    [_backgroundAlterView addConstraint:NSLayoutAttributeTop equalTo:self.alertView offset:0];
    [_backgroundAlterView addConstraint:NSLayoutAttributeBottom equalTo:self.alertView offset:0];
    [_backgroundAlterView addConstraint:NSLayoutAttributeLeft equalTo:self.alertView offset:0];
    [_backgroundAlterView addConstraint:NSLayoutAttributeRight equalTo:self.alertView offset:0];
}

- (void)getDefalutTitle:(UIView *)titleView offset:(CGFloat)offset
{
    [self.titleLabel addConstraint:NSLayoutAttributeTop equalTo:titleView toAttribute:NSLayoutAttributeTop offset:offset];
    [self.titleLabel addConstraint:NSLayoutAttributeLeft equalTo:titleView offset:30];
    [self.titleLabel addConstraint:NSLayoutAttributeRight equalTo:titleView offset:-30];
    
}

- (void)getDefalutBody:(UIView *)bodyView
                  text:(NSMutableAttributedString *)text
                  value:(CGFloat)value
{
    self.messageLabel.attributedText = text;
    [bodyView addSubview:self.messageLabel];

    [self.messageLabel addConstraint:NSLayoutAttributeTop equalTo:bodyView toAttribute:NSLayoutAttributeTop offset:value];
    [self.messageLabel addConstraint:NSLayoutAttributeLeft equalTo:bodyView offset:30];
    [self.messageLabel addConstraint:NSLayoutAttributeRight equalTo:bodyView offset:-30];
}

/**
 获取默认的footView(横排的一组buttion)

 @param otherButtonTitles buttion集合
 @param cancelButtonTitle 取消buttion的title
 */
- (void)getDefalutFootView:(NSArray <NSString *>*)otherButtonTitles
         cancelButtonTitle:(NSString *)cancelButtonTitle
{
    int count = (int)otherButtonTitles.count;
    
    if ((cancelButtonTitle && cancelButtonTitle.length > 0) || otherButtonTitles.count > 0) {
        
        [_btnContainerView addConstraint:NSLayoutAttributeHeight equalTo:nil offset:WLAlertBtnHeight];
        
        if (cancelButtonTitle && cancelButtonTitle.length > 0) {
            UIButton *cancelBtn = self.cancelBtn;
            [cancelBtn setTitle:cancelButtonTitle forState:UIControlStateNormal];
            [_btnContainerView addSubview:cancelBtn];
            [self.buttionList addObject:cancelBtn];
            if (otherButtonTitles.count > 0) {
                CGFloat w = (_alterWidth -  count)/(count+1);
                cancelBtn.frame = CGRectMake(0, 0, w, WLAlertBtnHeight);
                UIView *lineView = [UIView new];
                lineView.backgroundColor = DefaultLineTranslucenceColor;
                lineView.frame = CGRectMake(CGRectGetMaxX(cancelBtn.frame), 0, 1, WLAlertBtnHeight);
                [_btnContainerView addSubview:lineView];
                [_lineList addObject:lineView];
                [self createDefalutOtherBtn:otherButtonTitles originX:CGRectGetMaxX(lineView.frame) width:w height:WLAlertBtnHeight];
                
            }else{
                cancelBtn.frame = CGRectMake(0, 0, _alterWidth, WLAlertBtnHeight);
            }
            
        }else{
            CGFloat w = (_alterWidth -  (count - 1))/count;
            [self createDefalutOtherBtn:otherButtonTitles originX:0 width:w height:WLAlertBtnHeight];
        }
        
    }else{
        [_btnContainerView addConstraint:NSLayoutAttributeHeight equalTo:nil offset:0];
    }
    
}

//MARK: --- 创建一排的按钮
- (void)createDefalutOtherBtn:(NSArray <NSString *>*)otherButtonTitles
               originX:(CGFloat)x
                 width:(CGFloat)width
                       height:(CGFloat)height
{
    int i = 0;
    for (NSString *btnTitle in otherButtonTitles) {
        UIButton *otherBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        otherBtn.tag = 101 + i;
        otherBtn.frame = CGRectMake(x + (i*(width+1)), 0, width, height);
        otherBtn.titleLabel.font = WLAlertTextFontMax;
        [otherBtn setTitle:btnTitle forState:UIControlStateNormal];
        [otherBtn setTitleColor:WLAlertTextCommonColor forState:UIControlStateNormal];
        [otherBtn addTarget:self action:@selector(buttionClick:) forControlEvents:UIControlEventTouchUpInside];
        [_btnContainerView addSubview:otherBtn];
        [self.buttionList addObject:otherBtn];

        if (i < otherButtonTitles.count - 1) {
            UIView *lineView = [UIView new];
            lineView.frame = CGRectMake(CGRectGetMaxX(otherBtn.frame), 0, 1, height);
            lineView.backgroundColor = DefaultLineTranslucenceColor;
            [_btnContainerView addSubview:lineView];
            [_lineList addObject:lineView];

        }
        i ++;
    }
}

- (void)setAlertViewFrame
{
    [self.titleView layoutIfNeeded];
    [self.messageContainerView layoutIfNeeded];
    [self.btnContainerView layoutIfNeeded];
    
    //更新alert内部布局约束
    CGFloat alertHeight = CGRectGetHeight(self.titleView.frame) + CGRectGetHeight(self.messageContainerView.frame) + CGRectGetHeight(self.btnContainerView.frame);
    
    if (_layAlertHeight) {
        _layAlertHeight.constant = alertHeight;
        [self.alertView setNeedsUpdateConstraints];
    }else{
        [self.alertView addConstraint:NSLayoutAttributeCenterX equalTo:self offset:0];
        [self.alertView addConstraint:NSLayoutAttributeCenterY equalTo:self offset:0];
        //    [self.alertView addConstraint:NSLayoutAttributeHeight equalTo:nil offset:alertHeight];
        [self.alertView addConstraint:NSLayoutAttributeWidth equalTo:nil offset:_alterWidth];
        _layAlertHeight = [self.alertView addConstraintAndReturn:NSLayoutAttributeHeight equalTo:nil toAttribute:NSLayoutAttributeHeight offset:alertHeight];
    }
    _setFrame = 2;
}

//MARK: ------------------------ 配置信息 -------------------------------
- (void)setAlertViewBackgroundColor:(UIColor *)color
{
    _backgroundColor = color;
    self.alertView.backgroundColor = _backgroundColor;
    self.titleView.backgroundColor = _backgroundColor;
    self.messageContainerView.backgroundColor = _backgroundColor;
    self.btnContainerView.backgroundColor = _backgroundColor;
}

- (void)hiddenAllLineView
{
    for (UIView *line in _lineList) {
        line.backgroundColor = _backgroundColor;
    }
    [self hiddenBodyLineView];
}

- (void)hiddenBodyLineView
{
    for (UIView *line in _bodyLineList) {
        line.backgroundColor = _backgroundColor;
    }
}

- (void)setTitleViewBackColor:(UIColor *)color
{
    self.titleView.backgroundColor = color;
}

- (void)setTitleViewTitleColor:(UIColor *)color
{
    self.titleLabel.textColor = color;
}

- (void)setMessageTitleColor:(UIColor *)color
{
    self.messageLabel.textColor = color;
}

- (void)setAllButtionTitleColor:(UIColor *)color
{
    for (UIButton *btn in self.buttionList) {
        [btn setTitleColor:color forState:UIControlStateNormal];
    }
}

- (void)setButtionTitleColor:(UIColor *)color index:(NSInteger)index
{
    UIButton *btn = [self.btnContainerView viewWithTag:100+index];
    if (btn) {
        [btn setTitleColor:color forState:UIControlStateNormal];
    }
}

- (void)setButtionTitleFontWithName:(NSString *)name
                               size:(CGFloat)size
                              index:(NSInteger)index
{
    UIButton *btn = [self.btnContainerView viewWithTag:100+index];
    if (btn) {
        btn.titleLabel.font = [UIFont fontWithName:name size:size];
    }
}

- (void)setTitleFontWithName:(NSString *)name size:(CGFloat)size
{
    if (name) {
        self.titleLabel.font = [UIFont fontWithName:name size:size];
    }else{
        self.titleLabel.font = [UIFont systemFontOfSize:size];
    }
}

- (void)setMessageFontWithName:(NSString *)name size:(CGFloat)size
{
    if (name) {
        self.messageLabel.font = [UIFont fontWithName:name size:size];
    }else{
        self.messageLabel.font = [UIFont systemFontOfSize:size];
    }
}

- (void)setAlertBackgroundView:(UIImage *)image articulation:(CGFloat)articulation
{
    _backgroundAlterView.hidden = NO;
    _backgroundAlterView.image = image;

    UIColor *newColor = [_backgroundColor colorWithAlphaComponent:articulation];
    self.titleView.backgroundColor = newColor;
    self.messageContainerView.backgroundColor = newColor;
    self.btnContainerView.backgroundColor = newColor;
}

/**
 设置蒙版的背景图
 
 @param image 蒙版的背景图（可使用高斯的image）
 */
- (void)setGaussianBlurImage:(UIImage *)image
{
    self.gaussianBlurOnMaskView.hidden = NO;
    self.gaussianBlurOnMaskView.image = image;
}

/**
 修改tiele（因为考虑到title,一般文字不是很多，所以高度不会变化，默认40）
 
 @param title 提示名称
 */
- (void)resetAlertTitle:(NSString *)title
{
    if (!_title) {//测试代码
        NSString *msg = [NSString stringWithFormat:@"\r\n%@\r\n",title];
        self.titleLabel.text = msg;
    }else{
        self.titleLabel.text = title;
    }
    _setFrame = 1;
    [self setNeedsLayout];
}

//MARK:  ------------  专属协议方法（协议的私有方法）-----------------
- (void)setCustomBodyView:(UIView *)bodyView height:(CGFloat)height
{
    [self.messageContainerView addSubview:bodyView];
    [bodyView addConstraint:NSLayoutAttributeTop equalTo:self.messageContainerView offset:0];
    [bodyView addConstraint:NSLayoutAttributeLeft equalTo:self.messageContainerView offset:5];
    [bodyView addConstraint:NSLayoutAttributeRight equalTo:self.messageContainerView offset:-5];
    [bodyView addConstraint:NSLayoutAttributeHeight equalTo:nil offset:height];
    [self.messageContainerView addConstraint:NSLayoutAttributeBottom equalTo:bodyView offset:1];
}

//MARK:  --------------- 统一参数配置/主题 ---------------------
- (void)setTheme:(id<WLAlertViewThemeProtocol>)theme
{
    if ([theme respondsToSelector:@selector(alertBackgroundView)]) {
        UIImage *img = [theme alertBackgroundView];
        if (img) {
            CGFloat alp = 0;
            if ([theme respondsToSelector:@selector(alterBackgroundViewArticulation)]) {
               alp = [theme alterBackgroundViewArticulation];
            }
            [self setAlertBackgroundView:img articulation:alp];
        }
    }
    if ([theme respondsToSelector:@selector(alertTitleViewColor)]) {
        UIColor *titleColor = [theme alertTitleViewColor];
        if (titleColor) {
            self.titleLabel.textColor = titleColor;
        }
    }
    if ([theme respondsToSelector:@selector(alertCancelColor)]) {
       UIColor *cancelColor = [theme alertCancelColor];
        if (cancelColor) {
            [self.cancelBtn setTitleColor:cancelColor forState:UIControlStateNormal];
        }
    }
    if ([theme respondsToSelector:@selector(alertBackgroundColor)]) {
         UIColor *backgroundColor = [theme alertBackgroundColor];
        [self setAlertViewBackgroundColor:backgroundColor];
    }
    
    CGFloat alp1 = 16;
    if ([theme respondsToSelector:@selector(alertTitleFont)]) {
        alp1 = [theme alertTitleFont];
    }
    if ([theme respondsToSelector:@selector(alertTitleFontWithName)]) {
        [self setTitleFontWithName:[theme alertTitleFontWithName] size:alp1];
    }else{
        [self setTitleFontWithName:nil size:alp1];
    }
    CGFloat alp2 = 14;
    if ([theme respondsToSelector:@selector(alertMessageFont)]) {
        alp2 = [theme alertMessageFont];
    }
    if ([theme respondsToSelector:@selector(alertMessageFontWithName)]) {
        [self setMessageFontWithName:[theme alertMessageFontWithName] size:alp2];
    }else{
        [self setMessageFontWithName:nil size:alp2];
    }

}

//MARK: ----------------------- getter & setter --------------------
- (UIButton *)cancelBtn
{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.tag = 100;
        _cancelBtn.titleLabel.font = WLAlertTextFontMax;
        [_cancelBtn setTitleColor:WLAlertTextCommonColor forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(buttionClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectZero];
        _maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        _maskView.backgroundColor = [UIColor colorWithRed:10 / 255.0 green:10 / 255.0 blue:10 / 255.0 alpha:0.0];
        _maskView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5];
        _maskView.alpha = 0;
    }
    return _maskView;
}

- (UIImageView *)gaussianBlurOnMaskView
{
    if (!_gaussianBlurOnMaskView) {
        _gaussianBlurOnMaskView                  = [UIImageView new];
        _gaussianBlurOnMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _gaussianBlurOnMaskView.hidden           = YES;
    }
    return _gaussianBlurOnMaskView;
}

- (UIView *)titleView
{
    if (!_titleView) {
        _titleView                 = [UIView new];
        _titleView.backgroundColor = DefaultTranslucenceColor;
    }
    return _titleView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel               = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font          = WLAlertTextFontMax;
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UILabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel               = [UILabel new];
        [_messageLabel setLineBreakMode:NSLineBreakByWordWrapping];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
        _messageLabel.font          = WLAlertTextFontMid;
    }
    return _messageLabel;
}

- (NSMutableArray *)buttionList
{
    if (!_buttionList) {
        _buttionList = [NSMutableArray new];
    }
    return _buttionList;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setAlertViewFrame];
    NSLog(@"%s",__func__);
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
    _lineList = nil;
    _bodyLineList = nil;
    _maskView = nil;
    _alertView = nil;
    _gaussianBlurOnMaskView = nil;
    _titleView = nil;
    _titleLabel = nil;
    _messageContainerView = nil;
    _messageLabel = nil;
    _btnContainerView = nil;
    _cancelBtn = nil;
    _buttionList = nil;
    _backgroundAlterView = nil;
    _backgroundColor = nil;
}
@end
