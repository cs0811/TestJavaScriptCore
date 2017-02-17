//
//  ViewController.m
//  TestJavaScriptCore
//
//  Created by tongxuan on 17/2/17.
//  Copyright © 2017年 tongxuan. All rights reserved.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@protocol WebExport <JSExport>

JSExportAs(log,
           - (void)ocLog:(NSString *)str
           );

@end

@interface ViewController ()<UIWebViewDelegate, WebExport>
@property (nonatomic, strong) UIWebView * webView;
@property (nonatomic, strong) JSContext * context;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.webView.frame = self.view.bounds;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
//    NSString * htmlUrl = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"js"];
//    NSString * html = [NSString stringWithContentsOfFile:htmlUrl encoding:NSUTF8StringEncoding error:nil];
//    [self.webView loadHTMLString:html baseURL:nil];
    
    NSString *path = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent:@"test.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
    [self.webView loadRequest:request];
}

- (void)ocLog:(NSString *)str {
    NSLog(@"oc %@",str);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    // 以 html title 设置 导航栏 title
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    // 禁用 页面元素选择
    //[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    
    // 禁用 长按弹出ActionSheet
    //[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
    
    self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //验证JSContext对象是否初始化成功
    self.context.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue)
    {
        context.exception = exceptionValue;
        NSLog(@"%@", exceptionValue);
    };
    
    // JS  ->  OC
    // 方法一
    self.context[@"log"] = ^(NSString *string){
        
        NSLog(@"%@",string);
        
    };
    
    // 方法二
        // WebExport
    self.context[@"native"] = self;
    
    
    // OC  ->  JS
    JSValue * fuction = self.context[@"fun1"];
    JSValue * result = [fuction callWithArguments:@[@2,@6]];
    NSLog(@"..%@",[result toNumber]);
}


#pragma mark - Getter
- (UIWebView *)webView {
    if (!_webView) {
        _webView = [UIWebView new];
    }
    return _webView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
