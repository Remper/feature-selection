//
//  ChiSquaredEvaluator.m
//  ml
//
//  Created by Yaroslav Nechaev on 24.05.14.
//  Copyright (c) 2014 2Eco. All rights reserved.
//

#import "ChiSquaredEvaluator.h"

@implementation ChiSquaredEvaluator

- (double) calculateFeature:(NSDictionary*)feature withClassTotals:(NSDictionary*)classTotals withTotal:(NSUInteger)total
{
    NSMutableDictionary* negativeFeature = [NSMutableDictionary dictionary];
    __block NSUInteger negativeTotal = 0;
    [classTotals enumerateKeysAndObjectsUsingBlock:^(NSString* klass, NSNumber* number, BOOL *stop) {
        NSUInteger curVal = number.integerValue - [[feature objectForKey:klass] integerValue];
        negativeTotal += curVal;
        [negativeFeature setObject:@(curVal) forKey:klass];
    }];
    [negativeFeature setObject:@(negativeTotal) forKey:@":total"];
    
    __block double chi = 0;
    [classTotals enumerateKeysAndObjectsUsingBlock:^(NSString* klass, NSNumber* number, BOOL *stop) {
        [@[feature, negativeFeature] enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
            double classTotal = number.doubleValue;
            double current = [[obj objectForKey:klass] doubleValue];
            double featureTotal = [[obj objectForKey:@":total"] doubleValue];
            double expected = classTotal * featureTotal / (double) total;
            chi += pow(expected - current, 2) / expected;
        }];
    }];
    
    return chi;
}

@end
