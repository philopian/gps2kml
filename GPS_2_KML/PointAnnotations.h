//
//  PointAnnotations.h
//  GPS_2_KML
//
//  Created by philopian on 11/18/13.
//  Copyright (c) 2013 philopian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface PointAnnotations : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic,  copy) NSString *subtitle;


-(id)initWithCoordinate:(CLLocationCoordinate2D) pointCoordinate;

@end




