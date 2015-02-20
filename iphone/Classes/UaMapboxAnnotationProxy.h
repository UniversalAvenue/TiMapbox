/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import "UaMapboxMapView.h"
#import "UaMapboxAnnotation.h"

@interface UaMapboxAnnotationProxy : TiProxy {
@private
    UaMapboxMapView *__weak delegate;
    UaMapboxAnnotation *annotation;
    BOOL placed;
    CGPoint offset;
}

// Center latitude and longitude of the annotion view.
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readwrite, weak) UaMapboxMapView *delegate;
@property (nonatomic, readonly)	BOOL needsRefreshingWithSelection;
@property (nonatomic, readwrite, assign) BOOL placed;
@property (nonatomic, readonly) CGPoint offset;

-(RMAnnotation *)annotationForMapView:(RMMapView *)mapView;

@end