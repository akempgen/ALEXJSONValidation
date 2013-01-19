//
//  ALEXJSONValidation.m
//  ALEXJSONValidation
//
//  Created by Alexander Kempgen on 12.01.13.
//
//

#import "ALEXJSONValidation.h"

#pragma mark Private Interface

@interface ALEXJSONValidation (Private)

+ (id)validatedSchemaForURL:(NSURL*)schemaURL error:(NSError**)error;
+ (NSCache *)cache;

+ (BOOL)validateJSONObject:(id)object forSchema:(NSDictionary*)schema error:(NSError**)error;
+ (BOOL)validateJSONObject:(id)object forSchema:(NSDictionary*)schema rootSchema:(NSDictionary*)rootSchema error:(NSError**)error;
+(BOOL)validateJSONObject:(id)object forType:(id)type rootSchema:(NSDictionary*)rootSchema error:(NSError**)error;
@end

#pragma mark - Implementation

@implementation ALEXJSONValidation

+ (BOOL)validateJSONObject:(id)object forSchemaAtURL:(NSURL*)schemaURL options:(ALEXJSONValidationOptions)options error:(NSError**)error {
	NSParameterAssert([NSJSONSerialization isValidJSONObject:object]);
	NSParameterAssert([schemaURL isKindOfClass:[NSURL class]]);
	
	id schema = [self validatedSchemaForURL:schemaURL error:error];
	
    //	NSLog(@"schema: %@", schema);
	
	BOOL valid = (!schema?NO:[self validateJSONObject:object forSchema:schema error:error]);
	
	return valid;
}

@end

#pragma mark - Private Implementation

@implementation ALEXJSONValidation (Private)

#pragma mark Load Schema

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
		//		NSURL *validationSchemaURL = [NSURL URLWithString:@"http://json-schema.org/schema"];
		// TODO: not ideal, better avoid the loop differently. (ship the schema?)
		//		BOOL validSchema = ([schemaURL isEqual:validationSchemaURL]
		//							? YES
		//							: [self validateJSONObject:schema forSchemaAtURL:validationSchemaURL options:0 error:error]);
		//		if (!validSchema)
		//			schema = nil;
		
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

#pragma mark Validation

+ (BOOL)validateJSONObject:(id)object forSchema:(NSDictionary*)schema error:(NSError**)error {
	return [self validateJSONObject:object forSchema:schema rootSchema:schema error:error];
}

