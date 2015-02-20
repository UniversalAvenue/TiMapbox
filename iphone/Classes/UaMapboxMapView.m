/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "UaMapboxAnnotationProxy.h"
#import "UaMapboxMapView.h"
#import "TiUtils.h"
#import "Mapbox.h"

@implementation UaMapboxMapView

#pragma mark Lifecycle

-(void)initializeState
{
    // This method is called right after allocating the view and
    // is useful for initializing anything specific to the view
    
    [self addMap];
    
    [super initializeState];
    
    NSLog(@"[VIEW LIFECYCLE EVENT] initializeState");
}

-(void)configurationSet
{
    // This method is called right after all view properties have
    // been initialized from the view proxy. If the view is dependent
    // upon any properties being initialized then this is the method
    // to implement the dependent functionality.
    
    [super configurationSet];
    
    NSLog(@"[VIEW LIFECYCLE EVENT] configurationSet");
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    NSLog(@"[VIEW LIFECYCLE EVENT] willMoveToSuperview");
}

#pragma mark private

-(void)addMap
{
    if(mapView==nil)
    {
        NSLog(@"[VIEW LIFECYCLE EVENT] addMap");
        
        NSString *mapPath = [TiUtils stringValue:[self.proxy valueForKey:@"map"]];
        id mapSource;
        
        //check if file exists, otherwise try to add remote map
        NSString *mapInResourcesFolder = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[mapPath stringByAppendingString:@".mbtiles"]];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:mapInResourcesFolder];
        NSLog(@"mapFile exists: %i", fileExists);
        
        if(fileExists)
        {
            mapSource = [[RMMBTilesSource alloc] initWithTileSetResource:mapPath ofType:@"mbtiles"];
            
        } else
        {
            mapSource = [[RMMapboxSource alloc] initWithMapID:mapPath];
            
        }
        
        /*create the mapView with CGRectMake upon initialization because we won't know frame size
         until frameSizeChanged is fired after loading view. If we wait until then, we can't add annotations.*/
        mapView = [[RMMapView alloc] initWithFrame:CGRectMake(0, 0, 1, 1) andTilesource:mapSource];
        mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:mapView];
        mapView.delegate = self;
    }
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    NSLog(@"[VIEW LIFECYCLE EVENT] frameSizeChanged");
    if (mapView!=nil)
    {
        [TiUtils setView:mapView positionRect:bounds];
    }
    else
    {
        [self addMap];
    }
}

#pragma mark Property Setters

-(void)setBackgroundColor_:(id)value
{
    [mapView setBackgroundColor:[[TiUtils colorValue:value] _color]];
}

-(void)setCenterLatLng_:(id)value
{
    [mapView setCenterCoordinate: CLLocationCoordinate2DMake([TiUtils floatValue:[value objectAtIndex:0]],[TiUtils floatValue:[value objectAtIndex:1]])];
}

-(void)setDebugTiles_:(id)value
{
    [mapView setDebugTiles:[TiUtils boolValue:value]];
}

-(void)setHideAttribution_:(id)value
{
    mapView.hideAttribution = [TiUtils boolValue:value];
}

-(void)setMinZoom_:(id)value
{
    [mapView setMinZoom:[TiUtils floatValue:value]];
}

-(void)setMaxZoom_:(id)value
{
    [mapView setMaxZoom:[TiUtils floatValue:value]];
}

-(void)setUserLocation_:(id)value
{
    mapView.showsUserLocation = [TiUtils boolValue:value];
}

-(void)setZoom_:(id)value
{
    [mapView setZoom:[TiUtils floatValue:value] animated:true];
}

