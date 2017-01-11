//
//  PostDetailViewController.swift
//  TryItOut
//
//  Created by Harri Westman on 10/7/16.
//
//

import UIKit

class PostDetailViewController: UIViewController {
    @IBOutlet weak var tblPost: UITableView!
    
    var post: FPost!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "logo_small")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        self.tblPost.reloadData()
    }
}


extension PostDetailViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.post == nil {
            return 0
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("POST_CELL") as! PostTableViewCell
        cell.resetWithPost(self.post)
        cell.selectionStyle = .None
        return cell
    }
}

extension PostDetailViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 600
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}