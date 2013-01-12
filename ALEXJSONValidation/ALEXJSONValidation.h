//
//  ALEXJSONValidation.h
//  ALEXJSONValidation
//
//  Created by Alexander Kempgen on 12.01.13.
//
//

#import <Foundation/Foundation.h>

#define ALEXJSONValidation_reverseDomainIdentifier @"de.alexander-kempgen.alexjsonvalidation"

typedef NS_OPTIONS(NSUInteger, ALEXJSONValidationOptions) {
	ALEXJSONValidationDefaultOptions = 0,
};

@interface ALEXJSONValidation : NSObject

+ (BOOL)validateJSONObject:(id)object forJSONSchemaAtURL:(NSURL*)schemaURL options:(ALEXJSONValidationOptions)options error:(NSError**)error;

@end


@interface ALEXJSONValidation (Testing)

+ (BOOL)validateJSONObject:(id)object forJSONSchema:(id)schema error:(NSError**)error;

@end
