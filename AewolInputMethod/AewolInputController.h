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
}

- (BOOL)inputText:(NSString*)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender;

@end

