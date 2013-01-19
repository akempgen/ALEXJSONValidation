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
//	NSDictionary *obj = @{@"name": @"Hans-Peter"};
		
	NSError *inputError;
	NSURL *url = [NSURL URLWithString:@"http://json-schema.org/schema"];
	NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&inputError];
	if (!data) {
		STFail(@"error fetching input data: %@", inputError);
	}
	NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&inputError];
	if (!obj) {
		STFail(@"error deserializing json: %@", inputError);
	}
	NSLog(@"Obj: %@", obj);
	
	NSURL *schemaURL = [NSURL URLWithString:@"http://json-schema.org/hyper-schema"];
	
	NSError *error;
	BOOL success = [ALEXJSONValidation validateJSONObject:obj forSchemaAtURL:schemaURL options:0 error:&error];
	STAssertTrue(success, @"error: %@", error);
}

@end
