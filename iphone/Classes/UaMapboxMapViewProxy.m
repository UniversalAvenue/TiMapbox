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

-(UaMapboxAnnotationProxy *)annotationFromArg:(id)arg
{
    if ([arg isKindOfClass:[UaMapboxAnnotationProxy class]])
    {
        [(UaMapboxAnnotationProxy *)arg setDelegate:(UaMapboxMapView *)[self view]];
        [arg setPlaced:NO];
        return arg;
    }
    
    ENSURE_TYPE(arg, NSDictionary);
    UaMapboxAnnotationProxy *proxy = [[UaMapboxAnnotationProxy alloc] _initWithPageContext:[self pageContext] args:[NSArray arrayWithObject:arg]];
    
    [proxy setDelegate:(UaMapboxMapView *)[self view]];
    return proxy;
}


-(void)addAnnotation:(id)arg
{
    ENSURE_SINGLE_ARG(arg, NSDictionary);
    TiThreadPerformOnMainThread(^{
        [(UaMapboxMapView *)[self view] addAnnotation:arg];
    }, NO);
}

-(void)addAnnotations:(id)args
{
    ENSURE_SINGLE_ARG(args, NSArray);
    TiThreadPerformOnMainThread(^{
        for (NSObject *annotation in (NSArray *)args) {
            [(UaMapboxMapView *)[self view] addAnnotation:annotation];
        }
    }, NO);
}

-(void)addShape:(id)arg
{
    ENSURE_SINGLE_ARG(arg, NSDictionary);
    TiThreadPerformOnMainThread(^{
        [(UaMapboxMapView *)[self view] addShape:arg];
    }, NO);
}

-(void)removeAnnotation:(id)arg
{
    ENSURE_SINGLE_ARG(arg, NSDictionary);
    TiThreadPerformOnMainThread(^{
        [(UaMapboxMapView *)[self view] removeAnnotation:arg];
    }, NO);
}

-(void)removeAnnotations:(id)args
{
    ENSURE_SINGLE_ARG(args, NSArray);
    TiThreadPerformOnMainThread(^{
        for (NSObject *annotation in (NSArray *)args) {
            [(UaMapboxMapView *)[self view] removeAnnotation:annotation];
        }
    }, NO);
}

-(void)removeAllAnnotations:(id)unused
{
    TiThreadPerformOnMainThread(^{
        [(UaMapboxMapView *)[self view] removeAllAnnotations];
    }, NO);
}
@end
