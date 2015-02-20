//
//  UaMapboxMarker.h
//  TiMapbox
//
//  Created by Jonatan Lundin on 2014-11-11.
//
//

#import "RMAnnotation.h"

@class UaMapboxAnnotationProxy;

@interface UaMapboxAnnotation : RMAnnotation {
}

@property (nonatomic, weak) UaMapboxAnnotationProxy* proxy;

@end
