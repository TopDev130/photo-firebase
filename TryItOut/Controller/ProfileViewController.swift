//
//  ProfileViewController.swift
//  TryItOut
//
//  Created by Harri Westman on 9/30/16.
//
//

import UIKit
import SVProgressHUD

class ProfileViewController: BaseViewController {
    @IBOutlet weak var tblView: UITableView!
    var posts = [FPost]()
    var selectedIndex: Int = -1
    
    @IBOutlet weak var imgPhoto: CacheImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = Constant.UI.GLOBAL_TINT_COLOR
        let logo = UIImage(named: "logo_small")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView

        SVProgressHUD.show()
        FPostHelper.loadMyPost { (myposts) in
            SVProgressHUD.dismiss()
            Manager.sharedInstance.myPosts = myposts
            self.reloadMyPosts()
        }
        
        imgPhoto.layer.cornerRadius = imgPhoto.bounds.width/2
        imgPhoto.layer.masksToBounds = true
        imgPhoto.layer.borderColor = Constant.UI.COLOR_PINK.CGColor
        imgPhoto.layer.borderWidth = 5

        if let user = FUser.currentUser() {
            lblName.text = user.name() ?? ""
            lblAddress.text = user.address() ?? ""
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
        
        NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.POST_LOADED, object: nil, queue: nil) { (notification) in
            self.reloadMyPosts()
        }
    }
    
    func reloadMyPosts() {
        self.posts = Manager.sharedInstance.myPosts
        self.tblView.reloadData()
    }
    
    @IBAction func onSignOut(sender: AnyObject) {
        if FUser.logOut() {
            let appDelegate: AppDelegate? = UIApplication.sharedApplication().delegate as? AppDelegate
            appDelegate!.showWelcome(true)
            
            NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.SIGN_OUT, object: nil)
        }
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("POST_CELL") as! MyPostTableViewCell
        cell.resetWithPost(self.posts[indexPath.row])
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == selectedIndex {
            return 540
        }
        else {
            return 232
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == self.selectedIndex {
            self.selectedIndex = -1
        }
        else
        {
            self.selectedIndex = indexPath.row
        }
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
    }
}