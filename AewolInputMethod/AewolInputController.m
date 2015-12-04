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

#define AWLog(...) {if (debug) NSLog(__VA_ARGS__);}

@implementation AewolInputController

- (void)awakeFromNib
{
    debug = NO;
}

- (IBAction)toggleDebug:(id)sender
{
    debug = !debug;
    NSLog(@"debugMode = %d, sender=%@", debug, sender);
}

- (IBAction)openWebsite:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://input.aewolstory.com"]];
}

- (NSString *)stringFromUCS4:(const ucschar *)s
{
    if (s == NULL) return @"";
    return [NSString stringWithCharacters:(unichar *)s length: wcslen((const wchar_t *)s)];
}

- (void)flushPreedit:(id)sender
{
    NSString *ps = [self flushPreeditString:sender];
    if ([ps length] > 0) {
        [sender insertText:ps replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
        AWLog(@"flushing [%@]", ps);
    }
}

- (NSString *)flushPreeditString:(id)sender
{
    if (!hangul_ic_is_empty(ctx)) {
        const ucschar *flush = hangul_ic_flush(ctx);
        return [self stringFromUCS4:flush];
    } else {
        return @"";
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
            AWLog(@"commit=[%@]", c);
        }
        NSString *p = [self stringFromUCS4:preedit];
        NSRange m = [sender markedRange];
        AWLog(@"preedit=[%@], marked=(%ld, %ld)", p, m.location, m.length);
        [sender setMarkedText:p selectionRange:NSMakeRange(m.location, p.length) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    }

    return handled;
}

#define AEWOL_QWERTY       "asdfhgzxcv\tbqweryt123465=97-80]ou[ip\tlj'k;\\,/nm.\t `\b"
#define AEWOL_QWERTY_SHIFT "ASDFHGZXCV\tBQWERYT!@#$^%+(&_*)}OU{IP\tLJ\"K:|<?NM>\t ~\b"
#define AEWOL_DVORAK       ""
#define AEWOL_DVORAK_SHIFT ""

- (BOOL)handleEvent:(NSEvent *)event client:(id)sender
{
    if (event.type != NSKeyDown) {
        AWLog(@"handleEvent for %ld", event.type);
        return NO;
    }

    NSInteger keyCode = event.keyCode;
    NSUInteger flags = event.modifierFlags;

    static char *keymaps[] = {AEWOL_QWERTY, AEWOL_QWERTY_SHIFT};
    static int MAX_KEYCODE = strlen(AEWOL_QWERTY) - 1;

    // fn키 누르면, NSNumericPadKeyMask가 켜져서 온다.
    NSUInteger FN_KEY_MASK = NSFunctionKeyMask | NSNumericPadKeyMask;
    NSUInteger fn_shift_caps_mask = NSShiftKeyMask | NSAlphaShiftKeyMask | FN_KEY_MASK;
    BOOL accepting_flags = (flags | fn_shift_caps_mask) == fn_shift_caps_mask;

    AWLog(@"flags=%ld, accepting_flags=%d, keycode=%ld", flags, accepting_flags, keyCode);
    if (!accepting_flags || keyCode > MAX_KEYCODE) {
        AWLog(@"bypassing");
        [self flushPreedit:sender];
        return NO;
    }

    BOOL shift = (flags & NSShiftKeyMask) > 0;
    char ascii = keymaps[shift][keyCode];
    
    if (ascii == '\b') {
        if ((flags & FN_KEY_MASK) == FN_KEY_MASK) {
            // fn backspace는 delete 키로 처리됨.
            [self flushPreedit:sender];
            return NO;
        } else {
            return [self updateBothCommitAndPreedit:hangul_ic_backspace(ctx) client:sender];
        }
    } else {
        if (!isalpha(ascii) || (flags & NSFunctionKeyMask) > 0) {
            // 알파벳이 아니거나, fn 조합으로 누를 경우에는 qwerty 입력처리하자.
            if (ascii == '\t') {
                // FIX: 페북에서 사용자멘션 자동입력후 엔터누르면 마지막 preedit도 중복 입력됨. 예) 김대현현
                AWLog(@"bypassing keycode=%ld, flags=%ld", keyCode, flags);
                [self flushPreedit:sender];
                return NO;
            } else {
                BOOL caps = ((flags & NSAlphaShiftKeyMask) > 0) && isalpha(ascii);
                ascii = keymaps[shift | caps][keyCode]; // capslock 키반영

                NSString *ascii_s = [NSString stringWithFormat:@"%@%c" , [self flushPreeditString:sender], ascii];
                AWLog(@"sending [%@] (caps=%d) for %ld", ascii_s, caps, keyCode);
                [sender insertText:ascii_s replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
                return YES;
            }
        } else {
            // 알파벳이고 fn이 안 눌린 상태면 여기로 온다.
            AWLog(@"processing %c", ascii);
            return [self updateBothCommitAndPreedit:hangul_ic_process(ctx, ascii) client:sender];
        }
    }
}

- (void)setValue:(id)value forTag:(long)tag client:(id)sender
{
    NSString *newMode = (NSString *)value;
    // kTextServiceInputModePropertyTag
    AWLog(@"newMode = %@ for tag = %ld, client = %@", newMode, tag, sender);
}

- (id)valueForTag:(long)tag client:(id)sender
{
    AWLog(@"valueForTag called tag=%ld, client=%@", tag, sender);
    return [super valueForTag:tag client:sender];
}

- (NSMenu*)menu
{
    AppDelegate *delegate = (AppDelegate *)[NSApp delegate];
    return [delegate menu];
}

- (void)activateServer:(id)sender
{
    AWLog(@"activate %@", sender);
    ctx = hangul_ic_new("2");
}

- (void)deactivateServer:(id)sender
{
    AWLog(@"deactivate %@", sender);
    [self flushPreedit:sender];
    if (ctx) hangul_ic_delete(ctx);
}

- (void)commitComposition:(id)sender
{
    AWLog(@"commitComposition called");
    [self flushPreedit:sender];
}

- (void)updateComposition
{
    AWLog(@"updateComposition called");
}

- (void)cancelComposition
{
    AWLog(@"cancelComposition called");
}

- (NSUInteger)recognizedEvents:(id)sender
{
    return NSKeyDownMask | NSLeftMouseDownMask | NSRightMouseDownMask | NSLeftMouseDraggedMask | NSRightMouseDraggedMask;
}

@end

