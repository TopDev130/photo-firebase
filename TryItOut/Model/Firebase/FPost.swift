//
//  FPost.swift
//  TryItOut
//
//  Created by Harri Westman on 10/5/16.
//
//

import UIKit

class FPost: FObject {
    var image: UIImage?
    
    var name: String? {
        get{
            return self[Constant.Firebase.Post.NAME] as? String
        }
        set{
            self[Constant.Firebase.Post.NAME] = newValue
        }
    }
    
    var place: String? {
        get{
            return self[Constant.Firebase.Post.PLACE] as? String
        }
        set{
            self[Constant.Firebase.Post.PLACE] = newValue
        }
    }
    
    var address: String? {
        get{
            return self[Constant.Firebase.Post.ADDRESS] as? String
        }
        set{
            self[Constant.Firebase.Post.ADDRESS] = newValue
        }
    }
    
    var userId: String? {
        get{
            return self[Constant.Firebase.Post.USERID] as? String
        }
        set{
            self[Constant.Firebase.Post.USERID] = newValue
        }
    }
    
    var userName: String? {
        get{
            return self[Constant.Firebase.Post.USERNAME] as? String
        }
        set{
            self[Constant.Firebase.Post.USERNAME] = newValue
        }
    }
    
    var photoUrl: String? {
        get{
            return self[Constant.Firebase.Post.PHOTO] as? String
        }
        set{
            self[Constant.Firebase.Post.PHOTO] = newValue
        }
    }
    
    var latitude: CGFloat? {
        get{
            return self[Constant.Firebase.Post.LATITUDE] as? CGFloat
        }
        set{
            self[Constant.Firebase.Post.LATITUDE] = newValue
        }
    }
    
    var longitude: CGFloat? {
        get{
            return self[Constant.Firebase.Post.LONGITUDE] as? CGFloat
        }
        set{
            self[Constant.Firebase.Post.LONGITUDE] = newValue
        }
    }
}
