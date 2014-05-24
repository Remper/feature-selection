//
//  DatasetCollector.h
//  ml
//
//  Created by Yaroslav Nechaev on 24.05.14.
//  Copyright (c) 2014 2Eco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatasetCollector : NSObject

- (void) addFeature:(NSString*) feature;
- (void) addKlass:(NSString*) klass;
- (void) sampleFinished;
- (bool) hasKlass;

- (NSDictionary*) result;

@end
