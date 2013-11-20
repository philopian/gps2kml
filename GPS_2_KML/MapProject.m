//
//  MapProject.m
//  GPS_2_KML
//
//  Created by philopian on 11/18/13.
//  Copyright (c) 2013 philopian. All rights reserved.
//

#import "MapProject.h"

@interface MapProject () <CLLocationManagerDelegate,MKMapViewDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) float currentLat;
@property (nonatomic) float currentLng;
@property (nonatomic) BOOL userEnableGPSUse;
@property (nonatomic,strong) NSMutableArray *placemarkNodesMuArray;
@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation MapProject


#pragma mark - Map stuff

-(void)mapStuff
{
    // Set tracking mode to YES
    _mapView.userTrackingMode = YES;
    
    // Show user location
    _mapView.showsUserLocation = YES;
    
    // Map type
    _mapView.mapType = MKMapTypeStandard;
    
    
    // location
    CLLocationCoordinate2D currentLocation;
    currentLocation = _mapView.userLocation.location.coordinate;
    
    // span
    MKCoordinateSpan mapSpan;
    mapSpan.latitudeDelta = 10;  // ten degree n/s
    
    // mapRegion (location + span)
    MKCoordinateRegion mapRegion;
    mapRegion.center = currentLocation;
    mapRegion.span = mapSpan;
    [_mapView setRegion:mapRegion animated:YES];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView
           viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *view = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
    if (view == nil) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
    }
    // enable animation
    view.enabled = YES;
    view.canShowCallout = YES;
    
    // image button 24x24 px is the recommendation
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PalmTree.png"]];
//    view.leftCalloutAccessoryView = imageView;
//    view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return view;
}

#pragma mark - CoreLocation

-(void)locationManagerSetup
{
    _locationManager =[[CLLocationManager alloc]init];
    _locationManager.delegate =self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([CLLocationManager locationServicesEnabled]) {
        // start the location manager
        [self.locationManager startUpdatingLocation];
        self.userEnableGPSUse = YES;
        
        //switch thru possible
        
    } else {
        
        // gps is disabled send a message
        self.userEnableGPSUse = NO;
        NSLog(@"Location Service is Disabled");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No GPS"
                                                       message:@"Cannot get your address because there is no GPS"
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
    }
    
}



#pragma mark - File Paths

- (NSString *)filePathOnDevice:(NSString *)createProjectName
{
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [dirPaths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@.xml",createProjectName];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentDirectory,fileName];
    NSLog(@"filePath: %@",filePath);
    return filePath;
}




#pragma mark - email methods

-(void)emailKmlFileWithFileName:(NSString *)fileNamePath
{
    
    // email Title/Body messages
    NSString *emailSubjectText = @"Here's a Kml";
    NSString *emailBodyDefaultText = @"Made this file from my iPhone!";
    
    // Create the MailComposerVC
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc]init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailSubjectText];
    [mc setMessageBody:emailBodyDefaultText isHTML:NO];
    
    
    // file name
    NSData *fileData = [NSData dataWithContentsOfFile:fileNamePath];
    
    // MIME type (Multipurpose Internet Mail Extension)
    NSString *mimeType = @"application/kml+xml";
    
    // Attach the kml document
    NSString *fileNameWithoutPath = [fileNamePath lastPathComponent];
    [mc addAttachmentData:fileData mimeType:mimeType fileName:fileNameWithoutPath];
    
    [self presentViewController:mc animated:YES completion:NULL];
}
- (void) mailComposeController:(MFMailComposeViewController *)controller
           didFinishWithResult:(MFMailComposeResult)result
                         error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}






















#pragma mark - View Did Load

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.addButtonProp.layer.cornerRadius = 5;
    
    self.title = self.projectName;
    
    // Add map stuff
    [self mapStuff];
    
    // CoreLocation
    [self locationManagerSetup];
    
    
    // Append new data and save
    [self startPointXMLDoc];
    
    // get array of all the placemarks (parse the XML for placemarks)
    // NSArray *adfsdfsdf = [self listOfAllXmlFilesInUsersDirectory];
    
    
    [self listAllNodesInXmlDoc:_xmlDocument];
    
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}









