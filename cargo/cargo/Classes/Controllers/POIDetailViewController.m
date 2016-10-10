//
//  POIDetailViewController.m
//  cargo
//
//  Created by kobewong on 10/10/2016.
//  Copyright © 2016 l99. All rights reserved.
//

#import "POIDetailViewController.h"
#import "RoutePlanningViewController.h"
#import "AMapTipAnnotation.h"
#import "POIAnnotation.h"
#import "BusStopAnnotation.h"



@implementation POIDetailViewController



#pragma mark - private

- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickGoBtn {
    RoutePlanningViewController *vc = [[RoutePlanningViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}




#pragma mark - super

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
        
        foo.origin.x = inset.left;
        foo.origin.y = inset.top;
        foo.size.width = 50;
        foo.size.height = topView.frame.size.height - inset.top - inset.bottom;
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = foo;
        [backBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [backBtn setTitle:@"<" forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(clickBackBtn) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:backBtn];
    }
    
    // bottomView
    {
        foo.size.width = self.view.frame.size.width;
        foo.size.height = 70;
        foo.origin.x = 0;
        foo.origin.y = self.view.frame.size.height - foo.size.height;
        UIView *bottomView = [[UIView alloc] initWithFrame:foo];
        bottomView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:bottomView];
        
        foo.origin.x = 15;
        foo.origin.y = 10;
        foo.size.width = bottomView.frame.size.width - foo.origin.x - 100;
        foo.size.height = 15;
        _titleLabel = [[UILabel alloc] initWithFrame:foo];
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _titleLabel.textColor = [UIColor blackColor];
        [bottomView addSubview:_titleLabel];
        
        foo.origin.y += foo.size.height + 10;
        _subtitleLabel = [[UILabel alloc] initWithFrame:foo];
        _subtitleLabel.font = [UIFont boldSystemFontOfSize:13];
        _subtitleLabel.textColor = [UIColor darkGrayColor];
        [bottomView addSubview:_subtitleLabel];
        
        foo.size.width = foo.size.height = 60;
        foo.origin.x = bottomView.frame.size.width - foo.size.width - 20;
        foo.origin.y = (bottomView.frame.size.height - foo.size.height) / 2.f;
        UIButton *goBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        goBtn.frame = foo;
        goBtn.layer.cornerRadius = 30;
        goBtn.backgroundColor = [UIColor blueColor];
        [goBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [goBtn setTitle:@"到这去" forState:UIControlStateNormal];
        [goBtn addTarget:self action:@selector(clickGoBtn) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:goBtn];
    }
    
    id <MAAnnotation> annotation = nil;
    if ([self.poi isKindOfClass:[AMapPOI class]]) {
        AMapPOI *poi = (AMapPOI *)self.poi;
        annotation = [[POIAnnotation alloc] initWithPOI:poi];
        
        _titleLabel.text = poi.name;
        _subtitleLabel.text = poi.address;
    }
    else if ([self.poi isKindOfClass:[AMapTip class]]) {
        AMapTip *mapTip = (AMapTip *)self.poi;
        annotation = [[AMapTipAnnotation alloc] initWithMapTip:mapTip];
        
        _titleLabel.text = mapTip.name;
        _subtitleLabel.text = mapTip.address;
    }
    
    [self.mapView addAnnotation:annotation];
    [self.mapView setCenterCoordinate:annotation.coordinate];
    [self.mapView selectAnnotation:annotation animated:YES];
}



#pragma mark - MAMapViewDelegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[AMapTipAnnotation class]])
    {
        static NSString *tipIdentifier = @"tipIdentifier";
        
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:tipIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:tipIdentifier];
        }
        
        poiAnnotationView.canShowCallout = YES;
        poiAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return poiAnnotationView;
    }
    else if ([annotation isKindOfClass:[BusStopAnnotation class]])
    {
        static NSString *busStopIdentifier = @"busStopIdentifier";
        
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:busStopIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                                reuseIdentifier:busStopIdentifier];
        }
        
        poiAnnotationView.canShowCallout = YES;
        poiAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return poiAnnotationView;
    }
    else if ([annotation isKindOfClass:[POIAnnotation class]])
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

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        
        polylineRenderer.lineWidth   = 4.f;
        polylineRenderer.strokeColor = [UIColor magentaColor];
        
        return polylineRenderer;
    }
    
    return nil;
}


@end
