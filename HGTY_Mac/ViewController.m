//
//  ViewController.m
//  HGTY_Mac
//
//  Created by david on 2018/12/3.
//  Copyright © 2018 david. All rights reserved.
//

//https://www.cesu6668.com
//https://www.cesu0086.com
//
//https://www.cesu6668.com/dataInterface.php?type=client
//https://www.cesu0086.com/dataInterface.php?type=client

//颜色
#define ColorHexWithAlpha(n,a) ([NSColor colorWithRed:((float)((n &0xFF0000) >> 16))/255.0 green:((float)((n & 0xFF00)>> 8))/255.0 blue:((float)(n & 0xFF))/255.0 alpha:a])
#define ColorHex(n) (ColorHexWithAlpha(n,1.0))


#import "ViewController.h"

@implementation ViewController {
    NSView *topBar;
    NSView *webContent;
    
    NSDictionary *list;
//    NSButton *ruteButton;
    NSComboBox *comboBox;
    NSInteger comboBoxIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    topBar = [[NSView alloc] initWithFrame:NSMakeRect(0, self.view.frame.size.height-80, self.view.frame.size.width, 80)];
    [topBar setWantsLayer:YES];
    [topBar.layer setBackgroundColor:ColorHex(0x493822).CGColor];
    [self.view addSubview:topBar];
    webContent = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, self.view.frame.size.width, self.view.frame.size.height-80)];
    [self.view addSubview:webContent];
    self.hgWebView = [[WKWebView alloc] initWithFrame:webContent.bounds];
    [webContent addSubview:_hgWebView];
    
    [self requstList];
}

- (void)setupTopbar {
    NSImage *logoImg = [NSImage imageNamed:@"logo"];
    CGFloat height = 50;
    CGFloat width = logoImg.size.width/logoImg.size.height*50;
    NSImageView *logo = [[NSImageView alloc] initWithFrame:NSMakeRect(30, 15, width, height)];
    logo.imageScaling = NSImageScaleAxesIndependently;
    logo.imageAlignment = NSImageAlignTopRight;
    logo.image = logoImg;
    [topBar addSubview:logo];
    
    NSArray *data = [list objectForKey:@"data"];
    comboBox = [[NSComboBox alloc] initWithFrame:NSMakeRect(width+90, 35, 160, 30)];
    [comboBox addItemWithObjectValue:@"默认线路"];
    for (int i = 0; i < data.count; i++) {
        NSDictionary *dict = data[i];
        NSString *name = [dict objectForKey:@"name"];
        [comboBox addItemWithObjectValue:name];
    }
    [topBar addSubview:comboBox];
    [comboBox selectItemAtIndex:comboBoxIndex];
    comboBox.delegate = self;
    
    
    NSButton *back = [[NSButton alloc] initWithFrame:NSMakeRect(width+300, 38, 26, 26)];
    back.bordered = NO;
    [back setImage:[NSImage imageNamed:@"back"]];
    back.imageScaling = NSImageScaleAxesIndependently;
    [topBar addSubview:back];
    [back setAction:@selector(onBack)];
    
    NSButton *front = [[NSButton alloc] initWithFrame:NSMakeRect(width+360, 38, 26, 26)];
    front.bordered = NO;
    [front setImage:[NSImage imageNamed:@"front"]];
    front.imageScaling = NSImageScaleAxesIndependently;
    [topBar addSubview:front];
    [front setAction:@selector(onFront)];
    
    NSButton *refresh = [[NSButton alloc] initWithFrame:NSMakeRect(width+420, 38, 26, 26)];
    refresh.bordered = NO;
    [refresh setImage:[NSImage imageNamed:@"refresh"]];
    refresh.imageScaling = NSImageScaleAxesIndependently;
    [topBar addSubview:refresh];
    [refresh setAction:@selector(onRefresh)];
}

- (void)onBack {
    [self.hgWebView goBack];
}

- (void)onFront {
    [self.hgWebView goForward];
}

- (void)onRefresh {
    [self.hgWebView reload];
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    comboBoxIndex = comboBox.indexOfSelectedItem;
    NSLog(@"comboBox:%li",comboBoxIndex);
    [self loadHomePage];
}


- (void)loadHomePage {
    NSString *urlstring = @"";
    if (comboBoxIndex == 0) {
        urlstring = [list objectForKey:@"default_url"];
    } else {
        NSInteger ind = comboBoxIndex-1;
        NSArray *data = [list objectForKey:@"data"];
        NSDictionary *dict = data[ind];
        urlstring = [dict objectForKey:@"url"];
    }
    NSURL *url = [NSURL URLWithString:urlstring];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self.hgWebView loadRequest:request];
}

- (void)requstList {
    NSString *urlString = @"";
    NSString *listUrlString = @"";
    if (PRODUCT == 1) {
        urlString = @"https://www.cesu6668.com/";
        listUrlString = @"https://www.cesu6668.com/dataInterface.php?type=client";
    } else if (PRODUCT == 2) {
        urlString = @"https://www.cesu0086.com/";
        listUrlString = @"https://www.cesu0086.com/dataInterface.php?type=client";
    }
    
    NSURL *listUrl = [NSURL URLWithString:listUrlString];
    NSData *listData = [NSData dataWithContentsOfURL:listUrl];
    if (!listData) {
        [self cannotGetList];
        return;
    }
    list = [NSJSONSerialization JSONObjectWithData:listData options:0 error:nil];//获取到线路列表
    if (!list) {
        [self cannotGetList];
        return;
    }
    [self setupTopbar];
    [self loadHomePage];
}

- (void)cannotGetList {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"确定"];
    [alert addButtonWithTitle:@"取消"];
    [alert setMessageText:@"确定删除输入文本?"];
    [alert setInformativeText:@"如果确定删除，删除的文本不能再找回!"];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSAlertFirstButtonReturn){
            NSLog(@"确定");
        }else if(returnCode == NSAlertSecondButtonReturn){
            NSLog(@"删除");
        }
    }];
}





- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}

//页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"页面开始加载时调用。   2");
}
//内容返回时调用，得到请求内容时调用(内容开始加载) -> view的过渡动画可在此方法中加载
- (void)webView:(WKWebView *)webView didCommitNavigation:( WKNavigation *)navigation {
    NSLog(@"内容返回时调用，得到请求内容时调用。 4");
}
//页面加载完成时调用
- (void)webView:(WKWebView *)webView didFinishNavigation:( WKNavigation *)navigation {
    NSLog(@"页面加载完成时调用。 5");
}
//请求失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"error1:%@",error);
}
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"error2:%@",error);
}
//在请求发送之前，决定是否跳转 -> 该方法如果不实现，系统默认跳转。如果实现该方法，则需要设置允许跳转，不设置则报错。
//该方法执行在加载界面之前
//Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Completion handler passed to -[ViewController webView:decidePolicyForNavigationAction:decisionHandler:] was not called'
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    
    //不允许跳转
    //    decisionHandler(WKNavigationActionPolicyCancel);
    NSLog(@"在请求发送之前，决定是否跳转。  1");
}
//在收到响应后，决定是否跳转（同上）
//该方法执行在内容返回之前
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //    decisionHandler(WKNavigationResponsePolicyCancel);
    NSLog(@"在收到响应后，决定是否跳转。 3");
    
}
//接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"接收到服务器跳转请求之后调用");
}
-(void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    NSLog(@"webViewWebContentProcessDidTerminate");
}





@end
