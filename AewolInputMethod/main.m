//
//  main.m
//  AewolHangulInput
//
//  Created by Daehyun Kim on 2014. 8. 26..
//  Copyright (c) 2014년 aewolstory. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

IMKServer*			server;
IMKCandidates*		candidates = nil;


int main(int argc, const char * argv[]) {
    server = [[IMKServer alloc] initWithName:@"AewolInput_Connection" bundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]];
    
    NSLog(@"Server created: %@", server);
    //load the bundle explicitly because in this case the input method is a background only application
    [NSBundle bundleWithIdentifier:@"MainMenu"];

    return NSApplicationMain(argc, argv);
}
