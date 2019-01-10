//
//  ViewController.h
//  HGTY_Mac
//
//  Created by david on 2018/12/3.
//  Copyright © 2018 david. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface ViewController : NSViewController <WKNavigationDelegate,WKUIDelegate,NSComboBoxDelegate>


@property (strong) WKWebView *hgWebView;
@property (strong) NSMutableArray *webviewArray;
@property (strong) NSMutableArray *tabButtons;


@end

