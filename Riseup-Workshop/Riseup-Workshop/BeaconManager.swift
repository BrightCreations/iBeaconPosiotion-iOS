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

typealias BeaconInfo = (minor: String, rssi:Int)
typealias BeaconCoords = (point:CGPoint, distance:Int, errorMult:CGFloat)

class BeaconManager: NSObject, CLLocationManagerDelegate{
    
    typealias BeaconInfo = (minor: String, distance:Int)
    var lastSignout = NSDate.distantPast() as NSDate
    
    var officeRegion : CLBeaconRegion?
    
    var locationManager = CLLocationManager()
    
    
    
    
    var lastBeaconMinor = 0
    
    var heading : Float = 0
    var headingDegrees : Float = 0
    
    var timesNotFound : Double = 0
    var isCheckingLocation = false
    
    var backgroundUpdateTask : UIBackgroundTaskIdentifier?
    
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
        
        var knownBeacons : [String : [String : Int]] = [String : [String : Int]]()
        
        if beacons.count > 0
        {
            timesNotFound = 0
            
            var orderedBeacons : [CLBeacon] = beacons
            orderedBeacons =  orderedBeacons.sort(){$0.accuracy > $1.accuracy}
            
            let beacon = orderedBeacons[0] as CLBeacon
            
            beacon.accuracy
            for foundBeacon in orderedBeacons
            {
                if foundBeacon.proximity.rawValue >= CLProximity.Near.rawValue
                {
                    if knownBeacons["\(foundBeacon.minor)"] == nil
                    {
                        knownBeacons["\(foundBeacon.minor)"] = [String:Int]()
                        
                        //						print("Added \(foundBeacon.minor) RSSI=\(foundBeacon.rssi) Accuracy=\(foundBeacon.accuracy) Prox:\(foundBeacon.proximity.rawValue)\n", terminator: "")
                    }
                    
                    knownBeacons["\(foundBeacon.minor)"]!["Distance"] = Int(100 * foundBeacon.accuracy)
                    
                }
            }
            
            var orderedBeaonsInfo : [BeaconInfo] = []
            
            for knownBeaconKey : String in knownBeacons.keys
            {
                let distance = knownBeacons[knownBeaconKey]!["Distance"]! as Int
                let tuple : BeaconInfo = (minor:knownBeaconKey, distance:distance)
                orderedBeaonsInfo.append(tuple)
            }
            
            if orderedBeaonsInfo.count > 0
            {
                orderedBeaonsInfo = orderedBeaonsInfo.sort{$0.1 < $1.1}
                
                print(orderedBeaonsInfo)
                
                //				let text = "RSSI: \(orderedBeaonsInfo[0].distance)\nMin:\(orderedBeaonsInfo[0].minor)"
                
                //				NSNotificationCenter.defaultCenter().postNotificationName("BeaconFound", object: nil, userInfo: ["value":text])
                
                let beaconName = orderedBeaonsInfo[0].minor
                let positionString = MapComponents.beaconsList[beaconName]!["RoomPosition"]!
                
                let locationPoints = positionString.componentsSeparatedByString(",")
                
                let x = Int(locationPoints[0])!
                let y = Int(locationPoints[1])!
                
                NSNotificationCenter.defaultCenter().postNotificationName(MonoPositionNotification, object: nil, userInfo: ["value":"\(x),\(y)"])
                print("\(x),\(y)\n")
                
                if orderedBeaonsInfo.count >= 3
                {
                    
                    var beaconsLocations : [BeaconCoords] = []
                    let beaconsCount = orderedBeaonsInfo.count
                    var points : [CGPoint] = []
                    var distances : [Int] = []
                    var totalDistances : Int = 0
                    var currentPoint = CGPoint()
                    

                    
                    for i in 0..<beaconsCount
                    {
                        let locationString = MapComponents.beaconsList[orderedBeaonsInfo[i].minor]!["Location"]!
                        let locationPoints = locationString.componentsSeparatedByString(",")
                        let x = Int(locationPoints[0])
                        let y = Int(locationPoints[1])
                        let distance = orderedBeaonsInfo[i].distance
                        let errorMultiplier : CGFloat = CGFloat((MapComponents.beaconsList[orderedBeaonsInfo[i].minor]!["ErrorMultiplier"]! as NSString).floatValue)
                        let tuple : BeaconCoords = (point:CGPoint(x: x!, y: y!), distance:distance, errorMult: errorMultiplier)
                        beaconsLocations.append(tuple)
                    }
                    
                    for i in 0..<beaconsCount {
                        
                        points.append(beaconsLocations[i].point)
                        distances.append(beaconsLocations[i].distance)
                        totalDistances += beaconsLocations[i].distance
                        
                    }
                    
                    for i in 0..<beaconsCount {
                        
                        let ratio = CGFloat(distances[i]) / CGFloat(totalDistances)
                        points[i].x = ratio *  points[i].x
                        points[i].y = ratio *  points[i].y
                        
                    }
                    
                    for i in 0..<beaconsCount {
                        currentPoint.x += points[i].x
                        currentPoint.y += points[i].y
                    }
                    if !currentPoint.x.isNaN && !currentPoint.y.isNaN
                    {
                        NSNotificationCenter.defaultCenter().postNotificationName(TriPositionNotification, object: nil, userInfo: ["value":"\(currentPoint.x),\(currentPoint.y)"])
                    }
                    print("\(currentPoint.x),\(currentPoint.y)\n")
                }
                
            }
        }
            else
            {
                //			let text = "No Beacons Found !!"
                
            }
        }
        
        func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
            
        }
        
        // MARK: -
        
}
