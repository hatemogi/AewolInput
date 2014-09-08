//
//  AewolInputController.h
//  AewolHangulInput
//
//  Created by Daehyun Kim on 2014. 8. 26..
//  Copyright (c) 2014년 aewolstory. All rights reserved.
//

#import <InputMethodKit/InputMethodKit.h>
#import "hangul.h"

@interface AewolInputController : IMKInputController {
    HangulInputContext *ctx;
    BOOL debug;
}

- (BOOL)handleEvent:(NSEvent *)event client:(id)sender;
- (IBAction)toggleDebug:(id)sender;

@end

