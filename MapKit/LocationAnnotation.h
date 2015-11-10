//
//  LocationAnnotation.h
//  DemoMap7
//
//  Created by techmaster on 10/31/13.
//  Copyright (c) 2013 Techmaster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@interface LocationAnnotation : NSObject <MKAnnotation>
- (id) initWithCoordinate : (CLLocationCoordinate2D) coordinate
                  andTitle: (NSString*) title
               andSubTitle: (NSString*) subTitle;
@end
