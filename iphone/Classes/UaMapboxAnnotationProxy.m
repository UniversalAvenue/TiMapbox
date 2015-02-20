/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "UaMapboxAnnotationProxy.h"
#import "TiUtils.h"

@implementation UaMapboxAnnotationProxy

@synthesize delegate;
@synthesize placed;
@synthesize offset;

#pragma mark Internal


-(NSString*)apiName
{
    return @"ua.mapbox.Annotation";
}

#pragma mark Public APIs

-(CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D result;
    result.latitude = [TiUtils doubleValue:[self valueForUndefinedKey:@"latitude"]];
    result.longitude = [TiUtils doubleValue:[self valueForUndefinedKey:@"longitude"]];
    return result;
}

-(void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self setValue:[NSNumber numberWithDouble:coordinate.latitude] forUndefinedKey:@"latitude"];
    [self setValue:[NSNumber numberWithDouble:coordinate.longitude] forUndefinedKey:@"longitude"];
}

-(void)setLatitude:(id)latitude
{
    double curValue = [TiUtils doubleValue:[self valueForUndefinedKey:@"latitude"]];
    double newValue = [TiUtils doubleValue:latitude];
    [self replaceValue:latitude forKey:@"latitude" notification:NO];
}

-(void)setLongitude:(id)longitude
{
    double curValue = [TiUtils doubleValue:[self valueForUndefinedKey:@"longitude"]];
    double newValue = [TiUtils doubleValue:longitude];
    [self replaceValue:longitude forKey:@"longitude" notification:NO];
}

-(void)setImage:(id)image
{
    id current = [self valueForUndefinedKey:@"image"];
    [self replaceValue:image forKey:@"image" notification:NO];

    if (marker) {
        [marker replaceUIImage:[TiUtils image:image proxy:self]];
    }
}

-(RMMarker *)marker
{
    if (marker == nil) {
        CGPoint anchorPoint;
        id image = [self valueForUndefinedKey:@"image"];
        id point = [self valueForUndefinedKey:@"anchorPoint"];
        
        NSLog(@"layer with image %@, ap %@", image, point);
        
        if (image != nil) {
            ENSURE_TYPE_OR_NIL(point, NSDictionary);
            
            if (point != nil) {
                anchorPoint = CGPointMake(
                                          [TiUtils floatValue:@"x" properties:point],
                                          [TiUtils floatValue:@"y" properties:point]
                                          );
            } else {
                anchorPoint = CGPointMake(0.5f, 0);
            }
            
            marker = [[UaMapboxMarker alloc] initWithUIImage:[TiUtils image:image proxy:self] anchorPoint:anchorPoint];
        } else {
            marker = [[UaMapboxMarker alloc] initWithMapboxMarkerImage:nil tintColor:nil];
        }
    }
    return marker;
}

-(UaMapboxAnnotation *)annotationForMapView:(RMMapView *)map
{
    if (!annotation) {
        annotation = [[UaMapboxAnnotation alloc] initWithMapView:map coordinate:[self coordinate] andTitle:nil];
        [annotation setProxy:self];
    }
    return annotation;
}

@end