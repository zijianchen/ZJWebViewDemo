//
//  WKWebViewController.h
//  ZJWebViewDemo
//
//  Created by max on 2019/3/5.
//  Copyright © 2019 陈子健. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebViewController : UIViewController

/**
 加载外部链接网页
 
 @param str URL地址
 */
- (void)loadWebURLSring:(NSString *)str;

/**
 加载本地网页
 
 @param str 本地HTML文件名称
 */
- (void)loadWebHTMLStr:(NSString *)str;

/** 是否显示Nav */
@property (nonatomic,assign) BOOL isNavHidden;

@end

NS_ASSUME_NONNULL_END
