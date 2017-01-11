//
//  VenueTableViewCell.swift
//  Revur
//
//  Created by Harri Westman on 8/31/16.
//  Copyright © 2016 Gerhard Moe. All rights reserved.
//

import UIKit
import MapKit
import SVProgressHUD
import Firebase

class PostTableViewCell: UITableViewCell {
    @IBOutlet weak var imgUser: CacheImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgPost: CacheImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var lblPhotoName: UILabel!
    @IBOutlet weak var lblPlaceName: UILabel!
    
    var firebase: FIRDatabaseReference? = nil
    var firebasePost: FIRDatabaseReference? = nil
    var post: FPost!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func resetWithPost(post: FPost) {
        imgUser.image = UIImage(named: "icon_user_empty")
        if let image = UIImage.imageFrom(post.userId!, subfolder: "user") {
            imgUser.image = image
        }
        else if let userphoto = Manager.sharedInstance.imageForUser(post.userId!){
            imgPost.setImageWithURL(NSURL(string: userphoto)!, placeholder: UIImage(named: "icon_user_empty")!, completion: { (image, error) in
                if error == nil && image != nil{
                    image!.saveToFile(post.userId!, subfolder: "user")
                }
            })
            
            if self.firebase !=  nil {
                self.firebase?.removeAllObservers()
            }
            self.firebase = FIRDatabase.database().referenceWithPath(Constant.Firebase.User.PATH).child(post.userId!)
            createUserObservers()
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constant.Notification.USER_UPDATED, object: nil)
        if post.userId == FUser.currentId() {
            NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.USER_UPDATED, object: nil, queue: nil) { (notification) in
                if let image = UIImage.imageFrom(post.userId!, subfolder: "user") {
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.imgUser.image = image
                    })
                }
            }
        }
        
        imgUser.layer.cornerRadius = imgUser.bounds.width/2
        imgUser.layer.masksToBounds = true
        imgUser.layer.borderColor = Constant.UI.COLOR_PINK.CGColor
        imgUser.layer.borderWidth = 2
        
        self.post = post
        imgPost.image = nil
        
        if let un = post.userName {
            lblUserName.text = un
        }
        
        if let pn = post.name {
            lblPhotoName.text = "#" + pn
        }
        
        if let placeName = post.place {
            lblPlaceName.text = "@" + placeName
        }
        
        if firebasePost != nil {
            firebasePost?.removeAllObservers()
        }
        
        if post.image != nil {
            imgPost.image = post.image
        }
        else if let image = UIImage.imageFrom(post.objectId(), subfolder: "post") {
            imgPost.image = image
        }
        else if post.photoUrl != nil {
            imgPost.setImageWithURL(NSURL(string: post.photoUrl!)!, placeholder: UIImage(named:"no_image")!, completion: { (image, error) in
                if error == nil && image != nil{
                    image!.saveToFile(post.objectId(), subfolder: "post")
                }
            })
        }
        else {
            self.firebasePost = FIRDatabase.database().referenceWithPath(Constant.Firebase.Post.PATH).child(post.objectId())
            createPhotoObservers()
        }
        
        self.mapView.delegate = self
        self.mapView.removeAnnotations(self.mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: Double(self.post.latitude!), longitude: Double(self.post.longitude!))
        annotation.title = self.post.name
        annotation.subtitle = self.post.address
        self.mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(annotation.coordinate, span)
        self.mapView.setRegion(region, animated: false)

        self.mapView.selectAnnotation(annotation, animated: false)
    }
    
    func createUserObservers() {
        guard firebase != nil else {
            return
        }
        
        firebase?.observeEventType(.ChildChanged, withBlock: { (snapshot) in
            let user = FObject.objectWithPath(Constant.Firebase.User.PATH, Subpath: self.post.userId!, dictionary: snapshot.value as! Dictionary<NSObject, AnyObject>)
            if let pictureUrl = user[Constant.Firebase.User.PICTURE] {
                self.imgUser.setImageWithURL(NSURL(string: pictureUrl as! String)!, placeholder: self.imgUser.image!, completion: { (image, error) in
                    if error == nil && image != nil{
                        image?.saveToFile(user.objectId(), subfolder: "user")
                        print("image loaded success")
                    }
                })
            }
        })
    }
    
    func createPhotoObservers() {
        guard firebasePost != nil else {
            return
        }
        
        firebasePost?.observeEventType(.Value, withBlock: { (snapshot) in
            print(snapshot.value)
            let postPhoto = FObject.objectWithPath(Constant.Firebase.Post.PATH, Subpath: self.post.objectId(), dictionary: snapshot.value as! Dictionary<NSObject, AnyObject>)
            if let pictureUrl = postPhoto[Constant.Firebase.Post.PHOTO] as? String {
                self.imgPost.setImageWithURL(NSURL(string: pictureUrl)!, placeholder: UIImage(named: "no_image")!, completion: { (image, error) in
                    if error == nil && image != nil{
                        self.post.photoUrl = pictureUrl
                        image!.saveToFile(self.post.objectId(), subfolder: "post")
                        self.firebasePost?.removeAllObservers()
                    }
                })
            }
        })
    }
    
    @IBAction func onPreview(sender: AnyObject) {
        Manager.preview(self.imgPost.image!)
    }
    
    @IBAction func onGoThere(sender: AnyObject) {
        if self.post.latitude != nil && self.post.longitude != nil && self.post.name != nil {
            Manager.openAppleMapWithDirection(self.post.latitude!, lon: self.post.longitude!, name: self.post.name!)
        }
        else {
            SVProgressHUD.showErrorWithStatus("Location coordinate is not correct.")
        }
    }
}

extension PostTableViewCell: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orangeColor()
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 50, height: 50)
        
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
        button.backgroundColor = Constant.UI.COLOR_PINK
        button.setImage(UIImage(named: "icon_walking"), forState: .Normal)
        button.addTarget(self, action: #selector(PostTableViewCell.getDirections), forControlEvents: .TouchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
    func getDirections(){
        Manager.openAppleMapWithDirection(self.post.latitude!, lon: self.post.longitude!, name: self.post.address!)
    }
}