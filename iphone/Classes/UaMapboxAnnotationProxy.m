/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "UaMapboxAnnotationProxy.h"
#import "UaMapboxMapView.h"
#import "TiUtils.h"

@implementation UaMapboxAnnotationProxy

@synthesize delegate;
@synthesize needsRefreshingWithSelection;
@synthesize placed;
@synthesize offset;

#define LEFT_BUTTON  1
#define RIGHT_BUTTON 2

#pragma mark Internal

-(void)_configure
{
    static int mapTags = 0;
    tag = mapTags++;
    needsRefreshingWithSelection = YES;
    offset = CGPointZero;
    [super _configure];
}

-(NSString*)apiName
{
    return @"Ti.Map.Annotation";
}

-(NSMutableDictionary*)langConversionTable
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:@"title",@"titleid",@"subtitle",@"subtitleid",nil];
}

-(void)refreshAfterDelay
{
    [self performSelector:@selector(refreshIfNeeded) withObject:nil afterDelay:0.1];
}

-(void)setNeedsRefreshingWithSelection: (BOOL)shouldReselect
{
    if (delegate == nil)
    {
        return; //Nobody to refresh!
    }
    @synchronized(self)
    {
        BOOL invokeMethod = !needsRefreshing;
        needsRefreshing = YES;
        needsRefreshingWithSelection |= shouldReselect;
        
        if (invokeMethod)
        {
            TiThreadPerformOnMainThread(^{[self refreshAfterDelay];}, NO);
        }
    }
}

-(void)refreshIfNeeded
{
    @synchronized(self)
    {
        if (!needsRefreshing)
        {
            return; //Already done.
        }
        if (delegate!=nil && [delegate viewAttached])
        {
            [(UaMapboxMapView*)[delegate view] refreshAnnotation:self readd:needsRefreshingWithSelection];
        }
        needsRefreshing = NO;
        needsRefreshingWithSelection = NO;
    }
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
    if (newValue != curValue) {
        [self setNeedsRefreshingWithSelection:YES];
    }
}

-(void)setLongitude:(id)longitude
{
    double curValue = [TiUtils doubleValue:[self valueForUndefinedKey:@"longitude"]];
    double newValue = [TiUtils doubleValue:longitude];
    [self replaceValue:longitude forKey:@"longitude" notification:NO];
    if (newValue != curValue) {
        [self setNeedsRefreshingWithSelection:YES];
    }
}

// Title and subtitle for use by selection UI.
- (NSString *)title
{
    return [self valueForUndefinedKey:@"title"];
}

-(void)setTitle:(id)title
{
    title = [TiUtils replaceString:[TiUtils stringValue:title]
                        characters:[NSCharacterSet newlineCharacterSet] withString:@" "];
    //The label will strip out these newlines anyways (Technically, replace them with spaces)
    
    id current = [self valueForUndefinedKey:@"title"];
    [self replaceValue:title forKey:@"title" notification:NO];
    if (![title isEqualToString:current])
    {
        [self setNeedsRefreshingWithSelection:NO];
    }
}

- (NSString *)subtitle
{
    return [self valueForUndefinedKey:@"subtitle"];
}

-(void)setSubtitle:(id)subtitle
{
    subtitle = [TiUtils replaceString:[TiUtils stringValue:subtitle]
                           characters:[NSCharacterSet newlineCharacterSet] withString:@" "];
    //The label will strip out these newlines anyways (Technically, replace them with spaces)
    
    id current = [self valueForUndefinedKey:@"subtitle"];
    [self replaceValue:subtitle forKey:@"subtitle" notification:NO];
    if (![subtitle isEqualToString:current])
    {
        [self setNeedsRefreshingWithSelection:NO];
    }
}

-(void)setImage:(id)image
{
    id current = [self valueForUndefinedKey:@"image"];
    [self replaceValue:image forKey:@"image" notification:NO];
    if ([current isEqual: image] == NO)
    {
        [self setNeedsRefreshingWithSelection:YES];
    }
}
@end