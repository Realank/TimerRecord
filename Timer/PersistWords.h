//
//  PersistWords.h
//  RainbowGet
//
//  Created by Realank on 2017/3/16.
//  Copyright © 2017年 Realank. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersistWords : NSObject

+(NSArray*)allWords;
+(void)addWordWithStart:(double)start period:(double)period wordid:(NSString*)wordID audioFileName:(NSString*)audioFileName;

@end
