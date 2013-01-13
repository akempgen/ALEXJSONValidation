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
	NSBundle *_testBundle;
}

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
	if (!_testBundle)
		_testBundle = [NSBundle bundleForClass:[self class]];
}

- (void)tearDown
{
    // Tear-down code here.
	
    [super tearDown];
}

//- (void)testAdditionalItems {
//	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"additionalItems" withExtension:@"json"]];
//}

//- (void)testAdditionalProperties {
//	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"additionalProperties" withExtension:@"json"]];
//}

//- (void)testDependencies {
//	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"dependencies" withExtension:@"json"]];
//}

//- (void)testDisallow {
//	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"disallow" withExtension:@"json"]];
//}

//- (void)testDivisibleBy {
//	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"divisibleBy" withExtension:@"json"]];
//}

//- (void)testEnum {
//	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"enum" withExtension:@"json"]];
//}

//- (void)testExtends {
//	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"extends" withExtension:@"json"]];
//}

//- (void)testItems {
//	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"items" withExtension:@"json"]];
//}

- (void)testMaximum {
	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"maximum" withExtension:@"json"]];
}

- (void)testMaxItems {
	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"maxItems" withExtension:@"json"]];
}

- (void)testMaxLength {
	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"maxLength" withExtension:@"json"]];
}

- (void)testMinimum {
	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"minimum" withExtension:@"json"]];
}

- (void)testMinItems {
	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"minItems" withExtension:@"json"]];
}

- (void)testMinLength {
	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"minLength" withExtension:@"json"]];
}

// optional
//- (void)testBignum {
//	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"bignum" withExtension:@"json"]];
//}

//- (void)testFormat {
//	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"format" withExtension:@"json"]];
//}

// end optional

//- (void)testPattern {
//	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"pattern" withExtension:@"json"]];
//}

//- (void)testPatternProperties {
//	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"patternProperties" withExtension:@"json"]];
//}

//- (void)testProperties {
//	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"properties" withExtension:@"json"]];
//}

//- (void)testRef {
//	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"ref" withExtension:@"json"]];
//}

- (void)testRequired {
	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"required" withExtension:@"json"]];
}

- (void)testType {
	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"type" withExtension:@"json"]];
}

// TODO: fails 3 uniqueItems tests, because @1 and @YES are considered equal in cocoa, but not in json
//- (void)testUniqueItems {
//	[self runTestGroupAtFileURL:[_testBundle URLForResource:@"uniqueItems" withExtension:@"json"]];
//}


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
//		STAssertNotNil(error, @"Test Suite test '%@' should generate an error", description);
	}
}

@end
