//
//  AFHTTPRequestOperationTest.m
//  AFNetworking
//
//  Created by Blake Watters on 5/10/13.
//  Copyright (c) 2013 AFNetworking. All rights reserved.
//

#import "AFNetworkingTests.h"

@interface AFHTTPRequestOperationTest : SenTestCase
@end

@implementation AFHTTPRequestOperationTest

- (void)testThatOperationInvokesSuccessCompletionBlockWithResponseObjectOnSuccess
{
    [Expecta setAsynchronousTestTimeout:30.0];
    __block id blockResponseObject = nil;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/get" relativeToURL:AFNetworkingTestsBaseURL()]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        blockResponseObject = responseObject;
    } failure:nil];
    [operation start];
    expect([operation isFinished]).will.beTruthy();
    expect(blockResponseObject).willNot.beNil();
}

- (void)testThatOperationInvokesFailureCompletionBlockWithErrorOnFailure
{
    __block NSError *blockError = nil;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/status/404" relativeToURL:AFNetworkingTestsBaseURL()]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:nil failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        blockError = error;
    }];
    [operation start];
    expect([operation isFinished]).will.beTruthy();
    expect(blockError).willNot.beNil();
}

- (void)testThat500StatusCodeInvokesFailureCompletionBlockWithErrorOnFailure{
    __block NSError *blockError = nil;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/status/500" relativeToURL:AFNetworkingTestsBaseURL()]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:nil failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        blockError = error;
    }];
    [operation start];
    expect([operation isFinished]).will.beTruthy();
    expect(blockError).willNot.beNil();
}

- (void)testThat200StatusCodeInvokesSuccessCompletionBlockWithResponseObjectOnSuccess{
    __block BOOL success;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/status/200" relativeToURL:AFNetworkingTestsBaseURL()]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        success = YES;
    } failure:nil];
    [operation start];
    expect([operation isFinished]).will.beTruthy();
    expect(success).will.beTruthy();
}

- (void)testThatRedirectBlockIsCalledWhen302IsEncountered{
    __block BOOL success;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/redirect/1" relativeToURL:AFNetworkingTestsBaseURL()]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:nil
                                     failure:nil];
    [operation
     setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
         if(redirectResponse){
             success = YES;
         }
         return request;
     }];
    [operation start];
    expect([operation isFinished]).will.beTruthy();
    expect(success).will.beTruthy();
}

- (void)testThatRedirectBlockIsCalledMultipleTimesWhenMultiple302sAreEncountered{
    __block NSInteger numberOfRedirects = 0;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/redirect/5" relativeToURL:AFNetworkingTestsBaseURL()]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:nil
                                     failure:nil];
    [operation
     setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
         if(redirectResponse){
             numberOfRedirects++;
         }
         return request;
     }];
    [operation start];
    expect([operation isFinished]).will.beTruthy();
    expect(numberOfRedirects).will.equal(5);
}

@end
