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

    XCTAssertTrue([_url jlr_matchPattern:@"/v2/categories/:categoryId"], @"URL should have matched route");
}
- (void)testMatchFailure
{
    XCTAssertFalse([_url jlr_matchPattern:@"/v2/styles/:styleId"], @"URL shouldn't have matched route");
}
- (void)testMatchSuccessReturnsParams
{
    NSDictionary *actual = [_url jlr_matchPattern:@"/v2/categories/:categoryId"];
    NSDictionary *expected = @{@"categoryId": @"1"};

    XCTAssertEqualObjects(actual, expected, @"When matched should return parsed route params");
}
//Add tests for url parameters and whatnot

-(void)testURLGenerationFromPattern {
    NSDictionary *parameters = @{@"categoryId": @"1"};
    NSURL *actual = [NSURL jlr_URLWithPattern:@"http://api.apple.com/v1/categories/:categoryId/" parameters:parameters];
    NSURL *expected = [NSURL URLWithString:@"http://api.apple.com/v1/categories/1/"];
    XCTAssertEqualObjects(actual, expected, @"jlr_URLWithPattern should return a valid url when passed a pattern and params");
}

- (void)testURLGenerationFromPattern2 {
    NSDictionary *parameters = @{
                                 @"styleId": @"5",
                                 @"categoryId": @"2"
                                 };
    NSURL *actual = [NSURL jlr_URLWithPattern:@"http://api.apple.com/v1/:categoryId/styleId/:styleId" parameters:parameters];
    NSURL *expected = [NSURL URLWithString:@"http://api.apple.com/v1/2/styleId/5"];
    XCTAssertEqualObjects(actual, expected, @"jlr_URLWithPattern should return a valid url when passed a pattern and params");
}

-(void)testSimilarlyNamedTokens {
    NSDictionary *parameters = @{@"alpha": @"a",
                                 @"alphabeta": @"ab",
                                 @"alp": @"c"
                                 };
    NSURL *actual = [NSURL jlr_URLWithPattern:@"http://api.apple.com/v1/:alpha/:alphabeta/:alp" parameters:parameters];
    NSURL *expected = [NSURL URLWithString:@"http://api.apple.com/v1/a/ab/c"];
    XCTAssertEqualObjects(actual, expected, @"Similarly named tokens should be processed correctly");
}

// Might consider adding an error ref param for the following issues.
-(void)testMaliciousTokenName {
    NSDictionary *parameters =@{
                                @"/": @"://myhackingsite.com/?hijack=",
                                @"user": @"me"
                                };
    NSURL *actual = [NSURL jlr_URLWithPattern:@"http://api.apple.com/:user/" parameters:parameters];
    XCTAssertNil(actual, @"should not allow / as first character of a token");
}

-(void)testInFactOnlySupportAlphaNumericTokenNames {
    NSDictionary *parameters =@{
                                @"$": @"profit",
                                @"user": @"me"
                                };
    NSURL *actual = [NSURL jlr_URLWithPattern:@"http://api.apple.com/:user/" parameters:parameters];
    XCTAssertNil(actual, @"should not allow $ in token");

}
-(void)testInFactOnlySupportAlphaNumericTokenNames1 {
    NSDictionary *parameters =@{
                                @"style&party": @"foofest",
                                @"user": @"me"
                                };
    NSURL *actual = [NSURL jlr_URLWithPattern:@"http://api.apple.com/:user/:style&party" parameters:parameters];
    XCTAssertNil(actual, @"should not allow & in token");

}
-(void)testInFactOnlySupportAlphaNumericTokenNames2 {
    NSDictionary *parameters =@{
                                @"user+name": @"Kav Latiolais",
                                @"user": @"me"
                                };
    NSURL *actual = [NSURL jlr_URLWithPattern:@"http://api.apple.com/:user/:user+name" parameters:parameters];
    XCTAssertNil(actual, @"should not allow + in token");
}


-(void)testThatTokensAreStrings {
    NSDictionary *parameters = @{@[@"alpha"]: @"a"};

    NSURL *actual = [NSURL jlr_URLWithPattern:@"http://api.apple.com/v1/:alpha/" parameters:parameters];
    XCTAssertNil(actual, @"Should not allow non string keys");
}

// ------------------- Open questions --------------
//Test case for http://api.apple.com/v1/fish:fishId/
//Should this work?
- (void)testUrlwithStrangePattern {
    NSDictionary *parameters = @{
                                 @"styleId": @"5",
                                 };
    NSURL *actual = [NSURL jlr_URLWithPattern:@"http://api.apple.com/v1/styleId:styleId" parameters:parameters];
    NSURL *expected = [NSURL URLWithString:@"http://api.apple.com/v1/styleId5"];
    XCTAssertEqualObjects(actual, expected, @"tokens should be replaced in the middle of path components");
}



//What should happen here?
//-(void)testReturnIncompleteParams {
//    NSDictionary *parameters = @{
//                                 @"styleId": @"5",
//                                 };
//    NSURL *actual = [NSURL jlr_URLWithPattern:@"http://api.apple.com/v1/:categoryId/styleId/:styleId" parameters:parameters];
//    XCTAssertNil(actual, @"should return nil if parameters do not produce valid URL.");
//}




@end
