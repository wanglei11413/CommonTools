#import "BasicViewController.h"
#import "UIImage+ChangedColor.h"

@interface BasicViewController ()

@end

@implementation BasicViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = APP_BasicColor;
    //设置导航栏返回箭头文字
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    // 导航栏大标题
    if (@available(iOS 11.0, *)) {
        [navBar setPrefersLargeTitles:NO];
    }
    // 是否不允许透明效果
    [navBar setTranslucent:_navUnTranslucent ? NO : YES];
    // 导航栏渲染风格
    [navBar setBarStyle:_navBarStyle ?: UIBarStyleDefault];
    // 导航栏图标渲染颜色
    [navBar setBarTintColor:[UIColor whiteColor]];
    [navBar setTintColor:_navTintColor ?: [UIColor whiteColor]];
    // 字体适配
    NSString *fontScaleStr = USERDEFAULT_float(CONTENT_FONT);
    CGFloat fontScale = [fontScaleStr floatValue];
    // 字体字典
    NSDictionary *textAttDic = @{ NSForegroundColorAttributeName:_navTextColor ?: [UIColor whiteColor], NSFontAttributeName: [UIFont systemFontOfSize:14.0*fontScale]};
    
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        // 设置文字大小颜色
        appearance.titleTextAttributes = textAttDic;
        // 设置导航栏背景色
        appearance.backgroundImage = [UIImage new];
        appearance.backgroundColor = _navBackgroundColor ?: APP_MainColor;
        // 设置分割线颜色
        appearance.shadowColor = _navShadowImage ? APP_LineColor : (_navBackgroundColor ?: APP_MainColor);
        
        appearance.backgroundEffect = nil;
        navBar.standardAppearance = appearance;
        navBar.scrollEdgeAppearance = appearance;
        
        [UITableView appearance].sectionHeaderTopPadding = 0;
        
    } else {
        // 设置文字大小颜色
        [navBar setTitleTextAttributes:textAttDic];
        // 导航栏背景颜色
        [navBar setBackgroundImage:[UIImage imageWithColor:_navBackgroundColor ?: APP_MainColor size:CGSizeMake(1, 1)] forBarMetrics:UIBarMetricsDefault];
        // 导航栏分割线
        UIColor *shadowColor = _navShadowImage ? (_navBackgroundColor ?: APP_MainColor) : APP_LineColor;
        [navBar setShadowImage:[UIImage imageWithColor:shadowColor size:CGSizeMake(1, 1)]];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.statusBarIsLight) {
        return UIStatusBarStyleLightContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
