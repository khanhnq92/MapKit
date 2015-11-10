//
//  LocationAnnotation.m
//  DemoMap7
//
//  Created by techmaster on 10/31/13.
//  Copyright (c) 2013 Techmaster. All rights reserved.
//

#import "LocationAnnotation.h"
#import <CoreLocation/CoreLocation.h>
@interface LocationAnnotation()
{
    CLLocationCoordinate2D _coordinate;
    NSString* _title;
    NSString* _subTitle;
}
@end

@implementation LocationAnnotation

- (id) initWithCoordinate : (CLLocationCoordinate2D) coordinate
                  andTitle: (NSString*) title
               andSubTitle: (NSString*) subTitle
{
    if (self = [super init]) {
        _coordinate = coordinate;
        _title = title;
        _subTitle = subTitle;
    }
    
    return self;
    
}


-(CLLocationCoordinate2D) coordinate{
    return _coordinate;
}

- (NSString *) title
{
    return _title;
}
- (NSString *)subtitle
{
    return _subTitle;
}
@end
