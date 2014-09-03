//
//  AewolInputController.m
//  AewolHangulInput
//
//  Created by Daehyun Kim on 2014. 8. 26..
//  Copyright (c) 2014년 aewolstory. All rights reserved.
//

#import "AewolInputController.h"
#import "AppDelegate.h"
#import <wchar.h>

@implementation AewolInputController

- (void)awakeFromNib {
    NSLog(@"컨텍스트 초기화");
    ctx = hangul_ic_new("2");
}

- (NSString *)stringFromUCS4:(const ucschar *)s {
    if (s == NULL) return @"";
    return [NSString stringWithCharacters:(unichar *)s length: wcslen((const wchar_t *)s)];
}

- (void)flushPreedit:(id)sender
{
    if (!hangul_ic_is_empty(ctx)) {
        const ucschar *flush = hangul_ic_flush(ctx);
        if (flush[0] != 0) {
            NSString *p = [self stringFromUCS4:flush];
            [sender insertText:p replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
        }
    }
}

- (BOOL)updateBothCommitAndPreedit:(BOOL)handled client:(id)sender
{
    const ucschar *commit = hangul_ic_get_commit_string(ctx);
    const ucschar *preedit = hangul_ic_get_preedit_string(ctx);
    
    if (handled) {
        if (commit[0] != 0) {
            NSString *c = [self stringFromUCS4:commit];
            [sender insertText:c replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
        }
        NSString *p = [self stringFromUCS4:preedit];
        [sender setMarkedText:p selectionRange:NSMakeRange(0, p.length) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    }
    
    return handled;
}

#define AEWOL_QWERTY       "asdfhgzxcv\tbqweryt123465=97-80]ou[ip\tlj'k;\\,/nm.\b `"
#define AEWOL_QWERTY_SHIFT "ASDFHGZXCV\1BQWERYT!@#$^%+(&_*)}OU{IP\tLJ\"K:|<?NM>\b ~"
#define AEWOL_DVORAK       ""
#define AEWOL_DVORAK_SHIFT ""

- (BOOL)inputText:(NSString*)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender
{
    static char *keymaps[] = {AEWOL_QWERTY, AEWOL_QWERTY_SHIFT};
    static int MAX_KEYCODE = strlen(AEWOL_QWERTY) - 1;

    // fn키 누르면, NSNumericPadKeyMask가 켜져서 온다.
    NSUInteger FN_KEY_MASK = NSFunctionKeyMask | NSNumericPadKeyMask;
    NSUInteger fn_shift_mask = NSShiftKeyMask | FN_KEY_MASK;
    BOOL fn_or_shift = (flags | fn_shift_mask) == fn_shift_mask;

    if (!fn_or_shift || keyCode > MAX_KEYCODE) {
        [self flushPreedit:sender];
        return NO;
    }

    int shift = ((flags & NSShiftKeyMask) > 0) ? 1 : 0;
    char ascii = keymaps[shift][keyCode];
    
    if (ascii == '\b') {
        if (flags & FN_KEY_MASK) {
            // fn backspace는 delete 키로 처리됨.
            [self flushPreedit:sender];
            return NO;
        } else {
            return [self updateBothCommitAndPreedit:hangul_ic_backspace(ctx) client:sender];
        }
    } else {
        NSString *ascii_s = [NSString stringWithFormat:@"%c", ascii];
    
        if (!isalpha(ascii) || (flags & NSFunctionKeyMask) > 0) {
            // 알파벳이 아니거나, fn 조합으로 누를 경우에는 qwerty 입력처리하자.
            [self flushPreedit:sender];
            if (ascii == '\t') {
                return NO;
            } else {
                NSLog(@"inserting %@ for %c (%ld)", ascii_s, ascii, keyCode);
                [sender insertText:ascii_s replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
                return YES;
            }
        } else {
            // 알파벳이고 fn이 안 눌린 상태면 여기로 온다.
            return [self updateBothCommitAndPreedit:hangul_ic_process(ctx, ascii) client:sender];
        }
    }
}

-(void)setValue:(id)value forTag:(long)tag client:(id)sender
{
    NSString *newMode = (NSString *)value;
    NSLog(@"New mode key = %@", newMode);
    ctx = hangul_ic_new("2");
}

-(void)commitComposition:(id)sender
{
    NSLog(@"commitComposition called");
    [self flushPreedit:sender];
}

-(void)updateComposition
{
    NSLog(@"updateComposition called");
}

-(void)cancelComposition
{
    NSLog(@"cancelComposition called");
}

-(NSMenu*)menu
{
    AppDelegate *delegate = (AppDelegate *)[NSApp delegate];
    return [delegate menu];
}

-(void)activateServer:(id)sender
{
    NSLog(@"activate");
}

-(void)deactivateServer:(id)sender
{
    NSLog(@"deactivate");
}

@end

