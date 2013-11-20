//
//  XmlProjectsTVC.h
//  GPS_2_KML
//
//  Created by philopian on 11/18/13.
//  Copyright (c) 2013 philopian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapProject.h"

@interface XmlProjectsTVC : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (nonatomic, strong)NSMutableArray *listXmlProjectsInDocumentsDir;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)btnAddNewProject:(id)sender;

@end
