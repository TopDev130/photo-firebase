//
//  AppConfiguration.swift
//  Prayer
//
//  Created by Harri Westman on 7/15/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

//Location 37.787359 -122.408227
//41.7922, 123.4328

import UIKit

extension NSError {
    func description(description: String, code: Int) -> NSError {
        let domain = NSBundle.mainBundle().bundleIdentifier
        let userInfo: [NSObject : AnyObject] = [NSLocalizedDescriptionKey: description]
        return NSError(domain: domain!, code: code, userInfo: userInfo)
    }
    
    func getDescription() -> String {
        return self.userInfo[NSLocalizedDescriptionKey as NSObject] as! String
    }
}

extension UIImage {
    func saveToFile (name: String, subfolder: String) {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        print(paths)
        let dirPath = paths + "/images/\(subfolder)"
        let imagePath = dirPath + "/\(name).jpg"
        let fileManager = NSFileManager.defaultManager()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            try! fileManager.createDirectoryAtPath(dirPath, withIntermediateDirectories: true, attributes: nil)
            UIImageJPEGRepresentation(self, 100)!.writeToFile(imagePath, atomically: true)
        }
    }
    
    func saveToFile (name: String, subfolder: String, completion: ((Bool)->Void)?) {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        print(paths)
        let dirPath = paths + "/images/\(subfolder)"
        let imagePath = dirPath + "/\(name).jpg"
        let fileManager = NSFileManager.defaultManager()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            try! fileManager.createDirectoryAtPath(dirPath, withIntermediateDirectories: true, attributes: nil)
            UIImageJPEGRepresentation(self, 100)!.writeToFile(imagePath, atomically: true)
            if completion != nil {
                completion!(true)
            }
        }
    }
    
    class func imageFrom(name: String, subfolder: String) -> UIImage? {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        let dirPath = paths + "/images/\(subfolder)"
        let imagePath = dirPath + "/\(name).jpg"
        let fileManager = NSFileManager.defaultManager()
        
        if fileManager.fileExistsAtPath(imagePath) {
            return UIImage(contentsOfFile: imagePath)
        }
        return nil
    }
    
    func resizeImage(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newWidth))
        self.drawInRect(CGRectMake(0, -(newHeight-newWidth)/2, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func squareImage() -> UIImage {
        let width = self.size.width
        let height = self.size.height
        
        if width < height {
            UIGraphicsBeginImageContext(CGSizeMake(width, width))
            self.drawInRect(CGRectMake(0, -(height-width)/2, width, height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        }
        else {
            UIGraphicsBeginImageContext(CGSizeMake(height, height))
            self.drawInRect(CGRectMake(-(width-height)/2, 0, width, height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        }
    }
}
