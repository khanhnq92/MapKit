//
//  PathFind.m
//  MapKitCoreLocation
//
//  Created by Cuong Trinh on 10/1/15.
//  Copyright © 2015 Cuong Trinh. All rights reserved.
//

#import "PathFind.h"
#import "LocationAnnotation.h"
#import <MapKit/MapKit.h>
@import AddressBookUI;

@interface PathFind ()<MKMapViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) MKDirections *direction;
@property (nonatomic, strong) CLGeocoder *geoCoder;
@property (nonatomic, strong) UIImageView* foundIndicator;
@end

@implementation PathFind
{
    id<MKOverlay> _overlay;
    CLPlacemark * _foundPlace;
    CLLocation* _fromLocation;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.translucent = NO;
    
    self.address.clearButtonMode = UITextFieldViewModeAlways;

    self.address.delegate = self;
    self.mapView.delegate = self;
    
    self.foundIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red.png"]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.foundIndicator];
    
    _fromLocation = [[CLLocation alloc] initWithLatitude:21.01484 longitude:105.84660];
    [self updateRegion:10.0];
    
    MKPointAnnotation *fromPin = [MKPointAnnotation new];
    [fromPin setCoordinate:_fromLocation.coordinate];
    [fromPin setTitle:@"TechMaster"];
    
    [self.mapView addAnnotation:fromPin];
    
    self.geoCoder = [CLGeocoder new];
}

- (void) updateRegion: (float) scale {
    CGSize size = self.mapView.bounds.size;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_fromLocation.coordinate,
                                                                   size.height * scale, size.width * scale);
    [self.mapView setRegion:region animated:true];
    
}
- (void) updateFoundIndicator: (BOOL) found {
    if (found) {
        self.foundIndicator.image = [UIImage imageNamed:@"green.png"];
    } else {
        self.foundIndicator.image = [UIImage imageNamed:@"red.png"];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
        [self.geoCoder geocodeAddressString:textField.text completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                [self updateFoundIndicator:false];
            } else {
                _foundPlace = placemarks.firstObject;
                MKPointAnnotation *foundPin = [MKPointAnnotation new];
                [foundPin setCoordinate:_foundPlace.location.coordinate];
                [foundPin setTitle:_foundPlace.description];
                [self.mapView addAnnotation:foundPin];
                [self updateFoundIndicator:true];
                
                MKPlacemark* toPlace = [[MKPlacemark alloc] initWithPlacemark:_foundPlace];
                [self routePath:[[MKPlacemark alloc] initWithCoordinate:_fromLocation.coordinate
                                                      addressDictionary:NULL]
                     toLocation:toPlace];
                
            }
        }];
    };
    return YES;
}

#pragma mark - Route Path
-(void) routePath: (MKPlacemark *) fromPlace
       toLocation: (MKPlacemark *) toPlace {
    MKDirectionsRequest * request = [MKDirectionsRequest new];
 
    MKMapItem *fromMapItem = [[MKMapItem alloc] initWithPlacemark:fromPlace];
    [request setSource: fromMapItem];
   
    MKMapItem *toMapItem = [[MKMapItem alloc] initWithPlacemark:toPlace];
    [request setDestination:toMapItem];
    
    
    self.direction = [[MKDirections alloc] initWithRequest: request];
    
    [self.direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error %@", [error localizedDescription]);
        } else {
            [self mapSetRegion: fromPlace.coordinate
                           and: toPlace.coordinate];
            
            [self showRoute:response];
            
        }
    }];

    
}

-(void)mapSetRegion: (CLLocationCoordinate2D) fromPoint
                and: (CLLocationCoordinate2D) toPoint
{
    CLLocationCoordinate2D centerPoint =
    CLLocationCoordinate2DMake((fromPoint.latitude + toPoint.latitude)/2.0,
                               (fromPoint.longitude + toPoint.longitude)/2.0);
    
    double latitudeDelta = ABS(fromPoint.latitude - toPoint.latitude) * 1.5;
    double longtitudeDelta = ABS(fromPoint.longitude - toPoint.longitude) * 1.5;
    
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longtitudeDelta);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(centerPoint, span);
    
    [self.mapView setRegion:region animated:YES];
}

-(void)showRoute:(MKDirectionsResponse *)response
{
    
    LocationAnnotation * fromAnnotation =
    [[LocationAnnotation alloc] initWithCoordinate: _fromLocation.coordinate
                                          andTitle: @"From"
                                       andSubTitle: @"TechMaster"];
    
    LocationAnnotation * toAnnotation =
    [[LocationAnnotation alloc] initWithCoordinate: _foundPlace.location.coordinate
                                          andTitle: @"To"
                                       andSubTitle: ABCreateStringWithAddressDictionary
     (_foundPlace.addressDictionary, NO)];
    
    [self.mapView addAnnotation:fromAnnotation];
    [self.mapView addAnnotation:toAnnotation];
    
    
    for (MKRoute *route in response.routes)
    {
        /*
         MKPolyline * polyLine = route.polyline;
         
         for (int i = 0; i < polyLine.pointCount; i++) {
         MKMapPoint point = polyLine.points[i];
         NSLog(@"x= %f, y=%f", point.x, point.y);
         }*/
        //[self.mapView removeOverlay:_overlay];
        _overlay = route.polyline;
        [self.mapView addOverlay:_overlay
                           level:MKOverlayLevelAboveRoads];
        
        for (MKRouteStep *step in route.steps)
        {
            NSLog(@"%@", step.instructions);
        }
    }
}
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer =
    [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 5.0;
    return renderer;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString* identifier = @"FoundLocation";
    MKPinAnnotationView* pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                                   reuseIdentifier:identifier];
    pinView.pinColor = MKPinAnnotationColorGreen;
    return pinView;
}

@end
