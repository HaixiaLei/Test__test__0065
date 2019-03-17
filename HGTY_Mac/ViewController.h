//
//  ViewController.h
//  HGTY_Mac
//
//  Created by david on 2018/12/3.
//  Copyright © 2018 david. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#if (PRODUCT == 1)//HG6668
#define DEFAULT_URL         @"https://www.cesu6668.com/dataInterface.php?type=mac"
#elif (PRODUCT == 2)//HG0086
#define DEFAULT_URL         @"https://www.cesu0086.com/dataInterface.php?type=mac"
#elif (PRODUCT == 3)//创富
#define DEFAULT_URL         @"https://cf123123.com/dataInterface.php?type=mac"
#elif (PRODUCT == 4)//国民
#define DEFAULT_URL         @"https://gm223223.com/dataInterface.php?type=mac"
#elif (PRODUCT == 5)//宏发
#define DEFAULT_URL         @"https://990333.cc/dataInterface.php?type=mac"
#endif





@interface ViewController : NSViewController <WKNavigationDelegate,WKUIDelegate,NSComboBoxDelegate>



@property (strong) WKWebView *hgWebView;
@property (strong) NSMutableArray *webviewArray;
@property (strong) NSMutableArray *tabButtons;


@end

