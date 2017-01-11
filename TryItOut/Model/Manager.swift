//
//  Manager.swift
//  Prayer
//
//  Created by Harri Westman on 7/15/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import MapKit
import SVProgressHUD

class Manager: NSObject{
    static let sharedInstance = Manager()
    var locationManager: CLLocationManager!
    var location: CLLocation!
    var selectedTabbarIndex: Int = 0
    var address: String!
    
    var user: FIRUser? = nil
    var users = [FUser]()
    var posts = [FPost]()
    var myPosts = [FPost]()
    var postPageIndex: UInt = 1
    var userLoggedIn: Bool = false

    var postListFirebase: FIRDatabaseReference? = nil
    
    var isNotFirstLaunch: Bool{
        get {
            let standard = NSUserDefaults.standardUserDefaults()
            return standard.boolForKey("NOT_FIRST_LAUNCH")
        }
        set {
            let standard = NSUserDefaults.standardUserDefaults()
            standard.setBool(newValue, forKey: "NOT_FIRST_LAUNCH")
        }
    }
    
    private override init() {
        super.init()
    }
    
    func initConfiguration()
    {
        let appearance = UITabBar.appearance()
        appearance.tintColor = Constant.UI.COLOR_PINK
        
        SVProgressHUD.setDefaultStyle(.Light)
        SVProgressHUD.setDefaultMaskType(.Black)
        SVProgressHUD.setMinimumDismissTimeInterval(0.5)
        
        NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.SIGN_IN, object: nil, queue: nil) { (notification) in
            self.userSignedIn()
        }
        
        if FUser.currentUser() != nil {
            NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.SIGN_IN, object: nil)
        }
    }
    
    func userSignedIn() {
        userLoggedIn = true
        
        SVProgressHUD.show()
        if users.count == 0 {
            loadAllUsers { (error) in
                if error != nil {
                    return
                }
                else {
                    NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.USER_LOADED, object: self.users)
                }
            }
        }
        
        self.loadPosts()
        
        if self.address != nil {
            Manager.updateUserLocation(self.address!)
        }
        
        postListFirebase = FIRDatabase.database().referenceWithPath(Constant.Firebase.Post.PATH)
        self.createPostObserver()
    }
    
    func createPostObserver() {
        guard postListFirebase != nil else {
            return
        }
        
        postListFirebase?.queryLimitedToLast(1).observeEventType(.ChildAdded, withBlock: { (snapshot) in
            if snapshot.exists() {
                let post = FPost(path: Constant.Firebase.Post.PATH, Subpath: nil, dictionary: snapshot.value as! [NSObject : AnyObject])
                self.addPost(post)
            }
        })
    }
    
    class func updateUserLocation(address: String) {
        if FUser.currentUser() != nil {
            let user = FUser.currentUser()
            user![Constant.Firebase.User.ADDRESS] = address
            user!.saveInBackground({ (error) in
                if error != nil {
                    print("User address update failed")
                }
            })
        }
    }
    
    func initGeolocation() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.distanceFilter = kCLDistanceFilterNone;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            
            let status = CLLocationManager.authorizationStatus()
            if status == .NotDetermined {
                self.locationManager.requestWhenInUseAuthorization()
            } else if status == CLAuthorizationStatus.AuthorizedWhenInUse
                || status == CLAuthorizationStatus.AuthorizedAlways {
                self.locationManager.startUpdatingLocation()
            }
            else {
                showNoPermissionsAlert()
            }
        }
    }
    
    func showNoPermissionsAlert() {
        let viewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        
        let alertController = UIAlertController(title: "No permission",
                                                message: "In order to work, app needs your location", preferredStyle: .Alert)
        let openSettings = UIAlertAction(title: "Open settings", style: .Default, handler: {
            (action) -> Void in
            let URL = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(URL!)
        })
        alertController.addAction(openSettings)
        viewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func isNearIn(latitude: Double, longitude: Double, radiusInMeter: Double) -> Bool{
        guard self.location != nil else { return false }
        
        let distance = self.location.distanceFromLocation(CLLocation(latitude: latitude, longitude: longitude))
        if distance < radiusInMeter {
            return true
        }
        else {
            return false
        }
    }
}

extension Manager { //user
    func setUserPhoto (userId: String, imageLink: String){
        let user = self.userWithId(userId)
        if user != nil {
            user![Constant.Firebase.User.PICTURE] = imageLink
        }
    }
    
