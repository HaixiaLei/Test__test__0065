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
#define TabWidth 200



#import "ViewController.h"

@implementation ViewController {
    NSView *topBar;
    NSView *webContent;
    
    NSDictionary *list;
//    NSButton *ruteButton;
    NSComboBox *comboBox;
    NSInteger comboBoxIndex;
    WKWebView *currentWebview;
    NSButton *homeButton;
    NSScrollView *tabScroll;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    topBar = [[NSView alloc] initWithFrame:NSMakeRect(0, self.view.frame.size.height-80, self.view.frame.size.width, 80)];
    [topBar setWantsLayer:YES];
    
    if (PRODUCT == 1 ||
        PRODUCT == 2) {
        [topBar.layer setBackgroundColor:ColorHex(0x493822).CGColor];
    } else if (PRODUCT == 3 || PRODUCT == 4 || PRODUCT == 5) {
        [topBar.layer setBackgroundColor:ColorHex(0xc52e28).CGColor];
    }
    [self.view addSubview:topBar];
    webContent = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, self.view.frame.size.width, self.view.frame.size.height-80)];
    [self.view addSubview:webContent];
    self.hgWebView = [[WKWebView alloc] initWithFrame:webContent.bounds];
    self.hgWebView.UIDelegate = self;
    self.hgWebView.navigationDelegate = self;
    currentWebview = self.hgWebView;
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
    comboBox = [[NSComboBox alloc] initWithFrame:NSMakeRect(width+80, 35, TabWidth, 30)];
//    [comboBox addItemWithObjectValue:@"默认线路"];
    for (int i = 0; i < data.count; i++) {
        NSDictionary *dict = data[i];
        NSString *name = [dict objectForKey:@"name"];
        [comboBox addItemWithObjectValue:name];
    }
    [topBar addSubview:comboBox];
    [comboBox selectItemAtIndex:comboBoxIndex];
    comboBox.delegate = self;
    
    homeButton = [[NSButton alloc] initWithFrame:NSMakeRect(comboBox.frame.origin.x, -1, 100, 25)];
    homeButton.tag = 1000;
    [homeButton setAction:@selector(tabButton:)];
    homeButton.wantsLayer = YES;
    homeButton.title = @"首页";
    homeButton.wantsLayer = YES;
    homeButton.layer.backgroundColor = ColorHex(0xffffff).CGColor;
    [self setButton:homeButton highLight:YES];
    [topBar addSubview:homeButton];
    
    
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

- (void)setButton:(NSButton *)btn highLight:(BOOL)highLight {
    NSMutableParagraphStyle *pghStyle = [[NSMutableParagraphStyle alloc] init];
    pghStyle.alignment = NSTextAlignmentCenter;
    NSColor *color;
    if (highLight) {
        color = ColorHex(0x000000);
    } else {
        color = ColorHex(0x707070);
    }
    NSDictionary *dicAtt = @{NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: pghStyle};
    btn.attributedTitle = [[NSAttributedString alloc] initWithString:btn.title attributes:dicAtt];
}

- (void)onBack {
    [currentWebview goBack];
}

- (void)onFront {
    [currentWebview goForward];
}

- (void)onRefresh {
    [currentWebview reload];
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    comboBoxIndex = comboBox.indexOfSelectedItem;
    NSLog(@"comboBox:%li",comboBoxIndex);
    [self loadHomePage];
    
    _hgWebView.hidden = NO;
    [self setButton:homeButton highLight:YES];
    
    
    
    //清空所有
    for (WKWebView *web in _webviewArray) {
        [web removeFromSuperview];
    }
    [_webviewArray removeAllObjects];
    for (NSView *view in _tabButtons) {
        [view removeFromSuperview];
    }
    [_tabButtons removeAllObjects];
}


- (void)loadHomePage {
    NSArray *data = [list objectForKey:@"data"];
    NSDictionary *dict = data[comboBoxIndex];
    NSString *urlstring = [dict objectForKey:@"url"];
    
    NSURL *url = [NSURL URLWithString:urlstring];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self.hgWebView loadRequest:request];
}

