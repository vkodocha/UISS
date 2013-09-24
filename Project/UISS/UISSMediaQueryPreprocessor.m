//
// Copyright (c) 2013 Brad Taylor. All rights reserved.
//

#import "UISSMediaQueryPreprocessor.h"

@implementation UISSMediaQueryPreprocessor

- (id)preprocessValueIfNecessary:(id)value userInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom;
{
    if ([value isKindOfClass:[NSDictionary class]]) {
        return [self preprocess:value userInterfaceIdiom:userInterfaceIdiom];
    } else {
        return value;
    }
}

- (NSDictionary *)preprocess:(NSDictionary *)dictionary userInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom;
{
    NSMutableDictionary *preprocessed = [NSMutableDictionary dictionary];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id object, BOOL *stop) {
        if ([key characterAtIndex:0] != '@' || [self evaluateMediaExpression:key]) {
            [preprocessed setObject:[self preprocessValueIfNecessary:object userInterfaceIdiom:userInterfaceIdiom]
                             forKey:key];
        }
    }];
    
    return preprocessed;
}

- (BOOL)evaluateMediaExpression:(NSString *)key
{
    static NSRegularExpression *regex = nil;
    if (!regex) {
        regex = [[NSRegularExpression alloc] initWithPattern:@"^@media\\s*\\(([\\w-]+):\\s*(\\w+)?\\)$"
                                                     options:0
                                                       error:nil];
    }
    
    for (NSTextCheckingResult *result in [regex matchesInString:key options:0 range:NSMakeRange(0, [key length])]) {
        NSString *feature = [key substringWithRange:[result rangeAtIndex:1]];
        NSString *expr = [key substringWithRange:[result rangeAtIndex:2]];
        CGFloat value = [[expr stringByReplacingOccurrencesOfString:@"px" withString:@""] floatValue];
        
        if (([feature isEqualToString:@"device-width"] && [UIScreen mainScreen].bounds.size.width != value)
            || ([feature isEqualToString:@"device-height"] && [UIScreen mainScreen].bounds.size.height != value)) {
            return NO;
        }
    }
    return YES;
}

@end
