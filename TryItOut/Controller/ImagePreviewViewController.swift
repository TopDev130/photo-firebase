//
//  ImagePreviewViewController.swift
//  TryItOut
//
//  Created by Harri Westman on 10/10/16.
//
//

import UIKit

class ImagePreviewViewController: UIViewController {
    var imgPreview: UIImageView!
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        view.opaque = false
        
        imgPreview = UIImageView(frame: self.view.bounds)
        imgPreview.image = image
        imgPreview.backgroundColor = UIColor.clearColor()
        imgPreview.contentMode = .ScaleAspectFit
        imgPreview.translatesAutoresizingMaskIntoConstraints = false;
        imgPreview.userInteractionEnabled = true
        self.view.addSubview(imgPreview)
        
        let verticalSpace = NSLayoutConstraint(item: self.imgPreview, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0)
        let topSpace = NSLayoutConstraint(item: self.imgPreview, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: 0)
        let leadingSpace = NSLayoutConstraint(item: self.imgPreview, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0)
        let trailingSpace = NSLayoutConstraint(item: self.imgPreview, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0)
        NSLayoutConstraint.activateConstraints([verticalSpace, topSpace, leadingSpace, trailingSpace])
             
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ImagePreviewViewController.hidePreview))
        imgPreview.addGestureRecognizer(tapGesture)
    }
    
    func hidePreview() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
