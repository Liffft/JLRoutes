//
//  NSURL+NSURL_JLRoutes.m
//  JLRoutes
//
//  Created by pair on 4/25/14.
//  Copyright (c) 2014 Afterwork Studios. All rights reserved.
//

#import "NSURL+JLRoutes.h"
#import "NSString+JLRoutes.h"
#import "JLRoutes.h"

@implementation NSURL (JLRoutes)

-(NSDictionary *)jlr_matchPattern:(NSString *)pattern {
    return [self parametersForURL:self pattern:pattern];
}

- (NSDictionary *)parametersForURL:(NSURL *)URL pattern:(NSString *)pattern {
	NSDictionary *routeParameters = nil;

    NSArray *URLComponents = [(URL.pathComponents ?: @[]) filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF like '/'"]];

    if ([URL.host rangeOfString:@"."].location == NSNotFound) {
		// For backward compatibility, handle scheme://path/to/ressource as if path was part of the
		// path if it doesn't look like a domain name (no dot in it)
		URLComponents = [@[URL.host] arrayByAddingObjectsFromArray:URLComponents];
	}
    
	[JLRoutes verboseLogWithFormat:@"URL path components: %@", URLComponents];

    NSArray *patternPathComponents = [[pattern pathComponents] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF like '/'"]];

	// do a quick component count check to quickly eliminate incorrect patterns
	BOOL componentCountEqual = URLComponents.count == patternPathComponents.count;
	BOOL routeContainsWildcard = !NSEqualRanges([pattern rangeOfString:@"*"], NSMakeRange(NSNotFound, 0));
	if (componentCountEqual || routeContainsWildcard) {
		// now that we've identified a possible match, move component by component to check if it's a match
		NSUInteger componentIndex = 0;
		NSMutableDictionary *variables = [NSMutableDictionary dictionary];
		BOOL isMatch = YES;

		for (NSString *patternComponent in patternPathComponents) {
			NSString *URLComponent = nil;
			if (componentIndex < [URLComponents count]) {
				URLComponent = URLComponents[componentIndex];
			} else if ([patternComponent isEqualToString:@"*"]) { // match /foo by /foo/*
				URLComponent = [URLComponents lastObject];
			}

			if ([patternComponent hasPrefix:@":"]) {
				// this component is a variable
				NSString *variableName = [patternComponent substringFromIndex:1];
				NSString *variableValue = URLComponent;
				if ([variableName length] > 0) {
					variables[variableName] = [variableValue JLRoutes_URLDecodedString];
				}
			} else if ([patternComponent isEqualToString:@"*"]) {
				// match wildcards
				variables[kJLRouteWildcardComponentsKey] = [URLComponents subarrayWithRange:NSMakeRange(componentIndex, URLComponents.count-componentIndex)];
				isMatch = YES;
				break;
			} else if (![patternComponent isEqualToString:URLComponent]) {
				// a non-variable component did not match, so this route doesn't match up - on to the next one
				isMatch = NO;
				break;
			}
			componentIndex++;
		}

		if (isMatch) {
			routeParameters = variables;
		}
	}

	return routeParameters;
}

+ (NSURL *)jlr_URLWithPattern:(NSString *)pattern parameters:(NSDictionary *)parameters
{
    NSCharacterSet *nonAlphaNumericCharacterSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];

    NSString *urlString = pattern;
    NSArray *keyArray = [[parameters allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 length] > [obj2 length] ? NSOrderedAscending : NSOrderedDescending;
    }];
    for (NSString *key in keyArray) {
        if(![key isKindOfClass:[NSString class]]) { return nil; }

        if ([key rangeOfCharacterFromSet:nonAlphaNumericCharacterSet].location != NSNotFound) {
            return nil;
        }
        NSString *valueString = [parameters objectForKey:key];
        NSString *keyString = [NSString stringWithFormat:@":%@", key];
        urlString = [urlString stringByReplacingOccurrencesOfString:keyString withString:valueString];
    }
    return [NSURL URLWithString:urlString];
}

@end
