//
//  AppConstants.swift
//  Prayer
//
//  Created by Harri Westman on 7/18/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit

struct Constant{
    
    static func allFonts() {
        for family: String in UIFont.familyNames()
        {
            print("\(family)")
            for names: String in UIFont.fontNamesForFamilyName(family)
            {
                print("== \(names)")
            }
        }
    }
    
    struct UI {
        static func RGB(r r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
            return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1)
        }
        
        static let GLOBAL_TINT_COLOR = UIColor(red: 164.0/255.0, green: 152.0/255.0, blue: 226.0/255.0, alpha: 1)
        static let COLOR_PINK = UI.RGB(r: 238, g: 100, b: 134)
        static let COLOR_LIGHT = UI.RGB(r: 239, g: 83, b: 80)
    }
    
    struct StandardDefault {
        static let CURRENTUSER           = "CurrentUser"
    }
    
    struct Notification {
        static let SIGN_IN              = "NOTIFICATION_SIGN_IN"
        static let SIGN_OUT             = "NOTIFICATION_SIGN_OUT"
        
        static let USER_UPDATED         = "NOTIFICATION_USER_UPDATED"
        static let USER_LOADED          = "NOTIFICATION_USER_LOADED"
        static let LOCATION_UPDATED     = "NOTIFICATION_LOCATION_UPDATED"
        static let POST_LOADED          = "NOTIFICATION_POST_LOADED"
    }
    
    struct Firebase {
        
        static let authDomain           = "try-it-at-bb1f4.appspot.com"
        static let FIREBASE_STORAGE     = "gs://try-it-at-bb1f4.appspot.com"
        
        static let OBJECTID             = "objectId"			//	String
        static let CREATEDAT            = "createdAt"			//	String
        static let UPDATEDAT            = "updatedAt"			//	String
        
        struct LoginMethod {
            static let LOGIN_FACEBOOK   = "Facebook"
            static let LOGIN_EMAIL      = "Email"
        }
        
        struct User {
            static let PATH             = "User"				//	Path name
            static let EMAIL            = "email"				//	String
            static let NAME             = "name"				//	String
            static let NAME_LOWER       = "name_lower"			//	String
            static let LOGINMETHOD      = "loginMethod"			//	String
            static let STATUS           = "status"				//	String
            
            static let MOBILEPHONE      = "mobilePhone"				//	String
            static let ADDRESS          = "address"				//	String
            
            static let PICTURE          = "picture"				//	String
            static let THUMBNAIL        = "thumbnail"			//	String
        }
        
        struct Post {
            static let PATH             = "Post"				//	String
            static let NAME             = "Name"				//	String
            static let PLACE            = "Place"				//	String
            static let ADDRESS          = "Address"				//	String
            static let LATITUDE         = "Latitude"			//	Float
            static let LONGITUDE        = "Longitude"			//	Float
            static let PHOTO            = "Photo"				//	String
            static let USERID           = "UserID"				//	String
            static let USERNAME         = "UserName"            //	String
        }
    }
}

struct Global_Functions {

    static func sort(dictionary: [NSObject : AnyObject]) -> [AnyObject] {
        var array: [AnyObject] = Array(dictionary.values)
        array.sortInPlace({ (obj1, obj2) -> Bool in
            let dict1 = obj1 as! Dictionary<NSObject, AnyObject>
            let dict2 = obj2 as! Dictionary<NSObject, AnyObject>
            return Double(dict1[Constant.Firebase.CREATEDAT]! as! NSNumber) > Double(dict2[Constant.Firebase.CREATEDAT] as! NSNumber)
        })
        return array
    }
    
    static func sortReverse(dictionary: [NSObject : AnyObject]) -> [AnyObject] {
        var array: [AnyObject] = Array(dictionary.values)
        array.sortInPlace({ (obj1, obj2) -> Bool in
            let dict1 = obj1 as! Dictionary<NSObject, AnyObject>
            let dict2 = obj2 as! Dictionary<NSObject, AnyObject>
            return Double(dict1[Constant.Firebase.CREATEDAT]! as! NSNumber) < Double(dict2[Constant.Firebase.CREATEDAT] as! NSNumber)
        })
        return array
    }
    
    static func stringSinceDateFor(interval: NSTimeInterval) -> String?{
        let period: Int = Int(NSDate().timeIntervalSince1970 - interval)
        
        let min = period/60
        let hours = (min/60)%24
        let day = (min/1440)
        let month = day / 30
        let year = month / 12
        
        var ret: String
        if (hours == 0)
        {
            ret = "\(min) min(s)"
        }
        else
        {
            ret = "\(hours) hr(s)"
            if (day > 0)
            {
                ret = "\(day%30) day(s)" + ret
                if (month > 0)
                {
                    ret = "\(month) month(s)"
                    if (year > 0)
                    {
                        ret = "\(year) yr(s) \(month%12) mth(s)"
                    }
                }
            }
        }
        return ret
    }
}
