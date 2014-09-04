//
//  AewolInputTests.m
//  AewolInputMethod
//
//  Created by Daehyun Kim on 2014. 9. 3..
//  Copyright (c) 2014년 aewolstory. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AewolInputController.h"

@interface MockClient: NSObject {
    
}

- (void)insertText:(NSString *)text replacementRange:(NSRange)r;
- (void)setMarkedText:(NSString *)text selectionRange:(NSRange)sr replacementRange:(NSRange *)rr;

@end

@implementation MockClient

- (void)insertText:(NSString *)text replacementRange:(NSRange)r {
    NSLog(@"mock.insertText(%@)", text);
}

- (void)setMarkedText:(NSString *)text selectionRange:(NSRange)sr replacementRange:(NSRange *)rr {
    NSLog(@"mock.setMarkedText(%@)", text);
}

@end

@interface AewolInputTests : XCTestCase {
    AewolInputController *controller;
    MockClient *mock;
}

@end

@implementation AewolInputTests

- (void)setUp {
    [super setUp];
    mock = [MockClient new];
    controller = [AewolInputController new];
    [controller awakeFromNib];
}

- (void)tearDown {
    [super tearDown];
}

- (void)keyCodesTest:(NSArray *)codes withBlock:(void(^)(void))block {
    for (NSNumber *code in codes) {
        NSEvent *event = [NSEvent keyEventWithType:NSKeyDown location:NSMakePoint(0,0) modifierFlags:0 timestamp:0 windowNumber:0 context:nil characters:nil charactersIgnoringModifiers:nil isARepeat:NO keyCode:[code shortValue]];
        [controller handleEvent:event client:mock];
    }
    block();
}

- (void)testExample {
    [self keyCodesTest:@[@0, @10, @10] withBlock:^{
        XCTAssert(YES);
    }];
}

@end

/*
0 a
1 s
2 d
3 f
4 h
5 g
6 z
7 x
8 c
9 v
10 \t
11 b
12 q
13 w
14 e
15 r
16 y
17 t
18 1
19 2
20 3
21 4
22 6
23 5
24 =
25 9
26 7
27 -
28 8
29 0
30 ]
31 o
32 u
33 [
34 i
35 p
36 \t
37 l
38 j
39 '
40 k
41 ;
42 \\    
43 ,
44 /
45 n
46 m
47 .
48 \t
49
50 `
51 \b
*/