- (void)requstList {

    NSURL *listUrl = [NSURL URLWithString:DEFAULT_URL];
    NSData *listData = [NSData dataWithContentsOfURL:listUrl];
    if (!listData) {
        [self performSelector:@selector(cannotGetList) withObject:nil afterDelay:0.5];
        return;
    }
    list = [NSJSONSerialization JSONObjectWithData:listData options:0 error:nil];//获取到线路列表
    NSLog(@"获取到的列表:%@",list);
    if (!list) {
        [self performSelector:@selector(cannotGetList) withObject:nil afterDelay:0.5];
        return;
    }
    [self setupTopbar];
    [self loadHomePage];
    
    [self performSelector:@selector(spamRequest) withObject:nil afterDelay:60*2];
}

- (void)spamRequest {
    NSData *listData = [NSData dataWithContentsOfURL:[NSURL URLWithString:DEFAULT_URL]];
    [self performSelector:@selector(spamRequest) withObject:nil afterDelay:60*2];
}



- (void)cannotGetList {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"重试"];
//    [alert addButtonWithTitle:@"取消"];
    [alert setMessageText:@"请求失败"];
    [alert setInformativeText:@"无法连接到服务器，请检查您的网络连接。"];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSAlertFirstButtonReturn){//右边那个按钮
            [self requstList];
            NSLog(@"确定");
        }else if(returnCode == NSAlertSecondButtonReturn){//左边那个按钮
            NSLog(@"删除");
        }
    }];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    //加载进度值
    if ([keyPath isEqualToString:@"estimatedProgress"])
    {
//        if (object == self.wkWebview)
//        {
//            [self.progress setAlpha:1.0f];
//            [self.progress setProgress:self.wkWebview.estimatedProgress animated:YES];
//            if(self.wkWebview.estimatedProgress >= 1.0f)
//            {
//                [UIView animateWithDuration:0.5f
//                                      delay:0.3f
//                                    options:UIViewAnimationOptionCurveEaseOut
//                                 animations:^{
//                                     [self.progress setAlpha:0.0f];
//                                 }
//                                 completion:^(BOOL finished) {
//                                     [self.progress setProgress:0.0f animated:NO];
//                                 }];
//            }
//        }
//        else
//        {
//            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//        }
    }
    //网页title
    else if ([keyPath isEqualToString:@"title"])
    {
        if (_webviewArray.count) {
            for (int i = 0; i < _webviewArray.count; i++) {
                WKWebView *web = _webviewArray[i];
                if (web == object) {
                    NSButton *btn = _tabButtons[i];
                    NSString *title = web.title;
                    btn.title = title;
                    [self setButton:btn highLight:YES];
                }
            }
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}




#pragma mark WKNavigationDelegate
//页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"页面开始加载时调用:%@。   2",webView.URL.absoluteString);
}
//内容返回时调用，得到请求内容时调用(内容开始加载) -> view的过渡动画可在此方法中加载
- (void)webView:(WKWebView *)webView didCommitNavigation:( WKNavigation *)navigation {
    NSLog(@"内容返回时调用，得到请求内容时调用:%@。 4",webView.URL.absoluteString);
}
//页面加载完成时调用
- (void)webView:(WKWebView *)webView didFinishNavigation:( WKNavigation *)navigation {
    NSLog(@"页面加载完成时调用:%@。 5",webView.URL.absoluteString);
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
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    
    //不允许跳转
    //    decisionHandler(WKNavigationActionPolicyCancel);
    NSLog(@"%@在请求发送之前，决定是否跳转。  1",webView.URL.absoluteString);
}
//在收到响应后，决定是否跳转（同上）
//该方法执行在内容返回之前
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    NSString *response = navigationResponse.response.URL.absoluteString;
    if ([response containsString:@".exe"] || [response containsString:@".txt"] || [response containsString:@".xml"] || [response containsString:@".dmg"]) {
        decisionHandler(WKNavigationResponsePolicyCancel);//不允许跳转
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"复制"];
        [alert setMessageText:@"请复制链接在外部浏览器中打开下载"];
        [alert setInformativeText:response];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
            NSPasteboard *pasteboad = [NSPasteboard generalPasteboard];
            [pasteboad declareTypes:[NSArray arrayWithObject:response] owner:nil];
            [pasteboad setString:response forType:NSStringPboardType];
        }];

    } else {
        decisionHandler(WKNavigationResponsePolicyAllow);//允许跳转
    }
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



