//
//  LFHeadMapDemoViewController.m
//  LFHeatMapDemo
//
//  Created by George Polak on 7/18/14.
//  Copyright (c) 2014 George Polak. All rights reserved.
//

#import "LFHeadMapDemoViewController.h"
#import <MapKit/MapKit.h>
#import "LFHeatMap.h"
#import "LFHeatMapView.h"

@interface LFHeadMapDemoViewController () <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UISlider *slider;

@property (nonatomic) UIImageView *imageView;
@property (nonatomic) NSMutableArray *locations;
@property (nonatomic) NSMutableArray *weights;

@property (strong, nonatomic) LFHeatMap *heatMap;

@end


@implementation LFHeadMapDemoViewController

static NSString *const kLatitude = @"latitude";
static NSString *const kLongitude = @"longitude";
static NSString *const kMagnitude = @"magnitude";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // get data
    NSString *dataFile = [[NSBundle mainBundle] pathForResource:@"quake" ofType:@"plist"];
    NSArray *quakeData = [[NSArray alloc] initWithContentsOfFile:dataFile];
    
    self.locations = [[NSMutableArray alloc] initWithCapacity:[quakeData count]];
    self.weights = [[NSMutableArray alloc] initWithCapacity:[quakeData count]];
    NSMutableDictionary *pointData = [NSMutableDictionary new];
    for (NSDictionary *reading in quakeData)
    {
        CLLocationDegrees latitude = [[reading objectForKey:kLatitude] doubleValue];
        CLLocationDegrees longitude = [[reading objectForKey:kLongitude] doubleValue];
        double magnitude = [[reading objectForKey:kMagnitude] doubleValue];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        [self.locations addObject:location];
        [self.weights addObject:[NSNumber numberWithInteger:(magnitude * 10)]];
        pointData[location] = @(magnitude * 10);
    }
    
    // set map region
    MKCoordinateSpan span = MKCoordinateSpanMake(10.0, 13.0);
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(39.0, -77.0);
    self.mapView.region = MKCoordinateRegionMake(center, span);
    
    // create overlay view for the heatmap image
    self.imageView = [[UIImageView alloc] initWithFrame:_mapView.frame];
    self.imageView.alpha = 0.5;
    self.imageView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:self.imageView];
    
    self.heatMap = [LFHeatMap new];
    self.heatMap.mapView = self.mapView;
    self.heatMap.pointData = pointData;
    [self.mapView addOverlay:self.heatMap];
    
    // show initial heat map
    [self sliderChanged:self.slider];
}

- (IBAction)sliderChanged:(UISlider *)slider
{
    float boost = slider.value;
    UIImage *heatmap = [LFHeatMap heatMapForMapView:self.mapView boost:boost locations:self.locations weights:self.weights];
    self.imageView.image = heatmap;
}

#pragma mark -
#pragma mark MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (!self.heatMap) {
        return;
    }
    
    self.heatMap.currentHeatMapImage = nil;
    [self.mapView removeOverlay:self.heatMap];
    [self.mapView addOverlay:self.heatMap];
    
    self.imageView.image = self.heatMap.currentHeatMapImage;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    LFHeatMapView *ret = [[LFHeatMapView alloc] initWithOverlay:overlay];
    return ret;
}

@end
