//
//  SignInViewController.swift
//  TryItOut
//
//  Created by Harri Westman on 9/30/16.
//
//

import UIKit
import SVProgressHUD
import Firebase

class SignInViewController: BaseViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem()
    }
    
    @IBAction func onSignIn(sender: AnyObject) {
        guard txtEmail.text != "" && txtPassword.text != "" else {
            SVProgressHUD.showErrorWithStatus("Input your credential, please")
            return
        }
        
        SVProgressHUD.show()
        FUser.signInWithEmail(txtEmail.text!, password: txtPassword.text!) { (user, error) in
            if error == nil {
                SVProgressHUD.dismiss()
                
                self.showTabbar()
                FUser.updateCurrentUser(Constant.Firebase.LoginMethod.LOGIN_EMAIL)
                NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.SIGN_IN, object: nil)
            }
            else {
                SVProgressHUD.showErrorWithStatus(error!.localizedDescription)
            }
        }
    }
    
    @IBAction func onForgotPassword(sender: AnyObject) {
        let alert = UIAlertController(title: "Reset Password", message: "Please input your email address.", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler(nil);
        let actionOk = UIAlertAction(title: "Ok", style: .Default, handler: { (action) in
            let textField = alert.textFields![0]
            let email = textField.text
            if email == nil {
                SVProgressHUD.showErrorWithStatus("Please type your email address")
            }
            else {
                SVProgressHUD.show()
                FIRAuth.auth()!.sendPasswordResetWithEmail(email!, completion: { (error) in
                    if error == nil {
                        SVProgressHUD.showSuccessWithStatus("Request sent to your email")
                    }
                    else {
                        SVProgressHUD.showErrorWithStatus(error!.userInfo[NSLocalizedDescriptionKey] as! String)
                    }
                })
            }
        })
        alert.addAction(actionOk)
        let actionCancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(actionCancel)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func onSignInFacebook() {
        ///SVProgressHUD.show()
        FUser.signInWithFacebook(self) { (user, error) in
            if error == nil {
                SVProgressHUD.dismiss()
                if user != nil {
                    
                    self.showTabbar()
                    FUser.updateCurrentUser(Constant.Firebase.LoginMethod.LOGIN_FACEBOOK)
                    NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.SIGN_IN, object: nil)
                }
            }
            else {
                SVProgressHUD.showErrorWithStatus(error!.description)
            }
        }
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}