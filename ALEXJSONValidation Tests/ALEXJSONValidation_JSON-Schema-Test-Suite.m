//
//  ALEXJSONValidation_JSON-Schema-Test-Suite.m
//  ALEXJSONValidation
//
//  Created by Alexander Kempgen on 12.01.13.
//  Copyright (c) 2013 Alexander Kempgen. All rights reserved.
//

#import "ALEXJSONValidation_JSON-Schema-Test-Suite.h"

#import "ALEXJSONValidation.h"

@implementation ALEXJSONValidation_JSON_Schema_Test_Suite {
	NSURL *_cacheDirectory;
}

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
//	NSError *error;
//	NSFileManager *fm = [NSFileManager defaultManager];
//	NSURL *cachesURL = [fm URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
//	STAssertNotNil(cachesURL, @"error creating caches directory url: %@", error);
//	_cacheDirectory = [cachesURL URLByAppendingPathComponent:ALEXJSONValidation_reverseDomainIdentifier];
//	BOOL created = [fm createDirectoryAtURL:_cacheDirectory withIntermediateDirectories:YES attributes:nil error:&error];
//	STAssertTrue(created, @"error creating our cache directory: %@", error);
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testTypeSuite {
	NSURL *fileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"type" withExtension:@"json"];
	[self runTestGroupAtFileURL:fileURL];
}

#pragma mark - helper methods

- (void)runTestGroupAtFileURL:(NSURL*)fileURL {
	NSLog(@"==== running test group '%@'", [fileURL lastPathComponent]);
	
	NSError *error;
	NSData *data = [NSData dataWithContentsOfURL:fileURL options:0 error:&error];
	STAssertNotNil(data, @"error loading test suite data: %@", error);
	NSArray *testGroup = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	STAssertNotNil(testGroup, @"error deserializing test suite json: %@", error);
	
	for (NSDictionary *testCase in testGroup) {
		[self runTestCase:testCase];
	}
	NSLog(@"====");
}

- (void)runTestCase:(NSDictionary*)testCase {
	NSString *description = testCase[@"description"];
	NSDictionary *schema = testCase[@"schema"];
	NSArray *tests = testCase[@"tests"];

	NSLog(@"---- running test case '%@'", description);
	
	for (NSDictionary *test in tests) {
		[self runTest:test withSchema:schema];
	}
}

- (void) runTest:(NSDictionary*)test withSchema:(NSDictionary*)schema {
	NSString *description = test[@"description"];
	id object = test[@"data"];
	BOOL shouldBeValid = [test[@"valid"] boolValue];
	
	NSLog(@"     running test '%@'", description);
	
	NSError *error;
	BOOL valid = [ALEXJSONValidation validateJSONObject:object forJSONSchema:schema error:&error];
	
	if (shouldBeValid) {
		STAssertTrue(valid, @"Test Suite test '%@' should be valid", description);
	}
	else {
		STAssertFalse(valid, @"Test Suite test '%@' should be invalid", description);
		STAssertNotNil(error, @"Test Suite test '%@' should generate an error", description);
	}
}

@end
