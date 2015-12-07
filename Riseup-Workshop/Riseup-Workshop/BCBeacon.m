//
//  RWTItem.m
//  ForgetMeNot
//
//  Created by Chris Wagner on 1/29/14.
//  Copyright (c) 2014 Ray Wenderlich Tutorial Team. All rights reserved.
//

#import "BCBeacon.h"


static NSString * const kRWTItemNameKey = @"name";
static NSString * const kRWTItemUUIDKey = @"uuid";
static NSString * const kRWTItemMajorValueKey = @"major";
static NSString * const kRWTItemMinorValueKey = @"minor";

@implementation BCBeacon

- (instancetype)initWithName:(NSString *)name
                        uuid:(NSUUID *)uuid
                       major:(uint16_t)major
                       minor:(uint16_t)minor
{
    self = [super init];
    if (!self) {
        return nil;
    }

    _name = name;
    _uuid = uuid;
    _major = major;
    _minor = minor;

    return self;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _name = [aDecoder decodeObjectForKey:kRWTItemNameKey];
    _uuid = [aDecoder decodeObjectForKey:kRWTItemUUIDKey];
    _major = [[aDecoder decodeObjectForKey:kRWTItemMajorValueKey] unsignedIntegerValue];
    _minor = [[aDecoder decodeObjectForKey:kRWTItemMinorValueKey] unsignedIntegerValue];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:kRWTItemNameKey];
    [aCoder encodeObject:self.uuid forKey:kRWTItemUUIDKey];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.major] forKey:kRWTItemMajorValueKey];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.minor] forKey:kRWTItemMinorValueKey];
}

+ (CGPoint)getCoordinateWithBeaconA:(CGPoint)a beaconB:(CGPoint)b beaconC:(CGPoint)c distanceA:(CGFloat)dA distanceB:(CGFloat)dB distanceC:(CGFloat)dC {
	CGFloat W, Z, x, y, y2;
	W = dA*dA - dB*dB - a.x*a.x - a.y*a.y + b.x*b.x + b.y*b.y;
	Z = dB*dB - dC*dC - b.x*b.x - b.y*b.y + c.x*c.x + c.y*c.y;
	
	x = (W*(c.y-b.y) - Z*(b.y-a.y)) / (2 * ((b.x-a.x)*(c.y-b.y) - (c.x-b.x)*(b.y-a.y)));
	y = (W - 2*x*(b.x-a.x)) / (2*(b.y-a.y));
	//y2 is a second measure of y to mitigate errors
	y2 = (Z - 2*x*(c.x-b.x)) / (2*(c.y-b.y));
	
	y = (y + y2) / 2;
	return CGPointMake(x, y);
}

+ (int)getCoordinateWithBeaconA:(CGPoint)a beaconB:(CGPoint)b distanceA:(CGFloat)dA distanceB:(CGFloat)dB resultPointA:(out CGPoint*)resultA resultPointB:(out CGPoint*)resultB{
	
	double dist = [self distanceBetweenPointA:a pointB:b];
	
	if (dist > dA + dB)
	{
		*resultA = CGPointMake((a.x+b.x)/2, (a.y+b.y)/2);
		return 1;
	}else if (dist < ABS(dA - dB))
	{
		*resultA = CGPointMake((a.x+b.x)/2, (a.y+b.y)/2);
		return 1;
	}else if ((dist == 0) && (dA == dB)){
		return 0;
	}else{
		double i = (dA*dA - dB*dB + dist*dist) / (2*dist);
		double h = sqrt(dA*dA - i*i);
		
		double cx = a.x + i * (b.x - a.x) / dist;
		double cy= a.y + i * (b.y - a.y) / dist;
		
		*resultA = CGPointMake(
							   cx + h * (b.y-a.y) / dist,
							   cy - h * (b.x-a.x) / dist
		);
		
		*resultB = CGPointMake(
							   cx - h * (b.y-a.y) / dist,
							   cy + h * (b.x-a.x) / dist
							   );
		
		if (dist == dA+dB)
			return 1;
		return 2;
		
	}
	
}

+ (NSArray *)getPositionsWithBeaconA:(CGPoint)a beaconB:(CGPoint)b distanceA:(CGFloat)dA distanceB:(CGFloat)dB
{
	CGPoint result1;
	CGPoint result2;
	
	int results = [self getCoordinateWithBeaconA:a beaconB:b distanceA:dA distanceB:dB resultPointA:&result1 resultPointB:&result2];
	
	
	if (results == 1)
	{
		return @[[NSValue valueWithCGPoint:result1]];
	}else if (results == 2)
	{
		return @[[NSValue valueWithCGPoint:result1],[NSValue valueWithCGPoint:result2]];
	}
	
	return @[];
	
}

+(float)distanceBetweenPointA:(CGPoint)a pointB:(CGPoint)b
{
	float dx = a.x - b.x;
	float dy = a.y - b.y;
	double dist = sqrt((dx*dx + dy*dy));
	
	return dist;
}

@end
