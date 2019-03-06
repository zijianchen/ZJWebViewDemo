//
//  ViewController.m
//  ZJWebViewDemo
//
//  Created by max on 2019/3/5.
//  Copyright © 2019 陈子健. All rights reserved.
//

#import "ViewController.h"

#import "WKWebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUI];
}

-(void)setUI {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setFrame:CGRectMake((self.view.bounds.size.width/2)-100, (self.view.bounds.size.height/2)-25, 200, 50)];
    [btn setTitle:@"跳转网址" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(jumpLinkAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
}

// 跳转到网页视图控制器
-(void)jumpLinkAction {
    WKWebViewController *webController = [[WKWebViewController alloc] init];
    
    // test1: 加载外部链接网页
    [webController loadWebURLStr:@"https://www.baidu.com"];
    
    [self.navigationController pushViewController:webController animated:YES];
}

@end
