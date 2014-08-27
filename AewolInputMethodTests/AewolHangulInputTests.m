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

@interface AewolHangulInputTests : XCTestCase

@end

@implementation AewolHangulInputTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHangulInputContext {
    HangulInputContext* hic = hangul_ic_new("2");
    hangul_ic_process(hic, 'r');
    hangul_ic_process(hic, 'l');
    hangul_ic_process(hic, 'a');
    hangul_ic_process(hic, 'a');
    const ucschar *commit = hangul_ic_get_commit_string(hic);
    const ucschar *preedit = hangul_ic_get_preedit_string(hic);
    NSString *c = [NSString stringWithCharacters:(unichar *)commit length:wcslen((const wchar_t *)commit)];
    NSString *p = [NSString stringWithCharacters:(unichar *)preedit length:wcslen((const wchar_t *)preedit)];
    NSLog(@"---------------------[%@, %@]-----------------", c, p);
    XCTAssertEqualObjects(c, @"김");
    XCTAssertEqualObjects(p, @"ㅁ");
    hangul_ic_delete(hic);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
