//
//  BeaconManager.swift
//  BCAttendance
//
//  Created by Ehab Amer on 3/29/15.
//  Copyright (c) 2015 TurnDigital. All rights reserved.
//

import Foundation
import CoreLocation
import SystemConfiguration
import CoreBluetooth
import CoreData
import UIKit

typealias BeaconInfo = (roomPoint:CGPoint, minor: String, distance:Int, beaconPoint:CGPoint)

class BeaconManager: NSObject, CLLocationManagerDelegate{
    
	
    var lastSignout = NSDate.distantPast() as NSDate
    
    var officeRegion : CLBeaconRegion?
    
    var locationManager = CLLocationManager()
	
    
    var heading : Float = 0
    var headingDegrees : Float = 0
	
    
    func setup() {
        locationManager.delegate = self
        officeRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: MainBeaconsSet)!, identifier: "Bright-Creations HQ")
        
        locationManager.requestAlwaysAuthorization()
        
        startMonitoring()
        startRanging()
        locationManager.startUpdatingHeading()
        
        
    }
    
    func startMonitoring()
    {
        locationManager.startMonitoringForRegion(officeRegion!)
    }
    
    func startRanging()
    {
        locationManager.startRangingBeaconsInRegion(officeRegion!)
    }
    
    
    // MARK: - Beacon Delegate
    
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError)
    {
        print(error.description, terminator: "")
        
        
    }
    
    func locationManager(manager: CLLocationManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError)
    {
        print(error.description, terminator: "")
        
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion)
    {
        
    }
    
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion)
    {
        print("<-- Did EXIT Region -->\n", terminator: "")
        
    }
    
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion)
    {
        
        var knownBeacons : [BeaconInfo] = []
        
        if beacons.count > 0
        {
            
            var orderedBeacons : [CLBeacon] = beacons
            orderedBeacons =  orderedBeacons.sort(){$0.accuracy > $1.accuracy}

            for foundBeacon in orderedBeacons
            {
				
//                if foundBeacon.proximity.rawValue >= CLProximity.Near.rawValue
				if foundBeacon.proximity != CLProximity.Unknown
                {
					let beaconName = "\(foundBeacon.minor)"
					let roomPositionString = MapComponents.beaconsList[beaconName]!["RoomPosition"]!
					let beaconPositionString = MapComponents.beaconsList[beaconName]!["Location"]!
					
					let roomLocationPoints = roomPositionString.componentsSeparatedByString(",")
					
					let roomX = Int(roomLocationPoints[0])!
					let roomY = Int(roomLocationPoints[1])!
					
					let beaconLocationPoints = beaconPositionString.componentsSeparatedByString(",")
					
					let beaconX = Int(beaconLocationPoints[0])!
					let beaconY = Int(beaconLocationPoints[1])!
					
					let beaconInfo = (roomPoint:CGPoint(x: roomX, y: roomY), minor: beaconName, distance:Int(100 * foundBeacon.accuracy), beaconPoint:CGPoint(x: beaconX, y: beaconY))
					
					knownBeacons.append(beaconInfo)
                    
                }
            }
			
            
            if knownBeacons.count > 0
            {
                knownBeacons = knownBeacons.sort{$0.distance < $1.distance}
                
                let beaconName = knownBeacons[0].minor
                
                let x = knownBeacons[0].roomPoint.x
                let y = knownBeacons[0].roomPoint.y
                
				NSNotificationCenter.defaultCenter().postNotificationName(MonoPositionNotification, object: nil, userInfo: ["value":"\(x),\(y)", "beacon": beaconName])
				
				if knownBeacons.count >= 3
				{
					
					let totalDistances : Int = knownBeacons.reduce(0){ $0 + $1.distance }
					var currentPoint = CGPoint()
					
					var newPoints : [CGPoint] = []
					
					var ratioSum : CGFloat = 0
					
					for i in 0..<knownBeacons.count {
						
						var ratio = CGFloat(knownBeacons[i].distance) / CGFloat(totalDistances)
						ratio = 1 - ratio
						ratioSum += ratio
						let calculatedPoint = CGPoint(x: (ratio *  knownBeacons[i].beaconPoint.x), y: (ratio *  knownBeacons[i].beaconPoint.y))
						newPoints.append(calculatedPoint)
					}
					
					print(ratioSum)
					currentPoint.x = (newPoints.reduce(0){ $0 + $1.x}) / ratioSum
					currentPoint.y = (newPoints.reduce(0){ $0 + $1.y}) / ratioSum
					
					
					NSNotificationCenter.defaultCenter().postNotificationName(TriPositionNotification, object: nil, userInfo: ["value":"\(currentPoint.x),\(currentPoint.y)"])
					
					print("\(currentPoint.x),\(currentPoint.y)\n")
				}
			}
		}
		else
		{
			print("No Beacons Found !!")
			
		}
	}
	
	func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		
	}
	
}
