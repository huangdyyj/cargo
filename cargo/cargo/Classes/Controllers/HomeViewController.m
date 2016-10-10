//
//  ViewController.m
//  cargo
//
//  Created by kobewong on 10/10/2016.
//  Copyright © 2016 l99. All rights reserved.
//

#import "HomeViewController.h"
#import "POIAnnotation.h"
//#import "PoiDetailViewController.h"
#import "CommonUtility.h"
#import "SearchViewController.h"

typedef NS_ENUM(NSInteger, AMapPOISearchType)
{
    AMapPOISearchTypeID = 0,
    AMapPOISearchTypeKeywords,
    AMapPOISearchTypeAround,
    AMapPOISearchTypePolyline
};

@interface HomeViewController ()

@property (nonatomic) AMapPOISearchType poiSearchType;

@end

@implementation HomeViewController




#pragma mark - private

- (void)startTrackingLocation {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            [_locationManager requestWhenInUseAuthorization];
        } else {
            [_locationManager startUpdatingLocation]; //启动位置管理器
        }
    }
    else if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [_locationManager startUpdatingLocation]; //启动位置管理器
    }
}

- (void)clickSearchBtn {
    SearchViewController *vc = [[SearchViewController alloc] init];
    [self.navigationController pushViewController:vc animated:NO];
}




#pragma mark - MAMapViewDelegate

//- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
//{
//    id<MAAnnotation> annotation = view.annotation;
//    
//    if ([annotation isKindOfClass:[POIAnnotation class]])
//    {
//        POIAnnotation *poiAnnotation = (POIAnnotation*)annotation;
//        
//        PoiDetailViewController *detail = [[PoiDetailViewController alloc] init];
//        detail.poi = poiAnnotation.poi;
//        
//        /* 进入POI详情页面. */
//        [self.navigationController pushViewController:detail animated:YES];
//    }
//}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[POIAnnotation class]])
    {
        static NSString *poiIdentifier = @"poiIdentifier";
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:poiIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:poiIdentifier];
        }
        
        poiAnnotationView.canShowCallout = YES;
        poiAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return poiAnnotationView;
    }
    
    return nil;
}

#pragma mark - AMapSearchDelegate

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    NSLog(@"error = %@", error);
}

/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (response.pois.count == 0)
    {
        return;
    }
    
    NSMutableArray *poiAnnotations = [NSMutableArray arrayWithCapacity:response.pois.count];
    
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        
        [poiAnnotations addObject:[[POIAnnotation alloc] initWithPOI:obj]];
        
    }];
    
    /* 将结果以annotation的形式加载到地图上. */
    [self.mapView addAnnotations:poiAnnotations];
    
    /* 如果只有一个结果，设置其为中心点. */
    if (poiAnnotations.count == 1)
    {
        [self.mapView setCenterCoordinate:[poiAnnotations[0] coordinate]];
    }
    /* 如果有多个结果, 设置地图使所有的annotation都可见. */
    else
    {
        [self.mapView showAnnotations:poiAnnotations animated:NO];
    }
}

#pragma mark - Utility

/* 根据ID来搜索POI. */
- (void)searchPoiByID
{
    AMapPOIIDSearchRequest *request = [[AMapPOIIDSearchRequest alloc] init];
    
    request.uid                 = @"B000A7ZQYC";
    request.requireExtension    = YES;
    
    [self.search AMapPOIIDSearch:request];
    
}

/* 根据关键字来搜索POI. */
- (void)searchPoiByKeyword:(NSString *)searchKey
{
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    
    request.keywords            = searchKey;
//    request.city                = @"北京";      // wong.todo - 根据当前所在的城市设定该值
//    request.types               = @"高等院校";
    request.requireExtension    = YES;
    
    /*  搜索SDK 3.2.0 中新增加的功能，只搜索本城市的POI。*/
//    request.cityLimit           = YES;
//    request.requireSubPOIs      = YES;
    
    [self.search AMapPOIKeywordsSearch:request];
}

/* 根据中心点坐标来搜周边的POI. */
- (void)searchPoiByCenterCoordinate
{
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    
    request.location            = [AMapGeoPoint locationWithLatitude:39.990459 longitude:116.481476];
    request.keywords            = @"电影院";
    /* 按照距离排序. */
    request.sortrule            = 0;
    request.requireExtension    = YES;
    
    [self.search AMapPOIAroundSearch:request];
}

/* 在指定的范围内搜索POI. */
- (void)searchPoiByPolygon
{
    NSArray *points = [NSArray arrayWithObjects:
                       [AMapGeoPoint locationWithLatitude:39.990459 longitude:116.481476],
                       [AMapGeoPoint locationWithLatitude:39.890459 longitude:116.581476],
                       nil];
    AMapGeoPolygon *polygon = [AMapGeoPolygon polygonWithPoints:points];
    
    AMapPOIPolygonSearchRequest *request = [[AMapPOIPolygonSearchRequest alloc] init];
    
    request.polygon             = polygon;
    request.keywords            = @"Apple";
    request.requireExtension    = YES;
    
    [self.search AMapPOIPolygonSearch:request];
}

