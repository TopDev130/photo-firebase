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

class MyPostTableViewCell: UITableViewCell {
    @IBOutlet weak var imgPost: CacheImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var lblPhotoName: UILabel!
    @IBOutlet weak var lblPlaceName: UILabel!
    
    var post: FPost!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func resetWithPost(post: FPost) {
        self.post = post
        imgPost.image = nil
        
        if let pn = post.name {
            lblPhotoName.text = pn
        }
        
        if let placeName = post.place {
            lblPlaceName.text = placeName
        }
        
        if post.image != nil {
            imgPost.image = post.image
        }
        else if let image = UIImage.imageFrom(post.objectId(), subfolder: "post") {
            imgPost.image = image
        }
        else if post.photoUrl != nil {
            imgPost.setImageWithURL(NSURL(string: post.photoUrl!)!, placeholder: UIImage(named: "logo_small")!, completion: { (image, error) in
                if error == nil && image != nil{
                    image!.saveToFile(post.objectId(), subfolder: "post")
                }
            })
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
    
    @IBAction func onGoThere(sender: AnyObject) {
        if self.post.latitude != nil && self.post.longitude != nil && self.post.name != nil {
            Manager.openAppleMapWithDirection(self.post.latitude!, lon: self.post.longitude!, name: self.post.name!)
        }
        else {
            SVProgressHUD.showErrorWithStatus("Location coordinate is not correct.")
        }
    }
}

extension MyPostTableViewCell: MKMapViewDelegate {
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