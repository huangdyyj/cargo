//
//  CGDataManager.m
//  cargo
//
//  Created by kobewong on 10/10/2016.
//  Copyright © 2016 l99. All rights reserved.
//

#import "CGDataManager.h"

@implementation CGDataManager


#pragma mark - public

+ (CGDataManager *)sharedManager {
    static CGDataManager *staticDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticDataManager = [[self alloc] init];
    });
    
    return staticDataManager;
}


@end
