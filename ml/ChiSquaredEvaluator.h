//
//  ChiSquaredEvaluator.h
//  ml
//
//  Created by Yaroslav Nechaev on 24.05.14.
//  Copyright (c) 2014 2Eco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Evaluator.h"

@interface ChiSquaredEvaluator : Evaluator

- (double) calculateFeature:(NSDictionary*)feature withClassTotals:(NSDictionary*)classTotals withTotal:(NSUInteger)total;

@end
