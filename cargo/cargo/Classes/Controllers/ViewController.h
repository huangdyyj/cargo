//
//  ViewController.h
//  cargo
//
//  Created by kobewong on 10/10/2016.
//  Copyright © 2016 l99. All rights reserved.
//

#import "BaseMapViewController.h"

@interface ViewController : BaseMapViewController <CLLocationManagerDelegate> {
    CLLocationManager *_locationManager;
    BOOL _firstGetLocation;
}


@end

