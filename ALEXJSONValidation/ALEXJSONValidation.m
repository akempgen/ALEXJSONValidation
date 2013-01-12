//
//  ALEXJSONValidation.m
//  ALEXJSONValidation
//
//  Created by Alexander Kempgen on 12.01.13.
//
//

#import "ALEXJSONValidation.h"

@interface ALEXJSONValidation ()

+ (BOOL)validateJSONObject:(id)object forJSONSchema:(id)schema error:(NSError**)error;

+ (id)validatedSchemaForURL:(NSURL*)schemaURL error:(NSError**)error;
+ (NSCache *)cache;

@end

@implementation ALEXJSONValidation

+ (BOOL)validateJSONObject:(id)object forJSONSchemaAtURL:(NSURL*)schemaURL options:(ALEXJSONValidationOptions)options error:(NSError**)error {
	NSParameterAssert([NSJSONSerialization isValidJSONObject:object]);
	NSParameterAssert([schemaURL isKindOfClass:[NSURL class]]);
	
	id schema = [self validatedSchemaForURL:schemaURL error:error];
	
    //	NSLog(@"schema: %@", schema);
	
	BOOL valid = (!schema?NO:[self validateJSONObject:object forJSONSchema:schema error:error]);
	
	return valid;
}

#pragma mark - Private

+ (BOOL)validateJSONObject:(id)object forJSONSchema:(NSDictionary*)schema error:(NSError**)error {
	NSParameterAssert(object); // leaf objects are accepted here
	NSParameterAssert([schema isKindOfClass:[NSDictionary class]]);
	BOOL valid = YES;
	
	id type = schema[@"type"];
	if (valid && type) {
		if ([type isKindOfClass:[NSArray class]]) {
			for (id allowedType in type) {
				valid = [self validateJSONObject:object forType:allowedType error:error];
				if (valid)
					break;
			}
		}
		else {
			valid = [self validateJSONObject:object forType:type error:error];
		}
			
	}
	
	
	return valid;
}



+(BOOL)validateJSONObject:(id)object forType:(id)type error:(NSError**)error {
	BOOL valid = YES;
	
	NSString *anyType		= @"any";
	NSString *stringType	= @"string";
	NSString *numberType	= @"number";
	NSString *integerType	= @"integer";
	NSString *booleanType	= @"boolean";
	NSString *objectType	= @"object";
	NSString *arrayType		= @"array";
	NSString *nullType		= @"null";
	
	if ([type isKindOfClass:[NSString class]]) {
		if (![type isEqualToString:anyType]) {
			// String
			if ([type isEqualToString:stringType]) {
				valid = [object isKindOfClass:[NSString class]];
			}
			// number
			else if ([type isEqualToString:numberType]) {
				valid = [object isKindOfClass:[NSNumber class]];
				if (valid)
					valid = (strncmp([(NSNumber*)object objCType], "q", 1) == 0
							 || strncmp([(NSNumber*)object objCType], "d", 1) == 0);
			}
			// integer
			else if ([type isEqualToString:integerType]) {
				valid = [object isKindOfClass:[NSNumber class]];
				if (valid)
					valid = (strncmp([(NSNumber*)object objCType], "q", 1) == 0);
			}
			// boolean
			else if ([type isEqualToString:booleanType]) {
				valid = [object isKindOfClass:[NSNumber class]];
				if (valid)
					valid = (strncmp([(NSNumber*)object objCType], "c", 1) == 0);
			}
			// object
			else if ([type isEqualToString:objectType]) {
				valid = [object isKindOfClass:[NSDictionary class]];
			}
			// array
			else if ([type isEqualToString:arrayType]) {
				valid = [object isKindOfClass:[NSArray class]];
			}
			// null
			else if ([type isEqualToString:nullType]) {
				valid = [object isKindOfClass:[NSNull class]];
			}
			
			else {
				valid = NO;
			}
		}
	}
	else {
		valid = [self validateJSONObject:object forJSONSchema:type error:error];
	}
	return valid;
}

+(id) validatedSchemaForURL:(NSURL*)schemaURL error:(NSError**)error {
	id schema = [self.cache objectForKey:schemaURL];
	if (!schema) {
		NSDate *startDate = [NSDate date];
		
		// Load the schema data from file or over the network
		NSData *data = [NSData dataWithContentsOfURL:schemaURL options:0 error:error];
		
		// Deserialize the schema
		if (data)
			schema = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
		
		// Validate the schema itself
		NSURL *validationSchemaURL = [NSURL URLWithString:@"http://json-schema.org/schema"];
		// TODO: not ideal, better avoid the loop differently. (ship the schema?)
		BOOL validSchema = ([schemaURL isEqual:validationSchemaURL]
							? YES
							: [self validateJSONObject:schema forJSONSchemaAtURL:validationSchemaURL options:0 error:error]);
		if (!validSchema)
			schema = nil;
		
		// Cache for future use
		if (schema) {
			NSTimeInterval timeInterval = [startDate timeIntervalSinceNow] * -1;
			NSUInteger cost = data.length*ceil(timeInterval);
			[self.cache setObject:schema forKey:schemaURL cost:cost];
		}
	}
	return schema;
}

+(NSCache *)cache {
	static NSCache *cache;
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		cache = [[NSCache alloc] init];
		cache.name = ALEXJSONValidation_reverseDomainIdentifier @".scheme-cache";
	});
	return cache;
}

@end
