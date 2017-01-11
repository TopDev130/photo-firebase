//
//  NBTabBarController.swift
//  TryItOut
//
//  Created by Harri Westman on 9/30/16.
//
//

import UIKit
import CLImageEditor

class NBTabBarController: UITabBarController {
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
}

extension NBTabBarController { //UITabBarDelegate
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if let index = tabBar.items?.indexOf(item) {
            if index == 2 { //camera
                let actionSheet = UIAlertController(title: "Select Photo", message: "", preferredStyle: .ActionSheet)
                
                let actionTake = UIAlertAction(title: "Take a photo", style: .Default, handler: { (action) in
                    self.showCamera()
                })
                let actionSelect = UIAlertAction(title: "Choose from library", style: .Default, handler: { (action) in
                    self.showPhotoLibrary()
                })
                let actionCancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                
                actionSheet.view.tintColor = Constant.UI.COLOR_PINK
                actionSheet.addAction(actionTake)
                actionSheet.addAction(actionSelect)
                actionSheet.addAction(actionCancel)
                self.presentViewController(actionSheet, animated: true, completion: nil)
            }
            else {
                Manager.sharedInstance.selectedTabbarIndex = index
            }
        }
    }
    
    func showCamera() {
        self.imagePicker = UIImagePickerController()
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        
        imagePicker.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        imagePicker.navigationBar.shadowImage = UIImage()
        imagePicker.navigationBar.translucent = true
        imagePicker.navigationBar.tintColor = Constant.UI.COLOR_PINK
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func showPhotoLibrary() {
        self.imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        
        imagePicker.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        imagePicker.navigationBar.shadowImage = UIImage()
        imagePicker.navigationBar.translucent = true
        imagePicker.navigationBar.tintColor = Constant.UI.COLOR_PINK
        imagePicker.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : Constant.UI.COLOR_PINK
        ]
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
}

extension NBTabBarController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editor = CLImageEditor(image: image)
        editor.delegate = self
        
        picker.setViewControllers([editor], animated: true)
        //picker.pushViewController(editor, animated: true)
    }
}

extension NBTabBarController: CLImageEditorDelegate {
    func imageEditor(editor: CLImageEditor!, didFinishEdittingWithImage image: UIImage!) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let postViewController = storyboard.instantiateViewControllerWithIdentifier("sid_postphoto") as! PostPhotoViewController
        postViewController.image = image.squareImage().resizeImage(300)//image.resizeImage(min(image.size.width, image.size.height))
        editor.navigationController?.pushViewController(postViewController, animated: true)
    }
}
