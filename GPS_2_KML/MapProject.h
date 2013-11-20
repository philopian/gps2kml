//
//  MapProject.h
//  GPS_2_KML
//
//  Created by philopian on 11/18/13.
//  Copyright (c) 2013 philopian. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;
@import CoreLocation;
#import "GDataXMLNode.h"
#import "XMLData.h"
#import "PointAnnotations.h"
#import <MessageUI/MessageUI.h>



@interface MapProject : UIViewController <MFMailComposeViewControllerDelegate>


- (IBAction)btnAddCurrentLocationToXmlFile:(id)sender;
- (IBAction)inAppEmail:(id)sender;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSString *projectName;
@property (nonatomic, strong) NSString *projectNameFilePath;
@property (nonatomic, strong) NSMutableArray *pointAnnotationList;
@property (nonatomic, strong) NSMutableArray *poiLat;
@property (nonatomic, strong) NSMutableArray *poiLng;

@property (nonatomic, strong) GDataXMLDocument *xmlDocument;

@property (weak, nonatomic) IBOutlet UIButton *addButtonProp;

@end
