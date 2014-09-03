//
//  AewolHangulInputTests.m
//  AewolHangulInputTests
//
//  Created by Daehyun Kim on 2014. 8. 26..
//  Copyright (c) 2014년 aewolstory. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "hangul.h"
#import <wchar.h>

@interface AewolHangulInputTests : XCTestCase {
    HangulInputContext *ctx;
}
@end

@implementation AewolHangulInputTests

- (void)setUp {
    [super setUp];
    ctx = hangul_ic_new("2");
}

- (void)tearDown {
    hangul_ic_delete(ctx);
    [super tearDown];
}

- (NSString *)stringFromUCS4:(const ucschar *)s {
    if (s == NULL) return @"";
    return [NSString stringWithCharacters:(unichar *)s length: wcslen((const wchar_t *)s)];
}

- (void)assertPreedit:(NSString *)s
{
    XCTAssertEqualObjects(s, [self stringFromUCS4:hangul_ic_get_preedit_string(ctx)]);
}

- (void)testHangulInputContext {
    XCTAssert(hangul_ic_is_empty(ctx));
    XCTAssertFalse(hangul_ic_backspace(ctx));
    hangul_ic_process(ctx, 'r');
    XCTAssertEqual('r', 0x72);
    hangul_ic_process(ctx, 'l');
    hangul_ic_process(ctx, 'a');
    hangul_ic_process(ctx, 'a');
    NSString *c = [self stringFromUCS4:hangul_ic_get_commit_string(ctx)];
    NSString *p = [self stringFromUCS4:hangul_ic_get_preedit_string(ctx)];
    NSLog(@"[%@, %@]", c, p);
    XCTAssertEqualObjects(c, @"김");
    [self assertPreedit:@"ㅁ"];
    XCTAssert(hangul_ic_backspace(ctx));
    XCTAssertFalse(hangul_ic_process(ctx, ' '));
    hangul_ic_process(ctx, 'e');
    hangul_ic_process(ctx, 'o');
    XCTAssertFalse(hangul_ic_process(ctx, ' '));
    hangul_ic_process(ctx, '1');

    c = [self stringFromUCS4:hangul_ic_get_commit_string(ctx)];
    p = [self stringFromUCS4:hangul_ic_get_preedit_string(ctx)];
    NSLog(@"[%@, %@]", c, p);
}

- (void)testBackspace {
    XCTAssertFalse(hangul_ic_backspace(ctx));
    hangul_ic_process(ctx, 'r');
    hangul_ic_process(ctx, 'l');
    hangul_ic_process(ctx, 'a');
    [self assertPreedit:@"김"];
    XCTAssert(hangul_ic_backspace(ctx));
    [self assertPreedit:@"기"];
    XCTAssert(hangul_ic_backspace(ctx));
    [self assertPreedit:@"ㄱ"];
    XCTAssert(hangul_ic_backspace(ctx));
    [self assertPreedit:@""];
    XCTAssertFalse(hangul_ic_backspace(ctx));
}

@end
