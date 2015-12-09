//
//  ServiceLayer.swift
//  WorkShop Demo
//
//  Created by Ehab Amer on 4/29/15.
//  Copyright (c) 2015 Bright-Creations. All rights reserved.
//

let domainURL = "http://api.navandgo.com"
let imagesURLPath = "/"
let serverURL = "http://api.navandgo.com/rest/web/"
let basicAuthString = ""


import Foundation


class ServiceLayer : NSObject {
		
	class func submitPosition(beaconID : String, delegate: AnyObject, callBack: Selector)
	{
		if userNickname == ""
		{
			return
		}
		let request = NSMutableURLRequest(URL: NSURL(string: serverURL+"/utility/get-utility-by-attribute.json")!)
		
		let bodyString = "beaconID=" + beaconID + "&username=" + userNickname
		
		request.HTTPMethod = "POST"
		
		request.HTTPBody = bodyString.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false)
		
		if basicAuthString != ""
		{
			request.setValue(basicAuthString, forHTTPHeaderField: "Authorization")
		}
		
		MyJSONParser.objectWithRequest(request, responseDelegate: delegate, responseSelector: callBack)
	}
    
}