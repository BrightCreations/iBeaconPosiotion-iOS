//
//  RWTItem.h
//  ForgetMeNot
//
//  Created by Chris Wagner on 1/29/14.
//  Copyright (c) 2014 Ray Wenderlich Tutorial Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface BCBeacon : NSObject <NSCoding>

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) NSUUID *uuid;
@property (assign, nonatomic, readonly) CLBeaconMajorValue major;
@property (assign, nonatomic, readonly) CLBeaconMinorValue minor;

- (instancetype)initWithName:(NSString *)name
                        uuid:(NSUUID *)uuid
                       major:(CLBeaconMajorValue)major
                       minor:(CLBeaconMinorValue)minor;
+ (CGPoint)getCoordinateWithBeaconA:(CGPoint)a beaconB:(CGPoint)b beaconC:(CGPoint)c distanceA:(CGFloat)dA distanceB:(CGFloat)dB distanceC:(CGFloat)dC;
+ (int)getCoordinateWithBeaconA:(CGPoint)a beaconB:(CGPoint)b distanceA:(CGFloat)dA distanceB:(CGFloat)dB resultPointA:(out CGPoint*)resultA resultPointB:(out CGPoint*)resultB;
+ (NSArray *)getPositionsWithBeaconA:(CGPoint)a beaconB:(CGPoint)b distanceA:(CGFloat)dA distanceB:(CGFloat)dB;
+(float)distanceBetweenPointA:(CGPoint)a pointB:(CGPoint)b;

@end
