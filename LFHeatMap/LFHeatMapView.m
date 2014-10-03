//
//  LFHeatMapView.m
//  LFHeatMapDemo
//
//  Created by Bryan Oltman on 10/3/14.
//  Copyright (c) 2014 George Polak. All rights reserved.
//

#import "LFHeatMapView.h"
#import "LFHeatMap.h"

@implementation LFHeatMapView

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)context
{
    LFHeatMap *heatMap = (LFHeatMap *)self.overlay;
    UIImage *source = [heatMap currentHeatMapImage];
    CGFloat xPerc = (mapRect.origin.x - heatMap.imageRect.origin.x) / (heatMap.imageRect.size.width);
    CGFloat yPerc = (mapRect.origin.y - heatMap.imageRect.origin.y) / (heatMap.imageRect.size.height);
    CGFloat widthScale = mapRect.size.width / heatMap.imageRect.size.width;
    CGFloat heightScale = mapRect.size.height / heatMap.imageRect.size.height;
    CGRect cropRect = CGRectMake(xPerc * source.size.width,
                                 yPerc * source.size.height,
                                 widthScale * source.size.width,
                                 heightScale * source.size.height);

    CGImageRef imageRef = CGImageCreateWithImageInRect([source CGImage], cropRect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    CGRect targetRect = [self rectForMapRect:mapRect];
    if (!CGSizeEqualToSize(cropped.size, cropRect.size)) {
        if (cropRect.origin.x < 0) {
            // We extended past the left side
            CGFloat xPerc = abs(cropRect.origin.x) / source.size.width;
            targetRect.origin.x += xPerc * targetRect.size.width;
            targetRect.size.width -= xPerc * targetRect.size.width;
        } else if (cropRect.size.width + cropRect.origin.x > source.size.width) {
            // We extended past the right side
            CGFloat xPerc = (cropRect.origin.x + cropRect.size.width - source.size.width) / source.size.width;
            targetRect.size.width -= xPerc * targetRect.size.width;
        }
        
        if (cropRect.origin.y < 0) {
            // We extended past the top
            CGFloat yPerc = abs(cropRect.origin.y) / source.size.height;
            targetRect.origin.y += yPerc * targetRect.size.height;
            targetRect.size.height -= yPerc * targetRect.size.height;
        } else if (cropRect.origin.y + cropRect.size.height > source.size.height) {
            // We extended past the bottom
            CGFloat yPerc = (cropRect.origin.y + cropRect.size.height - source.size.height) / source.size.height;
            targetRect.size.height -= yPerc * targetRect.size.height;
        }
    }
    
    UIGraphicsPushContext(context);
    [cropped drawInRect:targetRect];
    UIGraphicsPopContext();

}

@end
