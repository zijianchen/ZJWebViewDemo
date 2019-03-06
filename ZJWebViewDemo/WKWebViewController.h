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
- (void)loadWebURLStr:(NSString *)str;

/**
 加载本地网页
 
 @param str 本地HTML文件名称
 */
- (void)loadWebHTMLStr:(NSString *)str;

/** 是否显示Nav */
@property (nonatomic,assign) BOOL isNavHidden;

/**
 加载外部链接POST请求(需预先加载本地JS方法的html实现，请检查 JSPOST.html 文件是否存在 )
 
 @param str 需要POST的URL地址
 @param postData post请求块，格式：@"\"username\":\"xxxx\",\"password\":\"xxxx\""
 */
- (void)POSTWebURLStr:(NSString *)str postData:(NSString *)postData;

@end

NS_ASSUME_NONNULL_END
