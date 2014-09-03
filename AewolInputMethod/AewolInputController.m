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

#define AEWOL_QWERTY       "asdfhgzxcv\tbqweryt123465=97-80]ou[ip\tlj'k;\\,/nm.\t `"
#define AEWOL_QWERTY_SHIFT "ASDFHGZXCV\1BQWERYT!@#$^%+(&_*)}OU{IP\tLJ\"K:|<?NM>\t ~"
#define AEWOL_DVORAK       ""
#define AEWOL_DVORAK_SHIFT ""

- (BOOL)inputText:(NSString*)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender
{
    static char *keymaps[] = {AEWOL_QWERTY, AEWOL_QWERTY_SHIFT};
    static int MAX_KEYCODE = strlen(AEWOL_QWERTY) - 1;

    NSLog(@"keycode = %ld (%ld) for = %@", keyCode, flags, string);
    if ((flags | NSShiftKeyMask) != NSShiftKeyMask || keyCode > MAX_KEYCODE) {
        [self flushPreedit:sender];
        return NO;
    }

    BOOL handled = NO;
    
    if (keyCode == 51) {
        handled = hangul_ic_backspace(ctx);
    } else {
        int shift = ((flags & NSShiftKeyMask) > 0) ? 1 : 0;
        char ascii = keymaps[shift][keyCode];
        if (isalpha(ascii)) {
            handled = hangul_ic_process(ctx, ascii);
        } else {
            [self flushPreedit:sender];
            if (ascii == '\t') {
                return NO;
            } else {
                NSString *asciiString = [NSString stringWithFormat:@"%c", ascii];
                [sender insertText:asciiString replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
                return YES;
            }
        }
    }
    
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

