//
//  SettingsViewController.swift
//  TryItOut
//
//  Created by Harri Westman on 10/5/16.
//
//

import UIKit
import SVProgressHUD
import Firebase
import MessageUI

class SettingsViewController: UIViewController {
    @IBOutlet weak var imgPhoto: CacheImageView!
    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var txtMobilePhone: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    var imagePicker: UIImagePickerController!
    var imageChanged = false

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = Constant.UI.GLOBAL_TINT_COLOR
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor()
        ]
        
        imgPhoto.layer.cornerRadius = imgPhoto.bounds.width/2
        imgPhoto.layer.masksToBounds = true
        imgPhoto.layer.borderColor = Constant.UI.COLOR_PINK.CGColor
        imgPhoto.layer.borderWidth = 5
        
        if let user = FUser.currentUser() {
            txtFullName.text = user.name() ?? ""
            txtMobilePhone.text = user.mobilePhone() ?? ""
            txtAddress.text = user.address() ?? ""
            txtEmail.text = user.email() ?? ""
        }
        
        imgPhoto.image = UIImage(named: "icon_user_empty")
        if let image = UIImage.imageFrom(FUser.currentId(), subfolder: "user") {
            imgPhoto.image = image
        }
        else if let userPhotoUrl = FUser.picture(){
            imgPhoto.setImageWithURL(NSURL(string: userPhotoUrl)!, placeholder: UIImage(named: "icon_user_empty")!, completion: { (image, error) in
                if error == nil && image != nil{
                    image!.saveToFile(FUser.currentId(), subfolder: "user")
                }
            })
        }
    }
    
    @IBAction func onChangePhoto(sender: AnyObject) {
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
    
    @IBAction func onChangePassword(sender: AnyObject) {
        let alert = UIAlertController(title: "Reset Password", message: "Are you sure to change your password?", preferredStyle: .Alert)
        let actionOk = UIAlertAction(title: "Yes", style: .Default, handler: { (action) in
            SVProgressHUD.show()
            FIRAuth.auth()!.sendPasswordResetWithEmail(FUser.currentUser()!.email()!, completion: { (error) in
                if error == nil {
                    SVProgressHUD.showSuccessWithStatus("Request sent to your email")
                }
                else {
                    SVProgressHUD.showErrorWithStatus(error!.userInfo[NSLocalizedDescriptionKey] as! String)
                }
            })
        })
        alert.addAction(actionOk)
        let actionCancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(actionCancel)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func onContactUS(sender: AnyObject) {
        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposeViewController.setToRecipients(["admin@tryitat.net"])
        mailComposeViewController.setSubject("Hello")
        mailComposeViewController.setMessageBody("How are you?", isHTML: false)
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Could not send email", preferredStyle: .Alert)
            let actionCancel = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            alert.addAction(actionCancel)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onSave(sender: AnyObject) {
        let user = FUser.currentUser()
        user![Constant.Firebase.User.MOBILEPHONE] = txtMobilePhone.text
        user![Constant.Firebase.User.NAME] = txtFullName.text
        user![Constant.Firebase.User.ADDRESS] = txtAddress.text
        user!.saveInBackground { (error) in
            if self.imageChanged {
                self.uploadImage(self.imgPhoto.image, completion: { (error, imageUrl) in
                    if error == nil, let realImage = imageUrl {
                        user![Constant.Firebase.User.PICTURE] = realImage
                        user!.saveInBackground()
                    }
                })
                self.imgPhoto.image!.saveToFile(FUser.currentId(), subfolder: "user", completion: { (result) in
                    NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.USER_UPDATED, object: nil)
                })
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func uploadImage(picture: UIImage?, completion: ((error: NSError?, imageUrl: String?)->Void)?) {
        let imagePath = FUser.imageNameWithUserId()
        let storageReference = FIRStorage.storage().referenceForURL(Constant.Firebase.FIREBASE_STORAGE).child(imagePath)
        
        if (picture != nil)
        {
            let picData = UIImageJPEGRepresentation(picture!, 0.6)
            storageReference.putData(picData!, metadata: nil) { (metadata, error) in
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

//    func setUserPhoto(image: UIImage) {
//        SVProgressHUD.showProgress(0)
//        let imagePath = FUser.imageNameWithDate()
//        let storageReference = FIRStorage.storage().referenceForURL(Constant.Firebase.FIREBASE_STORAGE).child(imagePath)
//        let picData = UIImageJPEGRepresentation(image, 0.6)
//        image.saveToFile(FUser.currentId(), subfolder: "user")
//        let task:FIRStorageUploadTask = storageReference.putData(picData!, metadata: nil) { (metadata, error) in
//            SVProgressHUD.dismiss()
//            if error == nil {
//                let link = metadata?.downloadURL()?.absoluteString
//                let user = FUser.currentUser()!
//                user[Constant.Firebase.User.PICTURE] = link
//                user.saveInBackground()
//                self.dismissViewControllerAnimated(true, completion: nil)
//            }
//            else {
//            }
//        }
//        task.observeStatus(.Progress, handler: { (snapshot) in
//            if snapshot.progress!.completedUnitCount == snapshot.progress!.totalUnitCount {
//                task.removeAllObservers()
//                SVProgressHUD.dismiss()
//                NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.USER_UPDATED, object: nil)
//            }
//            print("Progress: \(Float(snapshot.progress!.completedUnitCount)/Float(snapshot.progress!.totalUnitCount))")
//            SVProgressHUD.showProgress(Float(snapshot.progress!.completedUnitCount)/Float(snapshot.progress!.totalUnitCount))
//        })
//    }
    
    @IBAction func onLogOut(sender: AnyObject) {
        FIRDatabase.database().reference().removeAllObservers()
        if FUser.logOut() {
            self.dismissViewControllerAnimated(true, completion: nil)
            let appDelegate: AppDelegate? = UIApplication.sharedApplication().delegate as? AppDelegate
            appDelegate!.showWelcome(true)
            NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.SIGN_OUT, object: nil)
        }
    }
    
    @IBAction func onClose(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate{
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.imgPhoto.image = image.squareImage().resizeImage(100)
        imageChanged = true
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
