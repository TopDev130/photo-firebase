//
//  SignUpViewController.swift
//  TryItOut
//
//  Created by Harri Westman on 9/30/16.
//
//

import UIKit
import SVProgressHUD
import Firebase

class SignUpViewController: BaseViewController {

    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var btnTermsOfUse: UIButton!
    @IBOutlet weak var btnPrivacyPolicy: UIButton!
    @IBOutlet weak var btnAgree: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem()
        
        let attrs = [NSFontAttributeName : UIFont.systemFontOfSize(12.0),
                     NSForegroundColorAttributeName : UIColor.whiteColor(),
                     NSUnderlineStyleAttributeName : 1]
        
        btnTermsOfUse.setAttributedTitle(NSMutableAttributedString(string: "Terms of Use", attributes: attrs), forState: .Normal)
        btnPrivacyPolicy.setAttributedTitle(NSMutableAttributedString(string: ", Privacy Policy ", attributes: attrs), forState: .Normal)
    }
    
    @IBAction func onSignUp(sender: AnyObject) {
        guard btnAgree.selected == true else {
            SVProgressHUD.showErrorWithStatus("You have to agree the terms of use.")
            return
        }
        
        guard txtFirstName.text != "" && txtLastName.text != "" && txtEmail.text != "" && txtPassword.text != "" else {
            SVProgressHUD.showErrorWithStatus("Input your credential, please")
            return
        }
        
        SVProgressHUD.show()
        FUser.createUserWithEmail(txtEmail.text!, password: txtPassword.text!, name: txtFirstName.text! + " " + txtLastName.text! , completion: { (user, error: NSError?) in
            if error == nil {
                SVProgressHUD.dismiss()
                
                self.showTabbar()
                FUser.updateCurrentUser(Constant.Firebase.LoginMethod.LOGIN_EMAIL)
                
                NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.SIGN_IN, object: nil)
            }
            else {
                SVProgressHUD.showErrorWithStatus(error!.localizedDescription)
            }
        })
    }
    
    @IBAction func onSignInFacebook() {
//        SVProgressHUD.show()
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
    
    @IBAction func onAgree(sender: UIButton) {
        btnAgree.selected = !btnAgree.selected
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is WebViewController {
            let controller = segue.destinationViewController as! WebViewController
            if segue.identifier == "sid_termsofuse" {
                controller.fileName = "TermsOfService"
            }
            else {
                controller.fileName = "PrivacyPolicy"
            }
        }
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}