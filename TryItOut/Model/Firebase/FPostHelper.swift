//
//  FObject.swift
//  Poster
//
//  Created by Harri Westman on 7/21/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import Firebase
import SVProgressHUD

class FPostHelper {
    static let sharedInstance = FPostHelper()
    
    var postsInPage: UInt = 100
    var posts: [FPost]?
    
    private init() {
        posts = [FPost]()
    }
        
    class func imageNameWithDate() -> String{
        let interval = NSDate().timeIntervalSince1970;
        let userId = FUser.currentId()
        return userId + "/post/\(interval).jpg"
    }
    
    class func uploadImage(picture: UIImage?, completion: ((error: NSError?, imageUrl: String?)->Void)?) {
        let storage = FIRStorage.storage()
        let reference = storage.referenceForURL(Constant.Firebase.FIREBASE_STORAGE).child(imageNameWithDate())
        
        if (picture != nil)
        {
            let picData = UIImageJPEGRepresentation(picture!, 0.6)
            reference.putData(picData!, metadata: nil) { (metadata, error) in
                if error == nil {
                    let link = metadata?.downloadURL()!.absoluteString
                    if let block = completion {
                        block(error: nil, imageUrl: link)
                    }
                }
            }
        }
        if let block = completion {
            block(error: NSError(domain: "Upload Image Error", code: -1, userInfo: nil), imageUrl: nil)
        }
    }
    
    class func createPost(name: String, place: String, address: String, image: UIImage, latitude: CGFloat, longitude: CGFloat, completion: ((error: NSError?, post: FPost?)->Void)?) {
        let post = FPost(path: Constant.Firebase.Post.PATH, Subpath: nil)
        post.name = name
        post.place = place
        post.address = address
        post.userId = FUser.currentId()
        post.userName = FUser.currentUser()!.name()
        post.latitude = latitude
        post.longitude = longitude
        post.image = image
        
        post.saveInBackground { (error: NSError?) in
            if error == nil
            {
                completion!(error: error, post: post)
                uploadImage(image, completion: { (error, imageUrl) in
                    if error == nil, let realImage = imageUrl {
                        post.photoUrl = realImage
                        post.saveInBackground()
                    }
                })
            }
            else {
                completion!(error: nil, post: nil)
            }
        }
    }
    
    class func loadMyPost(completion: (([FPost])->Void)?){
        let reference = FIRDatabase.database().referenceWithPath(Constant.Firebase.Post.PATH)
        let userId = FUser.currentId()
        let query: FIRDatabaseQuery = reference.queryOrderedByChild(Constant.Firebase.Post.USERID).queryEqualToValue(userId)
        query.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            var objects = [FPost]()
            if snapshot.exists() {
                let sorted = sort(snapshot.value as! Dictionary<NSObject, AnyObject>)
                for dictionary in sorted {
                    let object = FPost(path: Constant.Firebase.Post.PATH, Subpath: nil, dictionary: dictionary as! [NSObject : AnyObject])
                    objects.append(object)
                }
            }

            if completion != nil {
                completion!(objects)
            }
        }
    }
    
    class func loadPosts(pageIndex: UInt, completion: (([FPost])->Void)?){
        let reference = FIRDatabase.database().referenceWithPath(Constant.Firebase.Post.PATH)
        let query = reference.queryOrderedByChild(Constant.Firebase.CREATEDAT).queryLimitedToLast(sharedInstance.postsInPage * pageIndex)
        query.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            var objects = [FPost]()
            if snapshot.exists() {
                let sorted = sort(snapshot.value as! Dictionary<NSObject, AnyObject>)
                for dictionary in sorted {
                    let object = FPost(path: Constant.Firebase.Post.PATH, Subpath: nil, dictionary: dictionary as! [NSObject : AnyObject])
                    objects.append(object)
                }
            }
            if completion != nil {
                print("Load Posts...")
                completion!(objects)
            }
        }
    }
    
    class func sort(dictionary: [NSObject : AnyObject]) -> [AnyObject] {
        var array: [AnyObject] = Array(dictionary.values)
        array.sortInPlace({ (obj1, obj2) -> Bool in
            let dict1 = obj1 as! Dictionary<NSObject, AnyObject>
            let dict2 = obj2 as! Dictionary<NSObject, AnyObject>
            return Int(dict1[Constant.Firebase.CREATEDAT] as! NSNumber) > Int(dict2[Constant.Firebase.CREATEDAT] as! NSNumber)
        })
        return array
    }
}
