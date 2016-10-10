//
//  POIDetailViewController.h
//  cargo
//
//  Created by kobewong on 10/10/2016.
//  Copyright © 2016 l99. All rights reserved.
//

#import "BaseMapViewController.h"


@interface POIDetailViewController : BaseMapViewController {
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
}


@property (nonatomic, strong) AMapSearchObject *poi;



@end
