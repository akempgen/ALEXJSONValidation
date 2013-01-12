//
//  ALEXJSONValidation_Tests.m
//  ALEXJSONValidation Tests
//
//  Created by Alexander Kempgen on 12.01.13.
//
//

#import "ALEXJSONValidation_Tests.h"

#import "ALEXJSONValidation.h"

@implementation ALEXJSONValidation_Tests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testALEXJSONValidation
{
	NSDictionary *obj = @{@"name": @"Hans-Peter"};
	
	NSURL *schemaURL = [NSURL URLWithString:@"http://json-schema.org/schema"];
	
	NSError *error;
	BOOL success = [ALEXJSONValidation validateJSONObject:obj forJSONSchemaAtURL:schemaURL options:0 error:&error];
	STAssertTrue(success, @"error: %@", error);
}

@end