#pragma mark - actions

- (IBAction)btnAddCurrentLocationToXmlFile:(id)sender
{
    //    _mapView.userLocation = coordinate
    NSLog(@"user location:%f",_mapView.userLocation.coordinate.latitude);
    
    float lat = _mapView.userLocation.coordinate.latitude;
    float lng = _mapView.userLocation.coordinate.longitude;
    
    // Add new data to document
    [self appendLatLngElementToDoc:_xmlDocument
                         appendLat:lat
                         appendLng:lng];
    
    
}

- (IBAction)inAppEmail:(id)sender
{
    
    // append the KML namespace and the ending KML tag
    NSString *contents= [NSString stringWithContentsOfFile:_projectNameFilePath encoding:NSUTF8StringEncoding error:nil];
    
    
    // add the KML namespace
    NSString *appendProjectName = [NSString stringWithFormat:@"<name>%@</name>",_projectName];
    NSString *xmlDeclarationTag = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
    NSString *appendKmlNameSpaceTags = [NSString
                                        stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><kml xmlns=\"http://www.opengis.net/kml/2.2\">%@",
                                        appendProjectName];
    NSString *contentsWithKmlNameSpace = [contents stringByReplacingOccurrencesOfString: xmlDeclarationTag
                                                                             withString:appendKmlNameSpaceTags];
    
    // add the </kml>
    contentsWithKmlNameSpace = [contentsWithKmlNameSpace stringByAppendingString:@"</kml>"];
    
    // file path for the kml file
    NSString *kmlFilePath = [[_projectNameFilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"kml"];
    
    // if the .kml exist delete it
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    
    if ([fileManager fileExistsAtPath:kmlFilePath]) {
        // delete the file
        [fileManager removeItemAtPath:kmlFilePath error:nil];
    }
    
    // cleanup the spaces between tags
    NSString *removeSpacesBetweenTags = [contentsWithKmlNameSpace stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *finalContentsWithKmlNameSpace = [[removeSpacesBetweenTags componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]
                                               componentsJoinedByString:@""];
    
    // create the .kml from the .xml file
    [finalContentsWithKmlNameSpace writeToFile:kmlFilePath atomically:YES encoding: NSUnicodeStringEncoding error:nil];
    
    
    
    // in-app email the .kml file
    [self emailKmlFileWithFileName:kmlFilePath];
    
}




#pragma mark - XML Doc Methods

-(void)startPointXMLDoc
{
    //    NSString *path = [[NSBundle mainBundle] pathForResource:_projectName ofType:@"xml"];
    NSString *path = _projectNameFilePath;
    
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:path];
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData error:&error];
    [self setXmlDocument:doc];
}



