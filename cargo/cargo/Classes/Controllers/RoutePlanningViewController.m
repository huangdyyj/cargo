//
//  RoutePlanningViewController.m
//  cargo
//
//  Created by kobewong on 11/10/2016.
//  Copyright © 2016 l99. All rights reserved.
//

#import "RoutePlanningViewController.h"
#import "MANaviRoute.h"
#import "RouteDetailViewController.h"




@interface RoutePlanningViewController ()

@property (nonatomic, strong) AMapRoute *route;

/* 当前路线方案索引值. */
@property (nonatomic) NSInteger currentCourse;

/* 路线方案个数. */
@property (nonatomic) NSInteger totalCourse;

/* 起始点经纬度. */
@property (nonatomic) CLLocationCoordinate2D startCoordinate;
/* 终点经纬度. */
@property (nonatomic) CLLocationCoordinate2D destinationCoordinate;

/* 用于显示当前路线方案. */
@property (nonatomic) MANaviRoute * naviRoute;

@property (nonatomic, strong) MAPointAnnotation *startAnnotation;
@property (nonatomic, strong) MAPointAnnotation *destinationAnnotation;


@end






@implementation RoutePlanningViewController



#pragma mark - private





#pragma mark - super




@end