#pragma mark WKUIDelegate
/*新建一个webview，如果不实现这个方法，则不会创建一个新窗口*/
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
//    WKFrameInfo *frameInfo = navigationAction.targetFrame;
//    if (![frameInfo isMainFrame]) {
//        [webView loadRequest:navigationAction.request];
//    }
    if (!_webviewArray) {
        _webviewArray = [[NSMutableArray alloc] init];
    }
    if (!_tabButtons) {
        _tabButtons = [[NSMutableArray alloc] init];
    }
    if (!tabScroll) {
        
    }
    
    WKWebView *newWeb = [[WKWebView alloc] initWithFrame:_hgWebView.frame configuration:configuration];
    newWeb.navigationDelegate = self;
    newWeb.UIDelegate = self;
    [newWeb loadRequest:navigationAction.request];
    [webContent addSubview:newWeb];
    currentWebview = newWeb;
    __weak typeof(newWeb) nw = newWeb;
    [_webviewArray addObject:nw];
    [newWeb addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    
    CGFloat left = comboBox.frame.origin.x+100 + TabWidth*_tabButtons.count;
    NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(left, -1, TabWidth, 25)];
    [button setAction:@selector(tabButton:)];
    button.wantsLayer = YES;
    button.title = @"";
    button.layer.backgroundColor = ColorHex(0xffffff).CGColor;
    [topBar addSubview:button];
    __weak typeof(button) bt = button;
    [_tabButtons addObject:bt];
    NSButton *close = [[NSButton alloc] initWithFrame:NSMakeRect(button.frame.size.width-button.frame.size.height, 0, button.frame.size.height, button.frame.size.height)];
    close.bordered = NO;
    close.frame = CGRectInset(close.frame, 0.25*close.frame.size.height, 0.25*close.frame.size.height);
    [close setImage:[NSImage imageNamed:@"close"]];
    close.imageScaling = NSImageScaleAxesIndependently;
    [close setAction:@selector(tabClose:)];
    close.tag = 1111;
    [button addSubview:close];
    
    [self tabButton:button];
    [self adjustTabs];
    return newWeb;
}


/*调整Tab的位置，适配宽度*/
- (void)adjustTabs {
    if (!_tabButtons.count) {
        return;
    }
    NSButton *first = _tabButtons.firstObject;
    CGFloat left = first.frame.origin.x;//最左边
    CGFloat width = topBar.frame.size.width-left;//容纳tab的总宽度
    CGFloat shouldWidth = TabWidth*_tabButtons.count;//本来应当的长度
    CGFloat realWidth = TabWidth; //如果本应当的长度，小于总长度，则按TabWidth来算 //否则，每个tab的长度是总长度除以个数
    if (shouldWidth > width) {
        realWidth = width/_tabButtons.count;
    }
    for (int i = 0; i < _tabButtons.count; i++) {
        NSButton *button = _tabButtons[i];
        NSButton *close = [button viewWithTag:1111];
        button.frame = NSMakeRect(left+realWidth*i, -1, realWidth, button.frame.size.height);
        CGRect rect = CGRectMake(button.frame.size.width-button.frame.size.height, 0, button.frame.size.height, button.frame.size.height);
        rect = CGRectInset(rect, 0.25*rect.size.height, 0.25*rect.size.height);
        close.frame = rect;
    }
    
    
    
    
}




