//
//  AppDelegate.m
//  AewolHangulInput
//
//  Created by Daehyun Kim on 2014. 8. 26..
//  Copyright (c) 2014년 aewolstory. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (NSMenu *)menu {
    return _menu;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSLog(@"애월입력기 실행됨");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    NSLog(@"애월입력기 종료");
}

@end
