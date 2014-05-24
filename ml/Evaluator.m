//
//  Evaluator.m
//  ml
//
//  Created by Yaroslav Nechaev on 24.05.14.
//  Copyright (c) 2014 2Eco. All rights reserved.
//

#import "Evaluator.h"

@implementation Evaluator

- (NSArray*) evaluate:(NSDictionary*)trainingSet
{
    NSDictionary* featureCounts = [self calculateFeatureCounts:trainingSet];
    NSDictionary* classTotals = [self calculateClassTotals:trainingSet];
    NSUInteger total = 0;
    for (NSString* classTotal in classTotals) {
        total += [[classTotals objectForKey:classTotal] integerValue];
    }
    
    __block NSMutableDictionary* answers = [NSMutableDictionary dictionary];
    __weak id weak_self = self;
    
    //Calculating metric
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_group_t group = dispatch_group_create();
    [featureCounts enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* feature, BOOL *stop) {
        dispatch_group_async(group, queue, ^{
            double score = [self calculateFeature:feature withClassTotals:classTotals withTotal:total];
            
            @synchronized(weak_self){
                [answers setObject:[NSNumber numberWithDouble:score] forKey:key];
            }
        });
    }];
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    //Sorting results
    NSArray* sortedFeatures = [[answers allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString* obj1, NSString* obj2) {
        double val1 = [[answers objectForKey:obj1] doubleValue];
        double val2 = [[answers objectForKey:obj2] doubleValue];
        if (val1 > val2) {
            return NSOrderedAscending;
        }
        if (val1 == val2) {
            return NSOrderedSame;
        }
        return NSOrderedDescending;
    }];
    
    NSMutableArray* result = [NSMutableArray array];
    for (NSString* feature in sortedFeatures) {
        [result addObject:@{@"feature":feature, @"score":[answers objectForKey:feature]}];
    }
    
    return result;
}

- (NSDictionary*) calculateFeatureCounts:(NSDictionary*)trainingSet
{
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    NSArray* classes = [trainingSet allKeys];
    
    [trainingSet enumerateKeysAndObjectsUsingBlock:^(NSString* klass, NSArray* samples, BOOL *stop) {
        for (NSSet* sample in samples) {
            for (NSString* feature in sample) {
                NSMutableDictionary* featureMatrix = [result objectForKey:feature];
                if (featureMatrix == nil) {
                    featureMatrix = [self dictWithKeys:classes];
                    [result setObject:featureMatrix forKey:feature];
                }
                
                [self increaseDictionary:featureMatrix forKey:klass By:1];
                [self increaseDictionary:featureMatrix forKey:@":total" By:1];
            }
        }
    }];
    
    return result;
}

- (NSDictionary*) calculateClassTotals:(NSDictionary*)trainingSet
{
    NSMutableDictionary* totals = [NSMutableDictionary dictionary];
    for (NSString* klass in [trainingSet allKeys]) {
        NSUInteger count = [[trainingSet objectForKey:klass] count];
        [totals setObject:[NSNumber numberWithInteger:count] forKey:klass];
    }
    
    return totals;
}

- (void) increaseDictionary:(NSMutableDictionary*)dict forKey:(NSString*)key By:(int) number
{
    NSNumber* curValue = [dict objectForKey:key];
    [dict setObject:@(curValue.intValue + number) forKey:key];
}

- (NSMutableDictionary*) dictWithKeys:(NSArray*) keys
{
    NSMutableDictionary* totals = [NSMutableDictionary dictionary];
    for (NSString* key in keys) {
        [totals setObject:@(0) forKey:key];
    }
    
    return totals;
}

- (double) calculateFeature:(NSDictionary*)feature withClassTotals:(NSDictionary*)classTotals withTotal:(NSUInteger)total
{
    NSLog(@"Tried to calculate with empty calculator");
    return 0;
}

@end
