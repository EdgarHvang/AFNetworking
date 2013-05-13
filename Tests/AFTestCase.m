//
//  AFTestCase.m
//  AFNetworking Tests
//
//  Created by Kevin Harwood on 5/13/13.
//  Copyright (c) 2013 AFNetworking. All rights reserved.
//

#import "AFTestCase.h"

NSString *AFNetworkingTestsBaseURLString = @"http://httpbin.org/";

NSURL *AFNetworkingTestsBaseURL(void)
{
    return [NSURL URLWithString:AFNetworkingTestsBaseURLString];
}


@implementation AFTestCase

- (void)setUp{
    [Expecta setAsynchronousTestTimeout:15.0];
}

@end
