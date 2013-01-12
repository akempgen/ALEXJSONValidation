//
//  ALEXJSONValidation.m
//  ALEXJSONValidation
//
//  Created by Alexander Kempgen on 12.01.13.
//
//

#import "ALEXJSONValidation.h"

#define ALEXJSONValidation_reverseDomainIdentifier @"de.alexander-kempgen.alexjsonvalidation"


@interface ALEXJSONValidation (Private)

+ (id)validatedSchemaForURL:(NSURL*)schemaURL error:(NSError**)error;
+ (NSCache *)cache;

@end

@implementation ALEXJSONValidation

+ (BOOL)validateJSONObject:(id)object forJSONSchemaAtURL:(NSURL*)schemaURL options:(ALEXJSONValidationOptions)options error:(NSError**)error {
	NSParameterAssert([NSJSONSerialization isValidJSONObject:object]);
	NSParameterAssert([schemaURL isKindOfClass:[NSURL class]]);
	
	id schema = [self validatedSchemaForURL:schemaURL error:error];
	
	return schema != nil;
}

@end



@implementation ALEXJSONValidation (Private)

+(id) validatedSchemaForURL:(NSURL*)schemaURL error:(NSError**)error {
	id schema = [self.cache objectForKey:schemaURL];
	if (!schema) {
		NSDate *startDate = [NSDate date];
		
		// Load the schema data either from file or over the network
		NSData *data;
		if ([schemaURL isFileURL]) {
			data = [NSData dataWithContentsOfURL:schemaURL options:0 error:error];
		}
		else {
			NSURLRequest *URLRequest = [NSURLRequest requestWithURL:schemaURL];
			data = [NSURLConnection sendSynchronousRequest:URLRequest returningResponse:NULL error:error];
		}
		
		// Deserialize the schema
		if (data)
			schema = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
		
		// Validate the schema itself
		NSURL *hyperSchemaURL = [NSURL URLWithString:@"http://json-schema.org/hyper-schema"];
		// TODO: not ideal, better avoid the loop differently. (ship the schema?)
		BOOL validSchema = ([schemaURL isEqual:hyperSchemaURL]
							? YES
							: [self validateJSONObject:schema forJSONSchemaAtURL:hyperSchemaURL options:0 error:error]);
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
