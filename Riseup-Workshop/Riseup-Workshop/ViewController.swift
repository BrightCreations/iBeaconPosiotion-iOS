//
//  ViewController.swift
//  Riseup-Workshop
//
//  Created by Ehab Amer on 12/6/15.
//  Copyright © 2015 EhabAmer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet var pinImage : UIImageView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		beaconManager.setup()
		// Do any additional setup after loading the view, typically from a nib.
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "positionCalculatedNotification:", name: MonoPositionNotification, object: nil)
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func positionCalculatedNotification(notification : NSNotification)
	{
		
		
		let userInfo = notification.userInfo!
		
		if let beaconName = userInfo["beacon"] as? String
		{
			let beaconNumber = beaconName.stringByReplacingOccurrencesOfString("1000", withString: "")
			ServiceLayer.submitPosition(beaconNumber, delegate: self, callBack: "positionSent:")
		}
		
		let pointString = userInfo["value"]!
		let subPoints = pointString.componentsSeparatedByString(",")
		var point = CGPoint(x: Double(subPoints[0])!, y: Double(subPoints[1])!)
		
		point.x /= 100.0
		point.x *= view.frame.width
		
		point.y /= 100.0
		point.y *= view.frame.height
		
		pinImage.center = point
	}
	
	func positionSent(response : [String : AnyObject]?)
	{
//		print(response)
	}
	
	
	deinit
	{
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

}

