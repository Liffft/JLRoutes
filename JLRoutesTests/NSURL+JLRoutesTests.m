//
//  NSURL+JLRoutesTests.m
//  JLRoutes
//
//  Created by pair on 4/25/14.
//  Copyright (c) 2014 Afterwork Studios. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSURL+JLRoutes.h"

@interface NSURL_JLRoutesTests : XCTestCase
@property (strong) NSURL *url;
@end

@implementation NSURL_JLRoutesTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _url = [[NSURL alloc] initWithString:@"CJWAPI://v2/categories/1"];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMatchSuccess
{

    XCTAssertTrue([_url jlr_matchRoute:@"/v2/categories/:categoryId"], @"URL should have matched route");
}
- (void)testMatchFailure
{
    XCTAssertFalse([_url jlr_matchRoute:@"/v2/styles/:styleId"], @"URL shouldn't have matched route");
}
- (void)testMatchSuccessReturnsParams
{
    NSDictionary *actual = [_url jlr_matchRoute:@"/v2/categories/:categoryId"];
    NSDictionary *expected = @{@"categoryId": @"1"};

    XCTAssertEqualObjects(actual, expected, @"When matched should return parsed route params");
}

@end