-(void)appendLatLngElementToDoc:(GDataXMLDocument *)doc
                      appendLat:(double)latitude
                      appendLng:(double)longitude
{
    
    // Data To Append
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy HH:mm"];
    NSDate *now = [[NSDate alloc] init];
    NSString *dateString = [format stringFromDate:now];
    NSString *coordinateElement = [NSString stringWithFormat:@"%f,%f,0",longitude, latitude];
    
    
    
    // XML document
    NSData *xmlData = [[NSData alloc]initWithContentsOfFile:_projectNameFilePath];
    doc = [[GDataXMLDocument alloc]initWithData:xmlData error:nil];
    
    // Placemark Node
    GDataXMLElement *placemarkElement = [GDataXMLNode elementWithName:@"Placemark"];
    
    // tags to go inside <Placemark>
    GDataXMLElement *nameElement = [GDataXMLNode elementWithName:@"name" stringValue:dateString];
    GDataXMLElement *descriptionElement = [GDataXMLNode elementWithName:@"description" stringValue:@"collected with iPhone"];
    GDataXMLElement *pointElement = [GDataXMLNode elementWithName:@"Point" stringValue:@""];
    GDataXMLElement *coordinatesElement = [GDataXMLNode elementWithName:@"coordinates" stringValue:coordinateElement];
    
    //Adding child element
    [placemarkElement addChild:nameElement];
    [placemarkElement addChild:descriptionElement];
    [pointElement addChild:coordinatesElement]; // add the coordinate tag to the point tag before you add the point to placemark
    [placemarkElement addChild:pointElement];
    
    // add to root element
    [doc.rootElement addChild:placemarkElement];
    
    //you supply in the details of the new xml data that you want to write to the NSData variable
    xmlData = doc.XMLData;
    
    //finally write the data to the file in the doc directory
    [xmlData writeToFile:_projectNameFilePath atomically:YES];
    
    NSLog(@"FilePath: %@",_projectNameFilePath);
    
    
    // add point to annotationArray (title,subtitle,coordinate)
    PointAnnotations *poi;
    CLLocationCoordinate2D coordinateLatLng;
    coordinateLatLng.latitude = latitude;
    coordinateLatLng.longitude = longitude;
    poi = [[PointAnnotations alloc]initWithCoordinate:coordinateLatLng];
    poi.title = dateString;
    poi.subtitle = @"collected with iPhone";
    
    [self.pointAnnotationList addObject:poi];
    [self.mapView addAnnotations:_pointAnnotationList];
}

-(void)listAllNodesInXmlDoc:(GDataXMLDocument *)doc
{
    // get parent node (aka each Placemark Element)
    NSArray *placemarkArray = [doc nodesForXPath:@"//Document/Placemark" error:nil];

    
    // annotation stuff
    PointAnnotations *poi;
    CLLocationCoordinate2D coordinateLatLng;
    NSMutableArray *annotationArray = [[NSMutableArray alloc]init];

    for (GDataXMLElement *element in placemarkArray) {
        NSArray *placemarkElementName = [element elementsForName:@"name"];  //get child "name"
        NSArray *placemarkElementPoint = [element elementsForName:@"Point"];    // get child "Point"
        
        if (placemarkElementName >0) {
            
            // get coordinates (child of "Point" element)
            GDataXMLElement *getCoor = (GDataXMLElement *) [placemarkElementPoint objectAtIndex:0];
            NSString *rawCoordinates = [[getCoor childAtIndex:0] stringValue];
            NSArray *splitString = [rawCoordinates componentsSeparatedByString:@","];
            coordinateLatLng.latitude = [splitString[1] doubleValue];
            coordinateLatLng.longitude = [splitString[0] doubleValue];
            poi = [[PointAnnotations alloc]initWithCoordinate:coordinateLatLng];
            NSLog(@"%@",rawCoordinates);
            
            // get the Title/Subtitle
            GDataXMLElement *nameElement = (GDataXMLElement *) [placemarkElementName objectAtIndex:0];
            poi.title = [nameElement stringValue];
            poi.subtitle = @"collected with iPhone";
            NSLog(@"%@",[nameElement stringValue]);
            
            // add annotation to annotationList
            [annotationArray addObject:poi];
        }
    }
    
    // show annotations on map
    self.pointAnnotationList = annotationArray;
    [self.mapView addAnnotations:_pointAnnotationList];
    
    // show all the point within bounds
//    [self.mapView showAnnotations:_pointAnnotationList animated:YES];

}




- (void)savedXMLPath:(NSString*)currentProjectName
              xmlDoc:(GDataXMLElement *)xmlDoc
{
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [dirPaths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@.xml",currentProjectName];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentDirectory,fileName];
    NSLog(@"filePath: %@",filePath);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        GDataXMLDocument *document = [[GDataXMLDocument alloc]
                                      initWithRootElement:xmlDoc];
        NSData *xmlData = document.XMLData;
        
        [xmlData writeToFile:filePath atomically:YES];
        //        [self saveXML:doc.rootElement];
        
    }
}






#pragma mark - XML methods
-(void)kmlWriter
{
    
    
}

-(void)saveKML:(GDataXMLElement*)rootElement
{
    
    
}

-(void)kmlAppendNewPoint
{
    
}

















@end