- (void)searchPoiWithType:(AMapPOISearchType)searchType
{
    /* 清除存在的annotation. */
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    switch (searchType)
    {
        case AMapPOISearchTypeID:
        {
            [self searchPoiByID];
            
            break;
        }
        case AMapPOISearchTypeKeywords:
        {
            [self searchPoiByKeyword:@"北京大学"];
            
            break;
        };
        case AMapPOISearchTypeAround:
        {
            [self searchPoiByCenterCoordinate];
            
            break;
        }
        case AMapPOISearchTypePolyline:
        {
            [self searchPoiByPolygon];
            
            break;
        }
    }
}

#pragma mark - Override

- (void)hookAction
{
    self.mapView.showsUserLocation = YES;
    
//    [self searchPoiWithType:self.poiSearchType];
}

#pragma mark - Handle Action

- (void)searchTypeAction:(UISegmentedControl *)segmentedControl
{
    self.poiSearchType = segmentedControl.selectedSegmentIndex;
    
    [self searchPoiWithType:self.poiSearchType];
}

#pragma mark - Initialization

- (void)initToolBar
{
    UIBarButtonItem *flexbleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                 target:self
                                                                                 action:nil];
    
    UISegmentedControl *searchTypeSegCtl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:
                                             @"POI的ID",
                                             @"关键字",
                                             @"周边",
                                             @"多边形",
                                             nil]];
    searchTypeSegCtl.selectedSegmentIndex  = self.poiSearchType;
    searchTypeSegCtl.segmentedControlStyle = UISegmentedControlStyleBar;
    [searchTypeSegCtl addTarget:self action:@selector(searchTypeAction:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:searchTypeSegCtl];
    
    self.toolbarItems = [NSArray arrayWithObjects:flexbleItem, item, flexbleItem, nil];
}

/* 初始化search. */
- (void)initSearch
{
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
}


#pragma mark - Life Cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        self.poiSearchType = AMapPOISearchTypeID;
        _firstGetLocation = YES;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initToolBar];
    
    _locationManager = [[CLLocationManager alloc] init];//创建位置管理器
    _locationManager.delegate = self;//设置代理
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;//指定需要的精度级别
    _locationManager.distanceFilter = 1.0f;//设置距离筛选器
    [_locationManager requestWhenInUseAuthorization];
    [_locationManager startUpdatingLocation];
    
    CGRect foo;
    
    // topView
    {
        foo.origin.x = foo.origin.y = 0;
        foo.size.width = self.view.frame.size.width;
        foo.size.height = 64;
        UIView *topView = [[UIView alloc] initWithFrame:foo];
        topView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:topView];
        
        foo = self.mapView.frame;
        foo.origin.y = CGRectGetMaxY(topView.frame);
        self.mapView.frame = foo;
        
        
        // subviews
        UIEdgeInsets inset = UIEdgeInsetsMake(25, 10, 5, 10);
        foo.origin.x = 10;
        foo.origin.y = 5 + 20;
        foo.size.width = topView.frame.size.width - inset.left - inset.right;
        foo.size.height = topView.frame.size.height - inset.top - inset.bottom;
        UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        searchBtn.frame = foo;
        searchBtn.layer.cornerRadius = 3;
        searchBtn.backgroundColor = [UIColor lightGrayColor];
        searchBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
        [searchBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [searchBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        [searchBtn setContentMode:UIViewContentModeLeft];
        [searchBtn addTarget:self action:@selector(clickSearchBtn) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:searchBtn];
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    self.navigationController.navigationBar.barStyle    = UIBarStyleBlack;
//    self.navigationController.navigationBar.translucent = NO;
//    
//    self.navigationController.toolbar.barStyle      = UIBarStyleBlack;
//    self.navigationController.toolbar.translucent   = YES;
//    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [self.navigationController setToolbarHidden:YES animated:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
}




#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self startTrackingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
//    CLLocation *currentLocation = [self.dataManager currentLocation];
//    
//    if (currentLocation != newLocation) {
        [self.dataManager setCurrentLocation:newLocation];
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOCATION_UPDATE object:currentLocation];
//    }
    if (_firstGetLocation) {
        _firstGetLocation = NO;
        [self.mapView setCenterCoordinate:self.dataManager.currentLocation.coordinate];
    }
}

- (void)locationManager: (CLLocationManager *)manager
       didFailWithError: (NSError *)error {
    NSLog(@"location manager did fail error: %ld , %@" , error.code , error.localizedDescription);
}




#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self searchPoiByKeyword:textField.text];
    
    return YES;
}




@end
