//
//  PointAnnotations.m
//  GPS_2_KML
//
//  Created by philopian on 11/18/13.
//  Copyright (c) 2013 philopian. All rights reserved.
//

#import "PointAnnotations.h"

@implementation PointAnnotations

-(id)initWithCoordinate:(CLLocationCoordinate2D) pointCoordinate;
{
    if(self = [super init]) {
        _coordinate = pointCoordinate;
        
    }
    return self;
}

@end
