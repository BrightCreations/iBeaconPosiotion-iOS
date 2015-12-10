//
//  ServiceLayer.swift
//  WorkShop Demo
//
//  Created by Ehab Amer on 4/29/15.
//  Copyright (c) 2015 Bright-Creations. All rights reserved.
//

let domainURL = "http://riseup.brightcreations.com"
let imagesURLPath = "/"
let serverURL = "http://riseup.brightcreations.com/api/"
let basicAuthString = ""


import Foundation


class ServiceLayer : NSObject {
		
	class func submitPosition(beaconID : String, delegate: AnyObject, callBack: Selector)
	{
		if userNickname == ""
		{
			return
		}
		let request = NSMutableURLRequest(URL: NSURL(string: serverURL+"users/add")!)
		
		let bodyString = "beacon=B0" + beaconID + "&name=" + userNickname
		
		request.HTTPMethod = "POST"
		
		request.HTTPBody = bodyString.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false)
		
		if basicAuthString != ""
		{
			request.setValue(basicAuthString, forHTTPHeaderField: "Authorization")
		}
		
		MyJSONParser.objectWithRequest(request, responseDelegate: delegate, responseSelector: callBack)
	}
    
}