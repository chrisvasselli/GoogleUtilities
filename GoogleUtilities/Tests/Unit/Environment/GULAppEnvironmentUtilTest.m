// Copyright 2018 Google
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <Foundation/Foundation.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif  // TARGET_OS_IOS

#import "GoogleUtilities/Environment/Public/GoogleUtilities/GULAppEnvironmentUtil.h"

@interface GULAppEnvironmentUtilTest : XCTestCase

@property(nonatomic) id processInfoMock;

@end

@implementation GULAppEnvironmentUtilTest

- (void)setUp {
  [super setUp];

  _processInfoMock = OCMPartialMock([NSProcessInfo processInfo]);
}

- (void)tearDown {
  [super tearDown];

  [_processInfoMock stopMocking];
}

#if TARGET_OS_IOS

- (void)testProcessInfoSystemVersionInfoMatchesUIDeviceSystemVersion {
  XCTAssertTrue([[GULAppEnvironmentUtil systemVersion]
      isEqualToString:[UIDevice currentDevice].systemVersion]);
}

#endif  // TARGET_OS_IOS

- (void)testSystemVersionInfoMajorOnly {
  NSOperatingSystemVersion osTen = {.majorVersion = 10, .minorVersion = 0, .patchVersion = 0};
  OCMStub([self.processInfoMock operatingSystemVersion]).andReturn(osTen);

  XCTAssertTrue([[GULAppEnvironmentUtil systemVersion] isEqualToString:@"10.0"]);
}

- (void)testSystemVersionInfoMajorMinor {
  NSOperatingSystemVersion osTenTwo = {.majorVersion = 10, .minorVersion = 2, .patchVersion = 0};
  OCMStub([self.processInfoMock operatingSystemVersion]).andReturn(osTenTwo);

  XCTAssertTrue([[GULAppEnvironmentUtil systemVersion] isEqualToString:@"10.2"]);
}

- (void)testSystemVersionInfoMajorMinorPatch {
  NSOperatingSystemVersion osTenTwoOne = {.majorVersion = 10, .minorVersion = 2, .patchVersion = 1};
  OCMStub([self.processInfoMock operatingSystemVersion]).andReturn(osTenTwoOne);

  XCTAssertTrue([[GULAppEnvironmentUtil systemVersion] isEqualToString:@"10.2.1"]);
}

- (void)testDeploymentType {
#if SWIFT_PACKAGE
  NSString *deploymentType = @"swiftpm";
#elif FIREBASE_BUILD_CARTHAGE
  NSString *deploymentType = @"carthage";
#elif FIREBASE_BUILD_ZIP_FILE
  NSString *deploymentType = @"zip";
#elif COCOAPODS
  NSString *deploymentType = @"cocoapods";
#else
  NSString *deploymentType = @"unknown";
#endif

  XCTAssertEqualObjects([GULAppEnvironmentUtil deploymentType], deploymentType);
}

- (void)testApplePlatform {
  // The below ordering is important. For example, both `TARGET_OS_MACCATALYST`
  // and `TARGET_OS_IOS` are `true` when building a macCatalyst app.
#if TARGET_OS_MACCATALYST
  NSString *expectedPlatform = @"maccatalyst";
#elif TARGET_OS_IOS
  NSString *expectedPlatform = @"ios";
#elif TARGET_OS_TV
  NSString *expectedPlatform = @"tvos";
#elif TARGET_OS_OSX
  NSString *expectedPlatform = @"macos";
#elif TARGET_OS_WATCH
  NSString *expectedPlatform = @"watchos";
#endif  // TARGET_OS_MACCATALYST

  XCTAssertEqualObjects([GULAppEnvironmentUtil applePlatform], expectedPlatform);
}

@end
