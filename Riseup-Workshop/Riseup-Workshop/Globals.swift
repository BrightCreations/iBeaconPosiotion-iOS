//
//  Globals.swift
//  Riseup-Workshop
//
//  Created by Ehab Amer on 12/6/15.
//  Copyright © 2015 EhabAmer. All rights reserved.
//

import Foundation
import SystemConfiguration

let MainBeaconsSet : String = "942ACCCE-3278-5FEE-25F7-A74AD8929DE3"
let TriPositionNotification = "TriPositionCalculated"
let MonoPositionNotification = "MonoPositionCalculated"

//TODO: Please set userNickname with a value to appear on screen
let userNickname = ""

var beaconManager = BeaconManager()

struct MapComponents {
	
	static var planInfo : [String : AnyObject] = [String : AnyObject]()
	static var beaconsList : [String : [String : String]] = [String : [String : String]]()
	static var mapNorth : Int = 0
	static var pixelToCM_Ratio : Float = 1
	
}