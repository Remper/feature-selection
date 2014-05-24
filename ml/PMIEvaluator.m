//
//  PMIEvaluator.m
//  ml
//
//  Created by Yaroslav Nechaev on 24.05.14.
//  Copyright (c) 2014 2Eco. All rights reserved.
//

#import "PMIEvaluator.h"

@implementation PMIEvaluator

- (double) calculateFeature:(NSDictionary*)feature withClassTotals:(NSDictionary*)classTotals withTotal:(NSUInteger)total
{
    __block double pmi = 0;
    [classTotals enumerateKeysAndObjectsUsingBlock:^(NSString* klass, NSNumber* number, BOOL *stop) {
        double classTotal = number.doubleValue;
        double current = [[feature objectForKey:klass] doubleValue];
        double featureTotal = [[feature objectForKey:@":total"] doubleValue];
        
        if (current == 0) {
            pmi += 1;
            return;
        }
        pmi += fabs(log((current * (double) total) / (classTotal * featureTotal)) / log(current / (double) total));
    }];
    
    return pmi;
}

@end
