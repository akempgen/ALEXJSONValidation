ALEXJSONValidation
==================

An Objective-C class to validate the output of NSJSONSerialization against a JSON Schema (http://json-schema.org).


API
---

ALEXJSONValidation has a single class method that does everything for you:

	@interface ALEXJSONValidation : NSObject

	+ (BOOL)validateJSONObject:(id)object forSchemaAtURL:(NSURL*)schemaURL options:(ALEXJSONValidationOptions)options error:(NSError**)error;

	@end

You just pass it the return value of -[NSJSONSerialization JSONObjectWithData:options:error:] and you're done.


Examples
--------

This example validates the base json schema against the hyper schema. It's actually one of the included tests.

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
	
	NSURL *schemaURL = [NSURL URLWithString:@"http://json-schema.org/hyper-schema"];
	
	NSError *validationError;
	BOOL success = [ALEXJSONValidation validateJSONObject:obj forSchemaAtURL:schemaURL options:0 error:&validationError];
	STAssertTrue(success, @"error: %@", validationError);

You could similarily use it to validate the responseJSON of an AFJSONRequestOperation.


Status
------

Currently passes some of the tests of the JSON Schema Test Suite (https://github.com/json-schema/JSON-Schema-Test-Suite) for draft 3 of the specification.


License
-------

© 2013 Alexander Kempgen, all rights reserved.


Version History
---------------

No stable releases.

