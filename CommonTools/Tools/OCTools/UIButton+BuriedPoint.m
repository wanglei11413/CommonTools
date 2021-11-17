//
//  UIButton+BuriedPoint.m
//  Davinci
//  全局埋点button拦截
//  Created by Miracle on 2021/6/21.
//

#import "UIButton+BuriedPoint.h"
#import <objc/message.h>

@implementation UIButton (BuriedPoint)


+ (void)load{
    
    [super load];
    
    //拿到sendAction方法，
    Method oldObjectAtIndex =class_getInstanceMethod([UIButton class],@selector(sendAction:to:forEvent:));
    
    //定义一个新的方法custom_sendAction
    Method newObjectAtIndex =class_getInstanceMethod([UIButton class], @selector(custom_sendAction:to:forEvent:));
    
    //交换两个方法的指针
    method_exchangeImplementations(oldObjectAtIndex, newObjectAtIndex);
    
}


- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
    [super sendAction:action to:target forEvent:event];
}


/// 自定义方法，替换系统按钮点击方法
/// @param action 点击事件
/// @param target 当前所在控制器
/// @param event 点击方式
- (void)custom_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
    
    [self custom_sendAction:action to:target forEvent:event];
    
    //获取点击按钮所在的类名、点击事件名称、按钮名称
    NSString * className = NSStringFromClass([target class]);
    NSString * btnName = self.titleLabel.text;
    NSString * actionName = NSStringFromSelector(action);
    
    //从plist文件中找到对应埋点事件数据
    NSString * sourcePath = [[NSBundle mainBundle]pathForResource:@"DAVBuriedPointSource" ofType:@"plist"];
    NSDictionary * sourceDic = [NSDictionary dictionaryWithContentsOfFile:sourcePath];
    
    //首先比对类名 有则查找按钮名称/点击事件名称
    NSDictionary * classDic = sourceDic[className];
    if (classDic) {
        //查找按钮名称或者点击事件
        NSDictionary * btnDic = classDic[btnName];
        NSDictionary * actionDic = classDic[actionName];
        if (btnDic) {
//            [CommonManage event:btnDic[@"eventName"] attributes:nil];
        }
        if (actionDic) {
//            [CommonManage event:actionDic[@"eventName"] attributes:nil];
        }
    }
    
}

@end
