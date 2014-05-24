//
//  main.m
//  ml
//
//  Created by Yaroslav Nechaev on 23.05.14.
//  Copyright (c) 2014 2Eco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatasetCollector.h"
#import "ChiSquaredEvaluator.h"
#import "PMIEvaluator.h"

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   printf("Execution time: %f seconds\n", -[startTime timeIntervalSinceNow])

NSDictionary* parseInput(NSString* path)
{
    NSFileHandle* handle = [NSFileHandle fileHandleForReadingAtPath:path];
    
    DatasetCollector* collector = [[DatasetCollector alloc] init];
    NSString* buffer = @"";
    NSData* rawBuffer;
    int charsProcessed = 0;
    while ([(rawBuffer = [handle readDataOfLength:1024]) length] != 0) {
        NSString* oldBuffer = @"";
        if (charsProcessed != 0) {
            oldBuffer = [buffer substringFromIndex:buffer.length-charsProcessed];
        }
        
        int j = (int)[oldBuffer length];
        NSString* newPortion = [[NSString alloc] initWithData:rawBuffer encoding:NSUTF8StringEncoding];
        buffer = [NSString stringWithFormat:@"%@%@", oldBuffer, newPortion];
        for (int i = j; i < [buffer length]; i++) {
            char ch = [buffer characterAtIndex:i];
            switch (ch) {
                case '\n': {
                    [collector sampleFinished];
                    break;
                }
                case ' ': {
                    if (charsProcessed == 0) {
                        break;
                    }
                    
                    if (![collector hasKlass]) {
                        NSString* curString = [buffer substringWithRange:NSMakeRange(i-charsProcessed, charsProcessed)];
                        [collector addKlass:curString];
                    }
                    break;
                }
                case ':': {
                    if (charsProcessed == 0) {
                        break;
                    }
                    
                    [collector addFeature:[buffer substringWithRange:NSMakeRange(i-charsProcessed, charsProcessed)]];
                    break;
                }
                default: {
                    charsProcessed++;
                    continue;
                }
            }
            charsProcessed = 0;
        }
    }
    
    [handle closeFile];
    return [collector result];
}

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        
        //Defaults
        NSString *inputFile = @"sample.dat";
        NSString *saveFile = @"result.txt";
        NSString *metric = @"chi2";
        int featureCount = 10;
        
        if ([arguments count] > 4) {
            saveFile = arguments[4];
        }
        if ([arguments count] > 3) {
            featureCount = [arguments[3] intValue];
            if (featureCount < 0) {
                printf("This setting should be greater than zero. Falling back to defaults\n");
                featureCount = 10;
            }
        }
        if ([arguments count] > 2 && [[arguments[2] lowercaseString] isEqualToString:@"pmi"]) {
            metric = @"pmi";
        }
        if ([arguments count] > 1) {
            inputFile = arguments[1];
        }
        
        printf("Settings:\n   Input File: %s\n   Metric: %s\n   Feature count: %i\n   File to save: %s\n", [inputFile UTF8String], [metric UTF8String], featureCount, [saveFile UTF8String]);
        NSDictionary* input = parseInput(inputFile);
        if (![input count]) {
            printf("File was parsed incorrectly. Shutting down\n");
            return 0;
        }
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:3];
        
        Evaluator* evaluator;
        if ([metric isEqualToString:@"chi2"]) {
            evaluator = [[ChiSquaredEvaluator alloc] init];
        } else {
            evaluator = [[PMIEvaluator alloc] init];
        }
        
        printf("\nPrinting top %i features:\n", featureCount);
        TICK;
        NSArray* results = [evaluator evaluate:input];
        TOCK;
        NSString* resultString = @"";
        for (NSDictionary* feature in results) {
            featureCount--;
            resultString = [NSString stringWithFormat:@"%@%@\t%@\n", resultString, feature[@"feature"], [formatter stringFromNumber:feature[@"score"]]];
            if (featureCount == 0) {
                break;
            }
        }
        printf("%s", [resultString UTF8String]);
        [[NSFileManager defaultManager] createFileAtPath:saveFile
                                                contents:[resultString dataUsingEncoding:NSUTF8StringEncoding]
                                              attributes:nil];
    }
    return 0;
}