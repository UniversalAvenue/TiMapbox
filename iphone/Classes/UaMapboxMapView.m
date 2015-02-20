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
    
    NSLog(@"args = %@", args);
    
    CLLocationDegrees latitude = [(NSString *)[region valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude = [(NSString *)[region valueForKey:@"longitude"] doubleValue];
    CLLocationDegrees latitudeDelta = [(NSString *)[region valueForKey:@"longitudeDelta"] doubleValue];
    CLLocationDegrees longitudeDelta = [(NSString *)[region valueForKey:@"latitudeDelta"] doubleValue];

    RMSphericalTrapezium bounds;
    bounds.northEast.latitude = latitude + latitudeDelta / 2;
    bounds.northEast.longitude = longitude + longitudeDelta / 2;
    bounds.southWest.latitude = latitude - latitudeDelta / 2;
    bounds.southWest.longitude = longitude - longitudeDelta / 2;
    
    NSLog(@"setRegion with bounds: northEast.latitude: %d, northEast.longitude: %d, southWest.latitude: %d, southWest.longitude: %d, from latitude: %d, longitude: %d, latitudeDelta: %d, longitudeDelta: %d",
          bounds.northEast.latitude, bounds.northEast.longitude, bounds.southWest.latitude, bounds.southWest.longitude,
          latitude, longitude, latitudeDelta, longitudeDelta);
    
    [mapView zoomWithLatitudeLongitudeBoundsSouthWest:bounds.southWest
                                            northEast:bounds.northEast
                                             animated:[TiUtils boolValue:@"animated"
                                                              properties:region
                                                                     def:YES]];
}

-(id)getRegion_
{
    RMSphericalTrapezium bounds = [mapView latitudeLongitudeBoundingBox];

    NSLog(@"getRegion with bounds: northEast.latitude: %d, northEast.longitude: %d, southWest.latitude: %d, southWest.longitude: %d", bounds.northEast.latitude, bounds.northEast.longitude, bounds.southWest.latitude, bounds.southWest.longitude)
    
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

- (void)mapViewRegionDidChange:(RMMapView *)map
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

//parts of addShape from https://github.com/benbahrenburg/benCoding.Map addPolygon method Apache License 2.0
-(void)addShape:(id)args
{
    ENSURE_TYPE(args,NSDictionary);
    ENSURE_UI_THREAD(addShape,args);
    
    id pointsValue = [args objectForKey:@"points"];
    
    //remove points from args since they are no longer needed
    //and we are passing args along to the annotation userInfo
    NSMutableDictionary *mutableArgs = [args mutableCopy];
    [mutableArgs removeObjectForKey:@"points"];
    
    if(pointsValue==nil)
    {
        NSLog(@"points value is missing, cannot add polygon");
        return;
    }
    NSArray *inputPoints = [NSArray arrayWithArray:pointsValue];
    //Get our counter
    NSUInteger pointsCount = [inputPoints count];
    
    //We need at least one point to do anything
    if(pointsCount==0){
        return;
    }
    
    //Create the number of points provided
    NSMutableArray *points = [[NSMutableArray alloc] init];
    
    //loop through and add coordinates
    for (int iLoop = 0; iLoop < pointsCount; iLoop++) {
        [points addObject:
         [[CLLocation alloc] initWithLatitude:[TiUtils floatValue:@"latitude" properties:[inputPoints objectAtIndex:iLoop] def:0]
                                    longitude:[TiUtils floatValue:@"longitude" properties:[inputPoints objectAtIndex:iLoop] def:0] ]];
    }
    
    RMAnnotation *annotation = [[RMAnnotation alloc]
                                initWithMapView:mapView
                                coordinate:((CLLocation *)[points objectAtIndex:0]).coordinate
                                andTitle:[TiUtils stringValue:@"title" properties:mutableArgs]];
    
    //Attach all data for use when creating the layer for the annotation
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              mutableArgs, @"args",
                              points, @"points",
                              @"Shape", @"type", nil];
    
    annotation.userInfo = userInfo;
    
    [mapView addAnnotation:annotation];
}


//This event that adds layer for any annotation created with RMAnnotation
- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    //check for user location annotation
    if (annotation.isUserLocationAnnotation)
        return nil;
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:annotation.userInfo];
    
    NSString *type = [userInfo objectForKey:@"type"];
    
    //Shape
    if([type isEqual: @"Shape"])
    {
        return [self shapeLayer:mapView userInfo:userInfo];
    }
    else if([type isEqual: @"Marker"])
    {
        return [self markerLayer:mapView userInfo:userInfo];
    }
}

- (RMMapLayer *)markerLayer:(RMMapView *)mapView userInfo:(NSDictionary *)userInfo
{
    RMMarker *marker = [[RMMarker alloc] initWithMapboxMarkerImage:nil tintColor:([TiUtils isIOS7OrGreater] ? mapView.tintColor : nil)];
    NSDictionary *args = [userInfo objectForKey:@"args"];
    
    marker.canShowCallout = YES;
    
    
    
    return marker;
}

- (RMMapLayer *)shapeLayer:(RMMapView *)mapView userInfo:(NSDictionary *)userInfo
{
    RMShape *shape = [[RMShape alloc] initWithView:mapView];
    NSDictionary *args = [userInfo objectForKey:@"args"];
    
    //FILL
    float fillOpacity = [TiUtils floatValue:@"fillOpacity" properties:args];
    UIColor *fillColor =  [[TiUtils colorValue:@"fillColor" properties:[userInfo objectForKey:@"args"]] _color];
    
    if (fillColor != nil)
    {
        if(fillOpacity)
        {
            fillColor = [fillColor colorWithAlphaComponent:fillOpacity];
        }
        shape.fillColor = fillColor;
    }
    
    //Line Properties
    float lineOpacity = [TiUtils floatValue:@"lineOpacity" properties:args];
    UIColor *lineColor =  [[TiUtils colorValue:@"lineColor" properties:[userInfo objectForKey:@"args"]] _color];
    if (lineColor != nil)
    {
        if(lineOpacity)
        {
            lineColor = [lineColor colorWithAlphaComponent:lineOpacity];
        }
        shape.lineColor = lineColor;
    }
    shape.lineWidth = [TiUtils floatValue:@"lineWidth" properties:args def: 1.0];
    
    shape.lineDashLengths = [args objectForKey:@"lineDashLengths" ];
    shape.lineDashPhase = [TiUtils floatValue:@"lineDashPhase" properties:args def: 0.0];
    shape.scaleLineDash = [TiUtils boolValue:@"scaleLineDash" properties:args def: NO];
    shape.lineJoin = [TiUtils stringValue:@"lineJoin" properties:args def:kCALineJoinMiter];
    
    //Add shape with coordinates
    for (CLLocation *location in (NSArray *)[userInfo objectForKey:@"points"])
        [shape addLineToCoordinate:location.coordinate];
    
    return shape;
}
@end