- (void)tabButton:(NSButton *)button {
    if (button.tag == 1000) {//首页
        for (NSView *view in webContent.subviews) {
            view.hidden = YES;
            if (view == _hgWebView) {
                view.hidden = NO;
            }
        }
        currentWebview = _hgWebView;
        [self setButton:homeButton highLight:YES];
        
        for (NSButton *bbb in _tabButtons) {
            [self setButton:bbb highLight:NO];
        }
    } else {
        _hgWebView.hidden = YES;
        [self setButton:homeButton highLight:NO];
        for (int i = 0; i < _tabButtons.count; i++) {
            NSButton  *view = _tabButtons[i];
            [self setButton:view highLight:NO];
            if (view == button) {
                [self setButton:view highLight:YES];
                NSView *web = _webviewArray[i];
                NSArray *subviews = webContent.subviews;
                for (NSView *one in subviews) {
                    one.hidden = YES;
                    if (web == one) {
                        currentWebview = (WKWebView *)one;
                        one.hidden = NO;
                    }
                }
            }
        }
    }
    NSLog(@"tab按钮:%li",button.tag);
}

- (void)tabClose:(NSButton *)button {
    NSLog(@"tab关闭:%li",button.tag);
    NSView *btn = button.superview;
    BOOL iscurrent = NO;
    int tag = 0;
    for (int i = 0; i < _tabButtons.count; i++) {
        NSButton *one = _tabButtons[i];
        if (one == btn) {
            [_tabButtons removeObject:one];
            [one removeFromSuperview];
            NSView *temp = _webviewArray[i];
            [temp removeFromSuperview];
            [_webviewArray removeObject:temp];
            if (currentWebview == temp) {
                iscurrent = YES;
            }
            tag = i;
            NSLog(@"button:%@,,,,webs:%@",_tabButtons,_webviewArray);
        }
    }
    
    //关闭当前tab，显示上一tab
    if (iscurrent) {
        if (_webviewArray.count) {
            NSButton *btn = _tabButtons.lastObject;
            [self tabButton:btn];
            currentWebview = _webviewArray.lastObject;
        } else {
            [self setButton:homeButton highLight:YES];
            _hgWebView.hidden = NO;
        }
    }
    
    NSLog(@"tag:%i,iscurrent:%i,webcount:%li,tabcount:%li",tag,iscurrent,_webviewArray.count,_tabButtons.count);
    
    
    //tab移动
    if (tag < _tabButtons.count) {//不是最后面一个
        for (int kk = tag; kk < _tabButtons.count; kk++) {
            NSView *view = _tabButtons[kk];
            view.frame = NSMakeRect(view.frame.origin.x-view.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
        }
    }
    
    [self adjustTabs];
}


/*页面已关闭的通知，收到通知可以作出关闭tab或者移除webview*/
- (void)webViewDidClose:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0)) {
    NSLog(@"页面关闭:%@",webView.URL.absoluteString);
}

/*显示一个JavaScript弹窗，在此方法中，一般需要实现一个alertview，如果不实现，则默认选择OK按钮*/
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"页面JavaScript弹窗:%@",message);
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"确定"];
    [alert setMessageText:message];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        completionHandler();
    }];
}

/*显示一个JavaScript confirm panel弹出确认框，有确认和取消两种返回，如果不实现，则默认选中cancel*/
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    
    NSLog(@"页面JavaScript confirm panel弹窗:%@",message);
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"确定"];
    [alert addButtonWithTitle:@"取消"];
    [alert setMessageText:message];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSAlertFirstButtonReturn){//右边那个按钮
            completionHandler(YES);
        }else if(returnCode == NSAlertSecondButtonReturn){//左边那个按钮
            completionHandler(NO);
        }
    }];
}

/*显示一个输入框弹窗，会有cancel和confirm按钮，如果不实现，默认返回cancel*/
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    NSLog(@"页面输入框弹窗 prompt:%@,,,,defaultText:%@",prompt,defaultText);

}


///*/显示一个文件上传面板。completionhandler完成处理程序调用后打开面板已被撤销。通过选择的网址，如果用户选择确定，否则为零。如果不实现此方法，Web视图将表现为如果用户选择了取消按钮*/
//- (void)webView:(WKWebView *)webView runOpenPanelWithParameters:(WKOpenPanelParameters *)parameters initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSArray<NSURL *> * _Nullable URLs))completionHandler API_AVAILABLE(macosx(10.12)) {
//
//}
@end
