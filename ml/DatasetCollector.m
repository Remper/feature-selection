//
//  DatasetCollector.m
//  ml
//
//  Created by Yaroslav Nechaev on 24.05.14.
//  Copyright (c) 2014 2Eco. All rights reserved.
//

#import "DatasetCollector.h"

@implementation DatasetCollector
{
    NSString* curClass;
    NSMutableSet* curSample;
    NSMutableDictionary* result;
}

- (id)init
{
    self = [super init];
    if (self) {
        result = [NSMutableDictionary dictionary];
        curClass = nil;
        curSample = nil;
    }
    return self;
}

- (void) addFeature:(NSString*) feature
{
    //Assuming "0" class
    if (curSample == nil) {
        [self addKlass:@"0"];
    }
    
    [curSample addObject:feature];
}

- (void) addKlass:(NSString*) klass
{
    if ([self hasKlass]) {
        [self sampleFinished];
    }
    
    NSMutableArray* oldKlass = [result objectForKey:klass];
    if (oldKlass == nil) {
        [result setObject:[NSMutableArray array] forKey:klass];
    }
    curClass = klass;
    curSample = [NSMutableSet set];
}

- (bool) hasKlass
{
    return curClass != nil;
}

- (void) sampleFinished
{
    if (curSample != nil)
    {
        [[result objectForKey:curClass] addObject:curSample];
    }
    curSample = nil;
    curClass = nil;
}

- (NSDictionary*) result
{
    [self sampleFinished];
    return result;
}

@end
