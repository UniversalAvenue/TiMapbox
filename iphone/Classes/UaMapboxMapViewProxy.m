/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "UaMapboxMapViewProxy.h"
#import "UaMapboxMapView.h"
#import "TiUtils.h"

@implementation UaMapboxMapViewProxy


-(void)addAnnotation:(id)arg
{
    ENSURE_SINGLE_ARG(arg, NSDictionary);
    TiThreadPerformOnMainThread(^{[(UaMapboxMapView *)[self view] addAnnotation:arg];}, NO);
}

-(void)addShape:(id)arg
{
    ENSURE_SINGLE_ARG(arg, NSDictionary);
    TiThreadPerformOnMainThread(^{[(UaMapboxMapView *)[self view] addShape:arg];}, NO);
}

-(void)clearTileCache:(id)unused
{
    TiThreadPerformOnMainThread(^{[(UaMapboxMapView *)[self view] clearOfflineCache:unused];}, NO);
}

-(void)removeAnnotation:(id)arg
{
    TiThreadPerformOnMainThread(^{[(UaMapboxMapView *)[self view] removeAnnotation:arg];}, NO);
}

-(void)removeAllAnnotations:(id)unused
{
    TiThreadPerformOnMainThread(^{[(UaMapboxMapView *)[self view] removeAllAnnotations:unused];}, NO);
}
@end
