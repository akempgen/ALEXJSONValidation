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

+ (NSCache *)cache;

@end

@implementation ALEXJSONValidation

+ (BOOL)validateJSONObject:(id)object forJSONSchema:(NSURL*)schemaURL options:(ALEXJSONValidationOptions)options error:(NSError**)error {
	NSParameterAssert([NSJSONSerialization isValidJSONObject:object]);
	
	
	
	return NO;
}

@end



@implementation ALEXJSONValidation (Private)

+(id) schemeForURL:(NSURL*)schemaURL {
	
	NSLog(@"cache: %@", self.cache.name);
	id schema = [self.cache objectForKey:schemaURL];
	
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
