//
//  WKWebViewController.m
//  ZJWebViewDemo
//
//  Created by max on 2019/3/5.
//  Copyright © 2019 陈子健. All rights reserved.
//

#import "WKWebViewController.h"

// 导入web相关框架
#import <WebKit/WKWebView.h>
#import <WebKit/WebKit.h>

typedef enum{
    kLoadWebURLString = 0,
    kLoadWebHTMLString,
    kPOSTWebURLString,
}ZJWebLoadType;

static void *WkwebBrowserContext = &WkwebBrowserContext;

@interface WKWebViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler,UINavigationControllerDelegate,UINavigationBarDelegate>

// 网页视图
@property (nonatomic, strong) WKWebView *wkWebView;
// 网页加载的类型
@property(nonatomic,assign) ZJWebLoadType loadType;
// 加载进度条
@property (nonatomic,strong) UIProgressView *progressView;
// 保存的网址链接
@property (nonatomic, copy) NSString *URLString;
// 保存POST请求体
@property (nonatomic, copy) NSString *postData;
// 仅当第一次的时候需要加载本地JS
@property(nonatomic,assign) BOOL isLoadJSPOST;
// 保存请求链接
@property (nonatomic)NSMutableArray* snapShotsArray;
// 返回按钮
@property (nonatomic)UIBarButtonItem* customBackBarItem;
// 关闭按钮
@property (nonatomic)UIBarButtonItem* closeButtonItem;

@end

@implementation WKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1.加载web页面
    [self loadWebView];
    // 2.添加webView到父视图
    [self.view addSubview:self.wkWebView];
    // 3.添加进度条
    [self.view addSubview:self.progressView];
    // 4.添加导航栏右侧刷新按钮
    [self setNavBtn];
     
    // Do any additional setup after loading the view.
}

// 当视图将要呈现的时候
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 若设置隐藏了导航栏，则创建一个假的状态栏
    if (_isNavHidden == YES) {
        self.navigationController.navigationBarHidden = YES;
        // 创建一个高20的假状态栏
        UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
        // 设置成绿色
        statusBarView.backgroundColor=[UIColor whiteColor];
        // 添加到 navigationBar 上
        [self.view addSubview:statusBarView];
    }else{
        self.navigationController.navigationBarHidden = NO;
    }
    
}

- (void)loadWebView {
    switch (self.loadType) {
        case kLoadWebURLString:{
            // 创建一个NSURLRequest对象
            NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.URLString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
            // 加载网页
            [self.wkWebView loadRequest:request];
            break;
        }
        case kLoadWebHTMLString:{
            [self loadHostPathURL:self.URLString];
            break;
        }
        case kPOSTWebURLString:{
            // 若需要加载外部链接POST请求，则设置 needLoadJSPOST 为 YES
            self.isLoadJSPOST = YES;
            // POST使用预先加载本地JS方法的html实现，请确认WKJSPOST存在
            [self loadHostPathURL:@"JSPOST"];
            break;
        }
    }
}

- (void)setNavBtn {
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction)];
    self.navigationItem.rightBarButtonItem = refreshItem;
}

// 刷新web视图
- (void)refreshAction {
    [self.wkWebView reload];
}

