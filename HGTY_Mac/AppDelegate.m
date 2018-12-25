//
//  AppDelegate.m
//  HGTY_Mac
//
//  Created by david on 2018/12/3.
//  Copyright © 2018 david. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSLog(@"当前项目是:%i (1:HG6668  2:HG0086)",PRODUCT);
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
