//
//  main.m
//  nslogify
//
//  Created by Sam Gardner on 7/26/19.
//  Copyright © 2019 Sam Gardner. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        if ([arguments count] != 2) {
            printf("Usage: nslogify <FILE>\n");
            exit(0);
        }
        NSString *orig = [NSString stringWithContentsOfFile:[[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:[arguments objectAtIndex:1]] encoding:NSUTF8StringEncoding error:nil];
        NSArray *header = [orig componentsSeparatedByString:[NSString stringWithFormat:@"\n"]];
        NSMutableArray *methods = [[NSMutableArray alloc] init];
        NSString *className;
        for (NSString *line in header) {
            if ([line hasPrefix:@"+"] || [line hasPrefix:@"-"]) {
                [methods addObject:line];
            } else if ([line hasPrefix:@"@interface "]) {
                NSRange searchFromRange = [line rangeOfString:@"@interface "];
                NSRange searchToRange;
                if ([line containsString:@":"]) {
                    searchToRange = [line rangeOfString:@" :"];
                } else {
                    searchToRange = [line rangeOfString:@";"];
                }
                className = [line substringWithRange:NSMakeRange(searchFromRange.location+searchFromRange.length, searchToRange.location-searchFromRange.location-searchFromRange.length)];
            }
        }
        NSMutableArray *parsedMethods = [[NSMutableArray alloc] init];
        for (NSString *methodUnparsed in methods) {
            NSString *method = [methodUnparsed stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([method containsString:@"(void)"]) {
                NSRange searchFromRange = [method rangeOfString:@")"];
                NSRange searchToRange;
                if ([method containsString:@":"]) {
                    searchToRange = [method rangeOfString:@":"];
                } else {
                    searchToRange = [method rangeOfString:@";"];
                }
                NSString *methodName = [method substringWithRange:NSMakeRange(searchFromRange.location+searchFromRange.length, searchToRange.location-searchFromRange.location-searchFromRange.length)];
                NSString *newMethod = [method stringByReplacingOccurrencesOfString:@";" withString:[NSString stringWithFormat:@"{\n    NSLog(@\"NSLOGIFY: METHOD %@ CALLED\");\n    %%orig;\n}", methodName]];
                [parsedMethods addObject:newMethod];
            } else {
                NSString *method = [methodUnparsed stringByReplacingOccurrencesOfString:@" " withString:@""];
                if ([method containsString:@"(void)"]) {
                    NSRange searchFromRange = [method rangeOfString:@")"];
                    NSRange searchToRange;
                    if ([method containsString:@":"]) {
                        searchToRange = [method rangeOfString:@":"];
                    } else {
                        searchToRange = [method rangeOfString:@";"];
                    }
                    NSString *methodName = [method substringWithRange:NSMakeRange(searchFromRange.location+searchFromRange.length, searchToRange.location-searchFromRange.location-searchFromRange.length)];
                    NSString *newMethod = [method stringByReplacingOccurrencesOfString:@";" withString:[NSString stringWithFormat:@"{\n    NSLog(@\"NSLOGIFY: METHOD %@ CALLED\");\n    return %%orig;\n}", methodName]];
                    [parsedMethods addObject:newMethod];
                }
            }
        }
        NSString *parsedMethodsString = [parsedMethods componentsJoinedByString:[NSString stringWithFormat:@"\n"]];
        NSString *new = [[[[[[[[[[[[[NSString stringWithFormat:@"%%hook %@\n\n%@\n\n%%end\n", className, parsedMethodsString] stringByReplacingOccurancesOfString:@"unsignedlong" withString:@"unsigned long"] stringByReplacingOccurancesOfString:@"longlong" withString:@"long long"] stringByReplacingOccurancesOfString:@"arg10" withString:@"arg10 "] stringByReplacingOccurancesOfString:@"arg9" withString:@"arg9 "] stringByReplacingOccurancesOfString:@"arg8" withString:@"arg8 "] stringByReplacingOccurancesOfString:@"arg7" withString:@"arg7 "]  stringByReplacingOccurancesOfString:@"arg6" withString:@"arg6 "] stringByReplacingOccurancesOfString:@"arg5" withString:@"arg5 "] stringByReplacingOccurancesOfString:@"arg4" withString:@"arg4 "] stringByReplacingOccurancesOfString:@"arg3" withString:@"arg3 "] stringByReplacingOccurancesOfString:@"arg2" withString:@"arg2 "] stringByReplacingOccurancesOfString:@"arg1" withString:@"arg1 "];
        [new writeToFile:[[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:@"nslogify.x"] atomically:TRUE encoding:NSUTF8StringEncoding error:nil];
    }
    return 0;
	}