-(void)setRegion_:(id)args
{
    ENSURE_DICT(args);
    NSDictionary *region = (NSDictionary *) args;
    
    NSLog(@"setRegion with args %@", args);
    
    CLLocationDegrees latitude = [(NSString *)[region valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude = [(NSString *)[region valueForKey:@"longitude"] doubleValue];
    CLLocationDegrees latitudeDelta = [(NSString *)[region valueForKey:@"longitudeDelta"] doubleValue];
    CLLocationDegrees longitudeDelta = [(NSString *)[region valueForKey:@"latitudeDelta"] doubleValue];

    RMSphericalTrapezium bounds;
    bounds.northEast.latitude = latitude + latitudeDelta / 2;
    bounds.northEast.longitude = longitude + longitudeDelta / 2;
    bounds.southWest.latitude = latitude - latitudeDelta / 2;
    bounds.southWest.longitude = longitude - longitudeDelta / 2;
    
    [mapView zoomWithLatitudeLongitudeBoundsSouthWest:bounds.southWest
                                            northEast:bounds.northEast
                                             animated:[TiUtils boolValue:@"animated"
                                                              properties:region
                                                                     def:YES]];
}

-(id)getRegion_
{
    RMSphericalTrapezium bounds = [mapView latitudeLongitudeBoundingBox];
    
    CLLocationDegrees latitude = mapView.centerCoordinate.latitude;
    CLLocationDegrees longitude = mapView.centerCoordinate.longitude;
    CLLocationDegrees latitudeDelta = fabs(bounds.northEast.latitude - bounds.southWest.latitude);
    CLLocationDegrees longitudeDelta = fabs(bounds.northEast.longitude - bounds.southWest.longitude);
    
    return @{
             @"longitude":      [NSNumber numberWithDouble:longitude],
             @"latitude":       [NSNumber numberWithDouble:latitude],
             @"longitudeDelta": [NSNumber numberWithDouble:longitudeDelta],
             @"latitudeDelta":  [NSNumber numberWithDouble:latitudeDelta],
             };
}

-(NSDictionary *)coordinateFromPoint:(CGPoint)point
{
    CLLocationCoordinate2D coordinate = [mapView pixelToCoordinate:point];
    return @{
             @"latitude": [NSNumber numberWithDouble:coordinate.latitude],
             @"longitude": [NSNumber numberWithDouble:coordinate.longitude]
             };
}

#pragma mark Annotations

-(UaMapboxAnnotationProxy *)annotationFromArg:(id)arg
{
    return [(UaMapboxMapView *)[self proxy] annotationFromArg:arg];
}

//add annotation via public api
-(void)addAnnotation:(id)args
{
    UaMapboxAnnotationProxy *annotationProxy = [self annotationFromArg:args];
    [mapView addAnnotation:[annotationProxy annotationForMapView:mapView]];
}

-(void)removeAnnotation:(id)proxy
{
    ENSURE_SINGLE_ARG(proxy, UaMapboxAnnotationProxy);
    [mapView removeAnnotation:[(UaMapboxAnnotationProxy *)proxy annotationForMapView:mapView]];
}

-(void)removeAllAnnotations
{
    [mapView removeAllAnnotations];
}


#pragma mark Events

- (void)longPressOnMap:(RMMapView *)map at:(CGPoint)point
{
    if ([self.proxy _hasListeners:@"longPress"]) {
        CLLocationCoordinate2D location = [mapView pixelToCoordinate:point];
        
        NSDictionary *event = @{
                                @"annotation": [NSNull null],
                                @"map": [self proxy],
                                @"latitude": [NSNumber numberWithDouble:[mapView pixelToCoordinate:point].latitude],
                                @"longitude": [NSNumber numberWithDouble:[mapView pixelToCoordinate:point].longitude],
                                };
        
        [self.proxy fireEvent:@"longPress" withObject:event];
    }
}

- (void)afterMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction
{
    if ([self.proxy _hasListeners:@"regionChange"]) {
        NSDictionary *event = [self getRegion_];
        [self.proxy fireEvent:@"regionChange" withObject:event];
    }
}

- (void)singleTapOnMap:(RMMapView *)_mapView at:(CGPoint)point
{
    // The event listeners for a view are actually attached to the view proxy.
    // You must reference 'self.proxy' to get the proxy for this view
    
    // It is a good idea to check if there are listeners for the event that
    // is about to fired. There could be zero or multiple listeners for the
    // specified event.
    if ([self.proxy _hasListeners:@"singleTap"]) {
        CLLocationCoordinate2D location = [mapView pixelToCoordinate:point];
        
        NSDictionary *event = @{
                                @"annotation": [NSNull null],
                                @"map": [self proxy],
                                @"latitude": [NSNumber numberWithDouble:[mapView pixelToCoordinate:point].latitude],
                                @"longitude": [NSNumber numberWithDouble:[mapView pixelToCoordinate:point].longitude],
                                };
        
        [self.proxy fireEvent:@"singleTap" withObject:event];
    }
}

-(void)tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    if ([self.proxy _hasListeners:@"tapOnAnnotation"]) {
        if ([annotation isKindOfClass:[UaMapboxAnnotation class]]) {
            UaMapboxAnnotationProxy *annotationProxy = [(UaMapboxAnnotation *)annotation proxy];
            
            NSDictionary *event = @{
                                    @"annotation": annotationProxy,
                                    @"map": [self proxy],
                                    @"latitude": [NSNumber numberWithDouble:annotation.coordinate.latitude],
                                    @"longitude": [NSNumber numberWithDouble:annotation.coordinate.longitude],
                                    };
            
            [self.proxy fireEvent:@"tapOnAnnotation" withObject:event];
        } else {
            NSLog(@"tapOnAnnotation: unknown annotation type");
        }
    }
}

- (RMMapLayer *)mapView:(RMMapView *)map layerForAnnotation:(RMAnnotation *)annotation
{
    // Check for user location annotation and other things we know nothing about
    if (![annotation isKindOfClass:[UaMapboxAnnotation class]]) {
        return nil;
    }
    return [[(UaMapboxAnnotation *)annotation proxy] marker];
}

@end