- (void)customBackItemClicked {
    if (self.wkWebView.goBack) {
        [self.wkWebView goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)closeItemClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

// 加载URL
- (void)loadHostPathURL:(NSString *)url {
    // 获取JS所在文件路径
//    NSString *path = [[NSBundle mainBundle] pathForResource:url ofType:@"html"];
//    // 获得html内容
//    NSString *html = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"%@==",html);
    // 加载js
    [self.wkWebView loadHTMLString:@"index" baseURL:[[NSBundle mainBundle] bundleURL]];
}

// 调用JS发送POST请求
- (void)postRequestWithJS {
    // 拼装成调用JavaScript的字符串
    NSString *jscript = [NSString stringWithFormat:@"post('%@',{%@});", self.URLString, self.postData];
    // 调用JS代码
    [self.wkWebView evaluateJavaScript:jscript completionHandler:^(id object, NSError * _Nullable error) {
    }];
}

- (void)loadWebURLStr:(NSString *)string{
    self.URLString = string;
    self.loadType = kLoadWebURLString;
}

- (void)loadWebHTMLStr:(NSString *)string{
    self.URLString = string;
    self.loadType = kLoadWebHTMLString;
}

- (void)POSTWebURLStr:(NSString *)string postData:(NSString *)postData{
    self.URLString = string;
    self.postData = postData;
    self.loadType = kPOSTWebURLString;
}

#pragma mark - WKNavigationDelegate

// 监听网页开始加载
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    // 开始加载的时候，让加载进度条显示
    self.progressView.hidden = NO;
    // 开始加载网页的时候将progressView的Height恢复为1.5倍
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    // 防止progressView被网页挡住
    [self.view bringSubviewToFront:self.progressView];
}

// 监听内容返回
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
}

// 监听服务器请求跳转
-(void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
}

// 监听网页加载完成
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // TODO: 该方法是当网页内容全部加载完毕的时候才调用
    // 判断是否需要加载（仅在第一次加载）
    if (self.isLoadJSPOST) {
        // 调用使用JS发送POST请求的方法
        [self postRequestWithJS];
        // 将 isLoadJSPOST 设置为 NO（后面就不需要加载了）
        self.isLoadJSPOST = NO;
    }
    // 获取加载网页的标题
    self.title = self.wkWebView.title;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // 更新导航栏的内容:自定义返回/关闭按钮
    [self updateNavigationItems];
}

// 内容加载失败时候调用
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"页面加载超时");
}

// 跳转失败的时候调用
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"跳转失败");
}

// 进度条
-(void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    
}

// 监听服务器开始请求
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    switch (navigationAction.navigationType) {
        case WKNavigationTypeLinkActivated: {
            [self pushCurrentSnapshotViewWithRequest:navigationAction.request];
            break;
        }
        case WKNavigationTypeFormSubmitted: {
            [self pushCurrentSnapshotViewWithRequest:navigationAction.request];
            break;
        }
        case WKNavigationTypeBackForward: {
            break;
        }
        case WKNavigationTypeReload: {
            break;
        }
        case WKNavigationTypeFormResubmitted: {
            break;
        }
        case WKNavigationTypeOther: {
            [self pushCurrentSnapshotViewWithRequest:navigationAction.request];
            break;
        }
        default: {
            break;
        }
    }
    [self updateNavigationItems];
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 更新导航栏
- (void)updateNavigationItems {
    if (self.wkWebView.canGoBack) {
        UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceButtonItem.width = -6.5;
        
        [self.navigationItem setLeftBarButtonItems:@[spaceButtonItem,self.customBackBarItem,self.closeButtonItem] animated:NO];
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        [self.navigationItem setLeftBarButtonItems:@[self.customBackBarItem]];
    }
}

// 请求链接处理
- (void)pushCurrentSnapshotViewWithRequest:(NSURLRequest*)request{
    // NSLog(@"push with request %@",request);
    NSURLRequest* lastRequest = (NSURLRequest*)[[self.snapShotsArray lastObject] objectForKey:@"request"];
    
    // 如果url是很奇怪的就不push
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        // NSLog(@"about blank!! return");
        return;
    }
    // 如果url一样就不进行push
    if ([lastRequest.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
        return;
    }
    UIView* currentSnapShotView = [self.wkWebView snapshotViewAfterScreenUpdates:YES];
    [self.snapShotsArray addObject:
     @{@"request":request,@"snapShotView":currentSnapShotView}];
}


#pragma mark - WKUIDelegate

// 获取js 里面的提示
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
}

// js 信息的交流
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

// 交互：可输入的文本。
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"textinput" message:@"JS调用输入框" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor redColor];
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
    
}