+ (BOOL)validateJSONObject:(id)object forSchema:(NSDictionary*)schema rootSchema:(NSDictionary*)rootSchema error:(NSError**)error {
//	NSLog(@"%s object: %@ schema: %@", __PRETTY_FUNCTION__, object, schema);
	NSParameterAssert([schema isKindOfClass:[NSDictionary class]]);
	
	// $ref is a special case, current schema will be replaced with a different one
//	NSString *dollarRef = schema[@"$ref"];
//	if (dollarRef) {
//		//			NSDictionary *newRootSchema =[self validatedSchemaForURL:firstPart error:error];
//		
//		NSRange hashRange = [dollarRef rangeOfString:@"#"];
//		if (hashRange.location == NSNotFound) {
//			return NO;
//		}
//		NSLog(@"range: %@", NSStringFromRange(hashRange));
//		NSString *schemaURI = [dollarRef substringToIndex:hashRange.location];
//		NSString *jsonPath = [dollarRef substringFromIndex:hashRange.location+hashRange.length];
//		NSDictionary *newRootSchema = rootSchema;
//		// TODO: if schemaURI.length -> newRootSchema = validatedSchemaAtURL
//		
//		NSLog(@"schemaURI: '%@' path: '%@'", schemaURI, jsonPath);
//		NSArray *jsonKeys = [jsonPath componentsSeparatedByString:@"/"];
//		NSMutableArray *keyPaths = [NSMutableArray arrayWithCapacity:[jsonKeys count]];
//		for (NSString *jsonKey in jsonKeys) {
//			if ([jsonKey length]) {
//				[keyPaths addObject:jsonKey];
//			}
//		}
//#warning keypath is not enough, it can also contain array indexes
//		NSString *keyPath = [keyPaths componentsJoinedByString:@"."];
//		NSLog(@"keyPath: %@", keyPath);
//		NSDictionary *refSchema = [rootSchema valueForKeyPath:keyPath];
//		if (![refSchema isKindOfClass:[NSDictionary class]]) {
//			return NO;
//		}
//		else {
//			return [self validateJSONObject:object forSchema:refSchema rootSchema:newRootSchema error:error];
//		}
//	}
	
	// normal validation starts here
	
	BOOL valid = YES;
	// required
	if (valid) {
		if ([schema[@"required"] boolValue]) {
			valid = (object != nil);
		}
	}
	
	// type
	if (valid) {
		id type = schema[@"type"];
		if ([type isKindOfClass:[NSArray class]]) {
			for (id allowedType in type) {
				valid = [self validateJSONObject:object forType:allowedType rootSchema:rootSchema error:error];
				if (valid)
					break;
			}
		}
		else if (type) {
			valid = [self validateJSONObject:object forType:type rootSchema:rootSchema error:error];
		}
			
	}
	
	// properties
	if (valid) {
		id properties = schema[@"properties"];
//		NSLog(@"object class: %@ properties: %@", NSStringFromClass([object class]), properties);
		for (NSString *property in properties) {
			valid = [self validateJSONObject:object[property] forSchema:properties[property] rootSchema:rootSchema error:error];
			if (!valid)
				break;
		}
		
		// additional properties
		id additionalProperties = schema[@"additionalProperties"];
		if ([additionalProperties isKindOfClass:[NSNumber class]]) {
			if ([additionalProperties boolValue] == NO) {
				for (NSString *property in object) {
					valid = (properties[property] != nil);
					if (!valid)
						break;
				}
			}
		}
		else if (additionalProperties) {
			for (NSString *property in object) {
				if (!properties[property]) {
					valid = [self validateJSONObject:object[property] forSchema:additionalProperties rootSchema:rootSchema error:error];
					if (!valid)
						break;
				}
			}
		}
	}
	
	// dependencies
	if (valid) {
		id dependencies = schema[@"dependencies"];
		for (NSString *dependendingProperty in dependencies) {
			if (object[dependendingProperty]) {
				id dependency = dependencies[dependendingProperty];
				if ([dependency isKindOfClass:[NSString class]]) {
					valid = (object[dependency] != nil);
				}
				else if ([dependency isKindOfClass:[NSArray class]]) {
					for (NSString *dependencySubkey in dependency) {
						valid = (object[dependencySubkey] != nil);
						if (!valid)
							break;
					}
				}
				else if (dependency) {
					valid = [self validateJSONObject:object forSchema:dependency rootSchema:rootSchema error:error];
				}
			}
			if (!valid)
				break;
		}
	}
	
	// 5.1. Validation keywords for numeric instances (number and integer)
	if (valid && [object isKindOfClass:[NSNumber class]]) {
		// maximum
		if (valid) {
			NSNumber *maximum = schema[@"maximum"];
			if (maximum) {
				BOOL exclusiveMaximum = [schema[@"exclusiveMaximum"] boolValue];
				if (exclusiveMaximum)
					valid = ([object doubleValue] < [maximum doubleValue]);
				else
					valid = ([object doubleValue] <= [maximum doubleValue]);
			}
		}
		// minimum
		if (valid) {
			NSNumber *minimum = schema[@"minimum"];
			if (minimum) {
				BOOL exclusiveMinimum = [schema[@"exclusiveMinimum"] boolValue];
				if (exclusiveMinimum)
					valid = ([object doubleValue] > [minimum doubleValue]);
				else
					valid = ([object doubleValue] >= [minimum doubleValue]);
			}
		}
	}
	
	// 5.2. Validation keywords for strings
	if (valid && [object isKindOfClass:[NSString class]]) {
		// maxLength
		if (valid) {
			NSNumber *maxLength = schema[@"maxLength"];
			if (maxLength) {
				valid = ([object length] <= [maxLength unsignedIntegerValue]);
			}
		}
		
		// minLength
		if (valid) {
			NSNumber *minLength = schema[@"minLength"];
			if (minLength) {
				valid = ([object length] >= [minLength unsignedIntegerValue]);
			}
		}
	}
	
	// 5.3. Validation keywords for arrays
	if (valid && [object isKindOfClass:[NSArray class]]) {
		// maxItems
		if (valid) {
			NSNumber *maxItems = schema[@"maxItems"];
			if (maxItems) {
				valid = ([object count] <= [maxItems unsignedIntegerValue]);
			}
		}
		// minItems
		if (valid) {
			NSNumber *minItems = schema[@"minItems"];
			if (minItems) {
				valid = ([object count] >= [minItems unsignedIntegerValue]);
			}
		}
		// uniqueItems
		if (valid) {
			BOOL uniqueItems = [schema[@"uniqueItems"] boolValue];
			if (uniqueItems) {
				// TODO: fails 3 uniqueItems tests, because @1 and @YES are considered equal in cocoa, but not in json
				NSSet *set = [NSSet setWithArray:object];
				valid = ([object count] == [set count]);
			}
		}
		// items
		if (valid) {
			id items = schema[@"items"];
			if ([items isKindOfClass:[NSArray class]]) {
//				NSLog(@"items: %@ object: %@", items, object);
				NSUInteger tupleIndex = 0;
				for (NSDictionary *tupleSchema in items) {
					id tupleObject = (tupleIndex < [object count]?object[tupleIndex]:nil);
					valid = [self validateJSONObject:tupleObject forSchema:tupleSchema rootSchema:rootSchema error:error];
					if (!valid)
						break;
					tupleIndex++;
				}
				
				id additionalItems = schema[@"additionalItems"];
				if ([additionalItems isKindOfClass:[NSNumber class]]) {
					if ([additionalItems boolValue] == NO) {
						valid = ([object count] <= [items count]);
					}
				}
				else if (additionalItems) {
					for (NSUInteger index = [items count]; index < [object count]; index++) {
						valid = [self validateJSONObject:object[index] forSchema:additionalItems rootSchema:rootSchema error:error];
						if (!valid)
							break;
					}
				}
				
			}
			else if (items) {
				for (id arrayObject in object) {
					valid = [self validateJSONObject:arrayObject forSchema:items rootSchema:rootSchema error:error];
					if (!valid)
						break;
				}
			}
		}
	}
	
	return valid;
}



+(BOOL)validateJSONObject:(id)object forType:(id)type rootSchema:(NSDictionary*)rootSchema error:(NSError**)error {
//	NSLog(@"%s object: %@ type: %@", __PRETTY_FUNCTION__, object, type);
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
				// TODO: these 4 checks are not good at all
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
		valid = [self validateJSONObject:object forSchema:type rootSchema:rootSchema error:error];
	}
	return valid;
}


@end
