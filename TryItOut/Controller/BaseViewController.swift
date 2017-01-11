//
//  BaseViewController.swift
//  TryItOut
//
//  Created by Harri Westman on 9/30/16.
//
//

import UIKit

class BaseViewController: UIViewController {
    @IBOutlet internal var backButton: UIBarButtonItem!
    @IBInspectable var hideNavigationBar: Bool = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if hideNavigationBar {
            self.navigationController?.navigationBarHidden = true
        }
        else {
            self.navigationController?.navigationBarHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (backButton != nil) {
            backButton.target = self
            backButton.action = #selector(BaseViewController.onBack(_:))
        }
        
        if hideNavigationBar {
            self.navigationController?.navigationBarHidden = true
        }
        else {
            self.navigationController?.navigationBarHidden = false
        }
        
        let settingsButton = UIBarButtonItem(image: UIImage(named: "icon_settings"), style: .Done, target: self, action: #selector(BaseViewController.onSettings))
        self.navigationItem.rightBarButtonItem = settingsButton
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    func onSettings() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsVewController = storyboard.instantiateViewControllerWithIdentifier("sid_settings") as! UINavigationController
        self.presentViewController(settingsVewController, animated: true, completion: nil)
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func showTabbar() {
        let appDelegate: AppDelegate? = UIApplication.sharedApplication().delegate as? AppDelegate
        appDelegate!.showTabBar(true)
    }
}
