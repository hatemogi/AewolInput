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

@interface LibHangulTests : XCTestCase {
    HangulInputContext *ctx;
}
@end

@implementation LibHangulTests

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

- (NSString *)preeditString {
    return [self stringFromUCS4:hangul_ic_get_preedit_string(ctx)];
}

- (NSString *)commitString {
    return [self stringFromUCS4:hangul_ic_get_commit_string(ctx)];
}

- (void)testHangulInputContext {
    XCTAssert(hangul_ic_is_empty(ctx));
    XCTAssertFalse(hangul_ic_backspace(ctx));
    hangul_ic_process(ctx, 'r');
    XCTAssertEqual('r', 0x72);
    hangul_ic_process(ctx, 'l');
    hangul_ic_process(ctx, 'a');
    hangul_ic_process(ctx, 'a');
    XCTAssertEqualObjects(@"김", [self commitString]);
    XCTAssertEqualObjects(@"ㅁ", [self preeditString]);
    XCTAssert(hangul_ic_backspace(ctx));
    XCTAssertFalse(hangul_ic_process(ctx, ' '));
    hangul_ic_process(ctx, 'e');
    hangul_ic_process(ctx, 'o');
    XCTAssertFalse(hangul_ic_process(ctx, ' '));

    hangul_ic_process(ctx, '1');
    XCTAssertEqualObjects(@"1", [self commitString]);
}

- (void)testBackspace {
    XCTAssertFalse(hangul_ic_backspace(ctx));
    hangul_ic_process(ctx, 'r');
    hangul_ic_process(ctx, 'l');
    hangul_ic_process(ctx, 'a');
    XCTAssertEqualObjects(@"김", [self preeditString]);
    XCTAssert(hangul_ic_backspace(ctx));
    XCTAssertEqualObjects(@"기", [self preeditString]);
    XCTAssert(hangul_ic_backspace(ctx));
    XCTAssertEqualObjects(@"ㄱ", [self preeditString]);
    XCTAssert(hangul_ic_backspace(ctx));
    XCTAssertEqualObjects(@"", [self preeditString]);
    XCTAssertFalse(hangul_ic_backspace(ctx));
}

@end
