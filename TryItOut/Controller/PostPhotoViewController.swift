//
//  CameraViewController.swift
//  TryItOut
//
//  Created by Harri Westman on 9/30/16.
//
//

import UIKit
import MapKit
import SVProgressHUD

class PostPhotoViewController: BaseViewController {
    var image: UIImage!
    var selectedPin: MKPlacemark!
    var location: CLLocation!
    
    @IBOutlet weak var txtItemName: UITextField!
    @IBOutlet weak var txtPlaceName: UITextField!
    @IBOutlet weak var imgItem: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var currentMapView: MKMapView!
    @IBOutlet weak var tblPlace: UITableView!
    
    var matchingItems = [MKMapItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = Constant.UI.GLOBAL_TINT_COLOR
        navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor()
        ]
        
        self.location = Manager.sharedInstance.location
        if self.location != nil {
            self.updateMapWithCurrentLocation(location.coordinate)
        }
        
        if self.image != nil {
            self.imgItem.image = image
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.LOCATION_UPDATED, object: nil, queue: nil) { (notification) in
            self.location = Manager.sharedInstance.location
            self.updateMapWithCurrentLocation(self.location.coordinate)
        }
    }
    
    @IBAction func onSave(sender: AnyObject) {
        guard txtItemName.text != "" else {
            SVProgressHUD.showErrorWithStatus("Please input the Item name")
            return
        }
        
        guard txtPlaceName.text != "" else {
            SVProgressHUD.showErrorWithStatus("Please input the Place name")
            return
        }
        
        var address = Manager.sharedInstance.address
        var selectedLocation = self.location
        if self.selectedPin != nil {
            address = Manager.parseAddress(self.selectedPin)
            selectedLocation = self.selectedPin.location
        }
        
        SVProgressHUD.show()
        FPostHelper.createPost(txtItemName.text!, place: txtPlaceName.text!, address: address, image: self.image, latitude: CGFloat(selectedLocation.coordinate.latitude), longitude: CGFloat(selectedLocation.coordinate.longitude)) { (error, post) in
            if error == nil {
                SVProgressHUD.showSuccessWithStatus("Save Success")
            }
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func onBack(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateMapWithCurrentLocation(location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        currentMapView.setRegion(region, animated: true)
    }
}

extension PostPhotoViewController: UISearchBarDelegate {
    func updateWithSearch(text: String) {
        self.tblPlace.hidden = false
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = text
        
        if self.location != nil {
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegion(center: self.location.coordinate, span: span)
            request.region = region
        }
        else {
            request.region = currentMapView.region
        }
        
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tblPlace.reloadData()
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = true
        updateWithSearch(searchText)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        tblPlace.hidden = true
        searchBar.showsCancelButton = false
    }
}

extension PostPhotoViewController: MKMapViewDelegate {
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
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), forState: .Normal)
        button.addTarget(self, action: #selector(PostPhotoViewController.getDirections), forControlEvents: .TouchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
    func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMapsWithLaunchOptions(launchOptions)
        }
    }
    
    func dropPinZoomIn(placemark: MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        currentMapView.removeAnnotations(currentMapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        currentMapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        currentMapView.setRegion(region, animated: true)
    }
}

extension PostPhotoViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VENUE_CELL")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = Manager.parseAddress(selectedItem)
        return cell
    }
}

extension PostPhotoViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        self.dropPinZoomIn(selectedItem)
        txtPlaceName.text = selectedItem.name
        tableView.hidden = true
        self.searchBar.resignFirstResponder()
        self.searchBar.showsCancelButton = false
    }
}

extension PostPhotoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
}
