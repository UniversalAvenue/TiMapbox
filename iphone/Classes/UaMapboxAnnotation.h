//
//  UaMapboxMarker.h
//  TiMapbox
//
//  Created by Jonatan Lundin on 2014-11-11.
//
//

#import "RMPointAnnotation.h"

@class UaMapboxAnnotationProxy;

@interface UaMapboxAnnotation : RMPointAnnotation {
}

@property (nonatomic, weak) UaMapboxAnnotationProxy* proxy;

@end
