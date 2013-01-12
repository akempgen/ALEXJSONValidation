//
//  ALEXJSONValidation.h
//  ALEXJSONValidation
//
//  Created by Alexander Kempgen on 12.01.13.
//
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, ALEXJSONValidationOptions) {
	ALEXJSONValidationDefaultOptions = 0,
};

@interface ALEXJSONValidation : NSObject

+ (BOOL)validateJSONObject:(id)object forJSONSchema:(NSURL*)schemaURL options:(ALEXJSONValidationOptions)options error:(NSError**)error;

@end
