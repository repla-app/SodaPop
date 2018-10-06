//
//  POPPlugin+Validation.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "POPPlugin+Validation.h"
#import "POPConstants.h"

@implementation POPPlugin (Validation)

#pragma mark Validation

- (BOOL)validateExtensions:(id *)ioValue error:(NSError * __autoreleasing *)outError
{
    NSArray *extensions;
    if ([*ioValue isKindOfClass:[NSArray class]]) {
        extensions = *ioValue;
    }
    
    BOOL valid = [self extensionsAreValid:extensions];
    if (!valid && outError) {
        NSString *errorMessage = @"The file extensions must be unique, and can only contain alphanumeric characters.";
        NSString *errorString = NSLocalizedString(errorMessage, @"Invalid file extensions error.");
        
        NSDictionary *userInfoDict = @{NSLocalizedDescriptionKey: errorString};
        *outError = [[NSError alloc] initWithDomain:kErrorDomain
                                               code:kErrorCodeInvalidPlugin
                                           userInfo:userInfoDict];
    }
    
    return valid;
}

- (BOOL)validateName:(id *)ioValue error:(NSError * __autoreleasing *)outError
{
    NSString *name;
    if ([*ioValue isKindOfClass:[NSString class]]) {
        name = *ioValue;
    }
    
    BOOL valid = [self nameIsValid:name];
    if (!valid && outError) {
        NSString *errorMessage = @"The plugin name must be unique, and can only contain alphanumeric characters, spaces, hyphens and underscores.";
        NSString *errorString = NSLocalizedString(errorMessage, @"Invalid plugin name error.");
        
        NSDictionary *userInfoDict = @{NSLocalizedDescriptionKey: errorString};
        *outError = [[NSError alloc] initWithDomain:kErrorDomain
                                               code:kErrorCodeInvalidPlugin
                                           userInfo:userInfoDict];
    }
    
    return valid;
}

#pragma mark Name Public

+ (BOOL)nameContainsOnlyValidCharacters:(NSString *)name
{
    return [self string:name containsOnlyCharactersInCharacterSet:[[self class] nameAllowedCharacterSet]];
}

- (BOOL)nameIsValid:(NSString *)name
{
    if (!name) {
        return NO;
    }

    if (![POPPlugin nameContainsOnlyValidCharacters:name]) {
        return NO;
    }

    if (![self.uniqueNameDataSource isUniqueName:name forPlugin:(POPPlugin *)self]) {
        return NO;
    }

    return YES;
}

- (NSString *)identifier
{
    NSAssert(NO, @"Subclass must override");
    return nil;
}

+ (NSCharacterSet *)nameAllowedCharacterSet
{
    NSMutableCharacterSet *allowedCharacterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"_- "];
    [allowedCharacterSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];

    return allowedCharacterSet;
}

#pragma mark File Extensions Public

- (BOOL)extensionsAreValid:(NSArray *)extensions
{
    NSCountedSet *extensionsCountedSet = [[NSCountedSet alloc] initWithArray:extensions];
    for (NSString *extension in extensionsCountedSet) {
        if (![extension isKindOfClass:[NSString class]] || // Must be a string
            !(extension.length > 0) || // Must be greater than zero characters
            !([[self class] extensionContainsOnlyValidCharacters:extension])) { // Must only contain valid characters
            return NO;
        }

        if ([extensionsCountedSet countForObject:extension] > 1) {
            // Must not contain duplicates
            return NO;
        }
    }

    return YES;
}

+ (NSArray *)validExtensionsFromExtensions:(NSArray *)extensions
{
    NSMutableArray *validExtensions = [NSMutableArray array];
    for (NSString *fileExtension in extensions) {
        NSString *validFileExtension = [[self class] extensionContainingOnlyValidCharactersFromExtension:fileExtension];
        if (validFileExtension &&
            ![validExtensions containsObject:validFileExtension]) {
            [validExtensions addObject:validFileExtension];
        }
    }

    return validExtensions;
}

#pragma mark File Extensions Private

+ (BOOL)extensionContainsOnlyValidCharacters:(NSString *)extension
{
    return [self string:extension containsOnlyCharactersInCharacterSet:[self fileExtensionAllowedCharacterSet]];
}

+ (NSString *)extensionContainingOnlyValidCharactersFromExtension:(NSString *)extension
{
    NSCharacterSet *disallowedCharacterSet = [[self fileExtensionAllowedCharacterSet] invertedSet];

    NSString *validExtension = [[extension componentsSeparatedByCharactersInSet:disallowedCharacterSet] componentsJoinedByString:@""];

    if (!(validExtension.length > 0)) {
        return nil;
    }

    return validExtension;
}

+ (NSCharacterSet *)fileExtensionAllowedCharacterSet
{
    return [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
}

#pragma mark Helpers

+ (BOOL)string:(NSString *)string containsOnlyCharactersInCharacterSet:(NSCharacterSet *)characterSet
{
    NSCharacterSet *invertedCharacterSet = [characterSet invertedSet];

    NSRange disallowedRange = [string rangeOfCharacterFromSet:invertedCharacterSet];
    BOOL foundCharacterInInvertedSet = !(NSNotFound == disallowedRange.location);

    return !foundCharacterInInvertedSet;
}
@end
