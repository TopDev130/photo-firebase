//
//  HomeViewController.swift
//  TryItOut
//
//  Created by Harri Westman on 9/30/16.
//
//

import UIKit

class HomeViewController: BaseViewController {
    @IBOutlet weak var tblPost: UITableView!
    var posts = [FPost]()
    var selectedIndex: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = Constant.UI.GLOBAL_TINT_COLOR
        let logo = UIImage(named: "logo_small")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.POST_LOADED, object: nil, queue: nil) { (notification) in
            self.reloadPosts()
        }
    }
    
    func reloadPosts() {
        self.posts = Manager.sharedInstance.posts
        self.tblPost.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("POST_CELL") as! PostTableViewCell
        cell.resetWithPost(self.posts[indexPath.row])
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == selectedIndex {
            return 600
        }
        else {
            return 280
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