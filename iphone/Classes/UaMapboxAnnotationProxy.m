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
}

-(RMAnnotation *)annotationForMapView:(RMMapView *)mapView
{
    if (annotation == nil) {
        NSString *title = [TiUtils stringValue:[self valueForUndefinedKey:@"title"]];
        annotation = [[UaMapboxAnnotation alloc] initWithMapView:mapView coordinate:[self coordinate] andTitle:title];
        [annotation setProxy:self];
    }
    
    return annotation;
}
@end