//
//  ALEXJSONValidation.h
//  ALEXJSONValidation
//
//  Created by Alexander Kempgen on 12.01.13.
//
//

#import <Foundation/Foundation.h>

#define ALEXJSONValidation_reverseDomainIdentifier @"alexjsonvalidation"

//typedef NS_OPTIONS(NSUInteger, ALEXJSONValidationOptions) {
//	ALEXJSONValidationOptionsFollowSchemaURIs = 1 << 0,
//};
typedef NSUInteger ALEXJSONValidationOptions;

@interface ALEXJSONValidation : NSObject

+ (BOOL)validateJSONObject:(id)object forSchemaAtURL:(NSURL*)schemaURL options:(ALEXJSONValidationOptions)options error:(NSError**)error;

@end


@interface ALEXJSONValidation (Testing)

+ (BOOL)validateJSONObject:(id)object forSchema:(NSDictionary*)schema error:(NSError**)error;

@end
