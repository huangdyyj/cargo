//
//  SearchViewController.h
//  cargo
//
//  Created by kobewong on 10/10/2016.
//  Copyright © 2016 l99. All rights reserved.
//

#import "BaseMapViewController.h"

@interface SearchViewController : BaseMapViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
    UITableView *_tableView;
    NSMutableArray *_searchResults;
}

@end