// KVO监听进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.wkWebView) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.wkWebView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.wkWebView.estimatedProgress animated:animated];
        
        // Once complete, fade out UIProgressView
        if(self.wkWebView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - WKScriptMessageHandler

// 拦截执行网页中的JS方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    // 服务器固定格式写法 window.webkit.messageHandlers.名字.postMessage(内容);
    // 客户端写法 message.name isEqualToString:@"名字"]
    if ([message.name isEqualToString:@"WXPay"]) {
        NSLog(@"%@", message.body);
        // 调用微信支付方法
        // [self WXPayWithParam:message.body];
    }
}


#pragma mark - 懒加载

- (WKWebView *)wkWebView {
    if (!_wkWebView) {
        // 设置网页的配置文件
        WKWebViewConfiguration * Configuration = [[WKWebViewConfiguration alloc]init];
        // 允许视频播放
        Configuration.allowsAirPlayForMediaPlayback = YES;
        // 允许在线播放
        Configuration.allowsInlineMediaPlayback = YES;
        // 允许可以与网页交互，选择视图
        Configuration.selectionGranularity = YES;
        // web内容处理池
        Configuration.processPool = [[WKProcessPool alloc] init];
        //自定义配置,一般用于 js调用oc方法(OC拦截URL中的数据做自定义操作)
        WKUserContentController * UserContentController = [[WKUserContentController alloc]init];
        // 添加消息处理，注意：self指代的对象需要遵守WKScriptMessageHandler协议，结束时需要移除
        [UserContentController addScriptMessageHandler:self name:@"WXPay"];
        // 是否支持记忆读取
        Configuration.suppressesIncrementalRendering = YES;
        // 允许用户更改网页的设置
        Configuration.userContentController = UserContentController;
        _wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:Configuration];
        _wkWebView.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
        // 设置代理
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
        // kvo 添加进度监控
        [_wkWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:WkwebBrowserContext];
        // 开启手势触摸
        _wkWebView.allowsBackForwardNavigationGestures = YES;
        // 设置 可以前进 和 后退
        //适应你设定的尺寸
        [_wkWebView sizeToFit];
    }
    return _wkWebView;
}

- (UIBarButtonItem*)customBackBarItem{
    if (!_customBackBarItem) {
        UIImage* backItemImage = [[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* backItemHlImage = [[UIImage imageNamed:@"back_hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        UIButton* backButton = [[UIButton alloc] init];
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        [backButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        [backButton setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [backButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [backButton setImage:backItemImage forState:UIControlStateNormal];
        [backButton setImage:backItemHlImage forState:UIControlStateHighlighted];
        [backButton sizeToFit];
        
        [backButton addTarget:self action:@selector(customBackItemClicked) forControlEvents:UIControlEventTouchUpInside];
        _customBackBarItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    return _customBackBarItem;
}

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        if (_isNavHidden == YES) {
            _progressView.frame = CGRectMake(0, 20, self.view.bounds.size.width, 3);
        }else{
            _progressView.frame = CGRectMake(0, 64, self.view.bounds.size.width, 3);
        }
        // 设置进度条的色彩
        [_progressView setTrackTintColor:[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0]];
        _progressView.progressTintColor = [UIColor blueColor];
    }
    return _progressView;
}

-(UIBarButtonItem*)closeButtonItem {
    if (!_closeButtonItem) {
        _closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeItemClicked)];
    }
    return _closeButtonItem;
}

- (NSMutableArray*)snapShotsArray {
    if (!_snapShotsArray) {
        _snapShotsArray = [NSMutableArray array];
    }
    return _snapShotsArray;
}

// 当视图即将消失的时候调用
- (void)viewWillDisappear:(BOOL)animated{
    [self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:@"WXPay"];
    [self.wkWebView setNavigationDelegate:nil];
    [self.wkWebView setUIDelegate:nil];
}

// 对象释放时把观察者移除
- (void)dealloc {
    [self.wkWebView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
