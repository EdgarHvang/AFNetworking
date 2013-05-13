//
//  AFTestCase.h
//  AFNetworking Tests
//
//  Created by Kevin Harwood on 5/13/13.
//  Copyright (c) 2013 AFNetworking. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "AFNetworking.h"

#define EXP_SHORTHAND YES
#import "Expecta.h"
#import "OCMock.h"

extern NSString *AFNetworkingTestsBaseURLString;
NSURL *AFNetworkingTestsBaseURL(void);

@interface AFTestCase : SenTestCase

@end
