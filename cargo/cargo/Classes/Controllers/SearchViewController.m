//
//  SearchViewController.m
//  cargo
//
//  Created by kobewong on 10/10/2016.
//  Copyright © 2016 l99. All rights reserved.
//

#import "SearchViewController.h"
#import "POIAnnotation.h"
#import "POIDetailViewController.h"
//#import "CommonUtility.h"

@implementation SearchViewController



#pragma mark - private

- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:NO];
}



#pragma mark - super

- (id)init {
    if (self = [super init]) {
        self.search = [[AMapSearchAPI alloc] init];
        self.search.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect foo;
    
    
    [self.mapView removeFromSuperview], self.mapView = nil, self.mapView.delegate = nil;
    
    foo = self.view.bounds;
    _tableView = [[UITableView alloc] initWithFrame:foo style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    // topView
    {
        foo.origin.x = foo.origin.y = 0;
        foo.size.width = self.view.frame.size.width;
        foo.size.height = 64;
        UIView *topView = [[UIView alloc] initWithFrame:foo];
        topView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:topView];
        
        foo = _tableView.frame;
        foo.origin.y = CGRectGetMaxY(topView.frame);
        _tableView.frame = foo;
        
        
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
        
        
        
        foo.origin.x = CGRectGetMaxX(backBtn.frame) + 10;
        foo.origin.y = inset.top;
        foo.size.width = topView.frame.size.width - foo.origin.x - inset.right;
        foo.size.height = topView.frame.size.height - inset.top - inset.bottom;
        UITextField *textfield = [[UITextField alloc] initWithFrame:foo];
        textfield.layer.cornerRadius = 3;
        textfield.backgroundColor = [UIColor lightGrayColor];
        textfield.delegate = self;
        textfield.placeholder = @"搜索";
        textfield.returnKeyType = UIReturnKeySearch;
        [topView addSubview:textfield];
        [textfield becomeFirstResponder];
    }
}
//
//- (void)hookAction {
//    _textf
//}



#pragma mark - AMapSearchDelegate

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    NSLog(@"error = %@", error);
}

/* 输入提示回调. */
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response
{
    _searchResults = [response.tips mutableCopy];
    
    [_tableView reloadData];
}

/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (response.pois.count == 0)
    {
        return;
    }
    
    _searchResults = [response.pois mutableCopy];
    [_tableView reloadData];
    
//    NSMutableArray *poiAnnotations = [NSMutableArray arrayWithCapacity:response.pois.count];
//    
//    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
//        
//        [poiAnnotations addObject:[[POIAnnotation alloc] initWithPOI:obj]];
//        
//    }];
//    
//    /* 将结果以annotation的形式加载到地图上. */
//    [self.mapView addAnnotations:poiAnnotations];
//    
//    /* 如果只有一个结果，设置其为中心点. */
//    if (poiAnnotations.count == 1)
//    {
//        [self.mapView setCenterCoordinate:[poiAnnotations[0] coordinate]];
//    }
//    /* 如果有多个结果, 设置地图使所有的annotation都可见. */
//    else
//    {
//        [self.mapView showAnnotations:poiAnnotations animated:NO];
//    }
}

#pragma mark - Utility

/* 根据关键字来搜索POI. */
- (void)searchPoiByKeyword:(NSString *)searchKey
{
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    
    request.keywords            = searchKey;
    request.city                = @"深圳";      // wong.todo - 根据当前所在的城市设定该值
//    request.types               = @"高等院校";
    request.requireExtension    = YES;
    
    /*  搜索SDK 3.2.0 中新增加的功能，只搜索本城市的POI。*/
//    request.cityLimit           = YES;
//    request.requireSubPOIs      = YES;
    
    [self.search AMapPOIKeywordsSearch:request];
}

/* 输入联想 */
- (void)searchTipsWithKey:(NSString *)key
{
    if (key.length == 0)
    {
        return;
    }
    
    AMapInputTipsSearchRequest *tips = [[AMapInputTipsSearchRequest alloc] init];
    tips.keywords = key;
    tips.city     = @"深圳";        // wong.todo - 根据当前所在的城市设定该值
//    tips.cityLimit = YES; 是否限制城市
    
    [self.search AMapInputTipsSearch:tips];
}



#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    id<MAAnnotation> annotation = view.annotation;
    
    if ([annotation isKindOfClass:[POIAnnotation class]])
    {
        POIAnnotation *poiAnnotation = (POIAnnotation*)annotation;
        
        POIDetailViewController *detail = [[POIDetailViewController alloc] init];
        detail.poi = poiAnnotation.poi;
        
        /* 进入POI详情页面. */
        [self.navigationController pushViewController:detail animated:YES];
    }
}

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



#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self searchPoiByKeyword:textField.text];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self searchTipsWithKey:string];
    
    return YES;
}




#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"SearchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    AMapPOI *poi = [_searchResults objectAtIndex:indexPath.row];
    cell.textLabel.text = poi.name;
    
    return cell;
}




#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    POIDetailViewController *vc = [[POIDetailViewController alloc] init];
    vc.poi = [_searchResults objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
