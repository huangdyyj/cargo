//
//  CGDataManager.h
//  cargo
//
//  Created by kobewong on 10/10/2016.
//  Copyright © 2016 l99. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CGDataManager : NSObject

@property (nonatomic, strong) CLLocation *currentLocation;

+ (CGDataManager *)sharedManager;


@end
