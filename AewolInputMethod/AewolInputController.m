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

// @TODO, 현재 사파리에서 텍스트필드에 처음 포커스가 가면, 첫번째 키가 안눌리는 문제가 있음.

@implementation AewolInputController

// initWithServer: server=<IMKServer: 0x600000000b60>, delegate=(null), client=<IMKXPCCompatibilityDOProxyInterposer: 0x608000001ca0>
- (id)initWithServer:(IMKServer *)server delegate:(id)delegate client:(id)client {
    self = [super initWithServer:server delegate:delegate client:client];
    if (self != nil) {
        NSLog(@"initWithServer: server=%@, delegate=%@, client=%@", server, delegate, client);
    }
    return self;
}

- (void)awakeFromNib
{
    debug = NO;
}

- (IBAction)toggleDebug:(id)sender
{
    debug = !debug;
    NSLog(@"debugMode = %d, sender=%@", debug, sender);
}

- (IBAction)openWebsite:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://input.aewolstory.com"]];
}

- (NSString *)stringFromUCS4:(const ucschar *)s
{
    if (s == NULL) return @"";
    return [NSString stringWithCharacters:(unichar *)s length: wcslen((const wchar_t *)s)];
}

- (void)flushPreedit:(id)sender
{
    if (!hangul_ic_is_empty(ctx)) {
        const ucschar *flush = hangul_ic_flush(ctx);
        NSString *p = [self stringFromUCS4:flush];
        [sender insertText:p replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
        NSRange m = [sender markedRange];
        AWLog(@"flushing [%@]", p);
        [sender setMarkedText:@"" selectionRange:NSMakeRange(m.location, 0) replacementRange:m];
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
        NSRange nm = NSMakeRange(m.location, p.length);
        AWLog(@"preedit=[%@], marked=(%ld, %ld)", p, m.location, m.length);
        if (m.length > 0 || nm.length > 0) {
            [sender setMarkedText:p selectionRange:nm replacementRange:m];
//            [sender setSelectedRange:nm];eh.n
        }
    }

    return handled;
}

#define AEWOL_QWERTY       "asdfhgzxcv\tbqweryt123465=97-80]ou[ip\tlj'k;\\,/nm.\t `\b"
#define AEWOL_QWERTY_SHIFT "ASDFHGZXCV\tBQWERYT!@#$^%+(&_*)}OU{IP\tLJ\"K:|<?NM>\t ~\b"
#define AEWOL_DVORAK       ""
#define AEWOL_DVORAK_SHIFT ""

- (BOOL)handleEvent:(NSEvent *)event client:(id)sender
{
    NSInteger keyCode = event.keyCode;
    NSUInteger flags = event.modifierFlags;

    static char *keymaps[] = {AEWOL_QWERTY, AEWOL_QWERTY_SHIFT};
    static int MAX_KEYCODE = strlen(AEWOL_QWERTY) - 1;

    // fn키 누르면, NSNumericPadKeyMask가 켜져서 온다.
    NSUInteger FN_KEY_MASK = NSFunctionKeyMask | NSNumericPadKeyMask;
    NSUInteger fn_shift_mask = NSShiftKeyMask | FN_KEY_MASK;
    BOOL fn_or_shift = (flags | fn_shift_mask) == fn_shift_mask;

    AWLog(@"flags=%ld, fn_or_shift=%d, keycode=%ld", flags, fn_or_shift, keyCode);
    if (!fn_or_shift || keyCode > MAX_KEYCODE) {
        AWLog(@"bypassing");
        [self flushPreedit:sender];
        return NO;
    }

    int shift = ((flags & NSShiftKeyMask) > 0) ? 1 : 0;
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
        NSString *ascii_s = [NSString stringWithFormat:@"%c", ascii];
    
        if (!isalpha(ascii) || (flags & NSFunctionKeyMask) > 0) {
            // 알파벳이 아니거나, fn 조합으로 누를 경우에는 qwerty 입력처리하자.
            [self flushPreedit:sender];
            if (ascii == '\t') {
                AWLog(@"bypassing keycode=%ld, flags=%ld", keyCode, flags);
                return NO;
            } else {
                AWLog(@"sending [%c] for %ld", ascii, keyCode);
                [sender insertText:ascii_s replacementRange:NSMakeRange(NSNotFound, 1)];
                return YES;
            }
        } else {
            // 알파벳이고 fn이 안 눌린 상태면 여기로 온다.
            AWLog(@"processing %c", ascii);
            return [self updateBothCommitAndPreedit:hangul_ic_process(ctx, ascii) client:sender];
        }
    }
}

-(void)setValue:(id)value forTag:(long)tag client:(id)sender
{
    NSString *newMode = (NSString *)value;
    // kTextServiceInputModePropertyTag
    AWLog(@"newMode = %@ for tag = %ld, client = %@", newMode, tag, sender);
}

-(id)valueForTag:(long)tag client:(id)sender
{
    AWLog(@"valueForTag called tag=%ld, client=%@", tag, sender);
    return [super valueForTag:tag client:sender];
}

-(NSMenu*)menu
{
    AppDelegate *delegate = (AppDelegate *)[NSApp delegate];
    return [delegate menu];
}

-(void)activateServer:(id)sender
{
    AWLog(@"activate %@", sender);
    ctx = hangul_ic_new("2");
}

-(void)deactivateServer:(id)sender
{
    AWLog(@"deactivate %@", sender);
    [self flushPreedit:sender];
    if (ctx) hangul_ic_delete(ctx);
}

-(void)commitComposition:(id)sender
{
    AWLog(@"commitComposition called");
    [self flushPreedit:sender];
}

-(void)updateComposition
{
    AWLog(@"updateComposition called");
}

-(void)cancelComposition
{
    AWLog(@"cancelComposition called");
}

@end

