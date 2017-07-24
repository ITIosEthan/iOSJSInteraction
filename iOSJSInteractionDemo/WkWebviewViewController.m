//
//  WkWebviewViewController.m
//  iOSJSInteractionDemo
//
//  Created by macOfEthan on 17/7/24.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import "WkWebviewViewController.h"
#import <WebKit/WebKit.h>

//WKScriptMessageHandler 处理交互
//WKUIDelegate 处理弹框 关闭webview
//WKNavigationDelegate 处理加载相关
@interface WkWebviewViewController ()<WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate>
@property (weak, nonatomic) IBOutlet UITextField *first;
@property (weak, nonatomic) IBOutlet UITextField *second;
@property (nonatomic, strong) WKWebView *webview;
@end

@implementation WkWebviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //加载html文件
    [self localHtml];
}

#pragma mark - 加载本地js 拦截js方法
- (void)localHtml
{
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    
    //创建UserContentController（提供JavaScript向webView发送消息的方法）
    WKUserContentController *contentVc = [[WKUserContentController alloc] init];
    
    // 添加消息处理，注意：self指代的对象需要遵守WKScriptMessageHandler协议，
    // 细节： 结束时需要移除 内存泄露
    //name 必须与js里边 window.webkit.messageHandlers.customName.postMessage(message) 一致 不然不会走didReceiveScriptMessage 方法
    [contentVc addScriptMessageHandler:self name:@"customName"];
    
    
    //结束时需要移除
    //[self.webview.configuration.userContentController removeScriptMessageHandlerForName:@"customName"];
    
    //将UserConttentController设置到配置文件
    config.userContentController = contentVc;
    
    self.webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300) configuration:config];
    
    //WKUIDelegate 处理webView加载完成 关闭 alter prompt confirm三种提示框 看代理
    self.webview.UIDelegate = self;
    //WKNavigationDelegate 处理加载进度
    self.webview.navigationDelegate = self;
    
    [self.view addSubview:self.webview];
    
    //加载本地html文件
    NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSString *htmlContents = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSURL *baseUrl = [[NSBundle mainBundle] bundleURL];
    
    [self.webview loadHTMLString:htmlContents baseURL:baseUrl];
    
    //禁止滚动
    self.webview.scrollView.bounces = NO;
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"name = %@ \n body = %@ \n url = %@", message.name, message.body, message.frameInfo.request.URL);
    
    if ([message.name isEqualToString:@"customName"]) {
        
        [self showMessage:message.name title:message.body];
        
    }
}


- (IBAction)add:(UIButton *)sender {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *resultStr = [NSString stringWithFormat:@"add(%@, %@)", _first.text, _second.text];
    
    [self.webview evaluateJavaScript:resultStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
        [weakSelf showMessage:[NSString stringWithFormat:@"oc调用js加法结果为：%@", result] title:nil];
    }];
}

- (void)showMessage:(NSString *)message title:(NSString *)title
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:message message:title preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"sure" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:sure];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}


#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler
{
    
    NSLog(@"js弹框提示=%@, js弹框内容=%@", prompt, defaultText);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:prompt message:defaultText preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入内容";
        textField.secureTextEntry = NO;
    }];
    
    __weak typeof(alert) weakAlert = alert;
    
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"sure" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //读取文本
        UITextField *tf = weakAlert.textFields.firstObject;
        
        // 返回到js 这个结果会调用runJavaScriptAlertPanelWithMessage弹出
        completionHandler(tf.text);
    }];
    
    [alert addAction:sure];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}


- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    NSLog(@"message=%@", message);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:message message:frame.request.URL.absoluteString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"sure" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        completionHandler(YES);
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }];
    
    [alert addAction:sure];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

//js中每有一个alert走一次
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    NSLog(@"message=%@", message);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:message message:frame.request.URL.absoluteString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"sure" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        completionHandler();
    }];
    
    [alert addAction:sure];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{

}


- (IBAction)deallocJump:(UIButton *)sender {
    
    NSLog(@"czyDealloc %p  %p", self.webview, self.webview.configuration.userContentController);
    
    //结束时需要移除
    [self.webview.configuration.userContentController removeScriptMessageHandlerForName:@"customName"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - dealloc
- (void)dealloc
{
    //控制器释放了 _webview并没有释放
    _webview = nil;
    
    NSLog(@"insturment检查没有内存泄露 但是不走dealloc 原来是因为之前写在根控制器viewController中 viewController 好坑");
    //insturment检查没有内存泄露 但是不走dealloc 原来是因为再跟控制器中
    NSLog(@"dealloc");
}


@end