    func imageForUser(userId: String) -> String? {
        let user = userWithId(userId)
        if user != nil {
            return user?.picture()
        }
        return nil
    }
    
    func userWithId (userId: String) -> FUser?{
        if userId == FUser.currentId() {
            return FUser.currentUser()
        }
        
        for user: FUser in self.users {
            if user.objectId() == userId {
                return user
            }
        }
        
        return nil
    }
    
    func loadAllUsers(completion: ((NSError?)->Void)?){
        users.removeAll()
        
        let reference = FIRDatabase.database().referenceWithPath(Constant.Firebase.User.PATH)
        let query: FIRDatabaseQuery = reference.queryOrderedByChild(Constant.Firebase.User.NAME_LOWER)
        query.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            if snapshot.exists() {
                for dictionary in (snapshot.value as! Dictionary<NSObject, AnyObject>).values {
                    let object = FUser(path: Constant.Firebase.User.PATH, Subpath: nil, dictionary: dictionary as! [NSObject : AnyObject])
                    if object.objectId() != FUser.currentId() {
                        self.users.append(object)
                    }
                }
            }
            else {
                completion!(NSError(domain: "load user failed", code: 1, userInfo: nil))
                return
            }
            if completion != nil {
                completion!(nil)
            }
        }
    }
}

extension Manager { //Post
    func loadPosts() {
        SVProgressHUD.show()
        FPostHelper.loadPosts(postPageIndex) { (result) in
            SVProgressHUD.dismiss()
            self.posts.removeAll()
            self.posts.appendContentsOf(result)
            NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.POST_LOADED, object: nil)
        }
    }
    
    func addPost(post: FPost?) {
        if let newPost = post {
            self.posts.insert(newPost, atIndex: 0)
            self.myPosts.insert(newPost, atIndex: 0)
            NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.POST_LOADED, object: nil)
        }
    }
}

extension Manager: CLLocationManagerDelegate {

    class func openAppleMapWithDirection(lat: CGFloat, lon: CGFloat, name: String) {
//Google Map
        if (UIApplication.sharedApplication().canOpenURL(NSURL(string:"comgooglemaps://")!)) {
            UIApplication.sharedApplication().openURL(NSURL(string:
                "comgooglemaps://?saddr=&daddr=\(lat),\(lon)&directionsmode=driving")!)
            
        } else {
            if let location = sharedInstance.location {
                UIApplication.sharedApplication().openURL(NSURL(string:
                    "http://maps.google.com/maps?f=d&saddr=\(location.coordinate.latitude),\(location.coordinate.longitude)&daddr=\(lat),\(lon)&directionsmode=driving")!)
            }
        }
//Apple Map
//        let coordinate = CLLocationCoordinate2DMake(Double(lat), Double(lon))
//        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
//        mapItem.name = name
//        mapItem.openInMapsWithLaunchOptions([MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse || status == .AuthorizedAlways {
            self.locationManager.startUpdatingLocation()
        }
        else {
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newlocation = locations[0]
        
        if self.location == nil || self.location.distanceFromLocation(newlocation) > 500 {
            print("location updated" + "lat: \(newlocation.coordinate.latitude), long: \(newlocation.coordinate.longitude)")
            self.location = newlocation
            NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.LOCATION_UPDATED, object: nil)
        }
        self.locationManager.stopUpdatingLocation()
        
        let standard = NSUserDefaults.standardUserDefaults()
        standard.setDouble(self.location.coordinate.longitude, forKey: "user_latitude")
        standard.setDouble(self.location.coordinate.longitude, forKey: "user_longitude")
        standard.synchronize()
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { (placeMarks, error) in
            if error == nil {
                let placeMark = placeMarks![0]
                if let addressDict = placeMark.addressDictionary {
                    let mkPlacemark = MKPlacemark(coordinate: self.location.coordinate, addressDictionary: addressDict as? [String: AnyObject])
                    self.address = Manager.parseAddress(mkPlacemark)
                }
            }
        }
    }
    
    class func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location Error")
    }
}

extension Manager { //UI Preview
    class func preview (image: UIImage) {
        let imagePreview = ImagePreviewViewController()
        imagePreview.image = image
        imagePreview.modalPresentationStyle = .OverCurrentContext
        imagePreview.modalTransitionStyle = .CrossDissolve
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let rootViewController = delegate.window!.rootViewController
        rootViewController?.presentViewController(imagePreview, animated: true, completion: nil)
    }
}