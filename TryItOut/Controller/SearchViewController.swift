//
//  SearchViewController.swift
//  TryItOut
//
//  Created by Harri Westman on 9/30/16.
//
//

import UIKit

class SearchViewController: BaseViewController {
    @IBOutlet weak var collectionPosts: UICollectionView!
    var posts: [FPost]!
    var filterdPosts = [FPost]()
    var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = Constant.UI.GLOBAL_TINT_COLOR
        
        self.searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Start type item or place"
        self.navigationItem.titleView = searchBar
        
        NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.POST_LOADED, object: nil, queue: nil) { (notification) in
            self.reloadPosts()
        }

        resetLayoutForCollectionView()
    }
    
    func reloadPosts() {
        self.posts = Manager.sharedInstance.posts
        updateWithSearchKeyword(nil)
    }
    
    func updateWithSearchKeyword(text: String?) {
        self.filterdPosts.removeAll()
        
        for post in self.posts {
            if Manager.sharedInstance.isNearIn(Double(post.latitude!), longitude: Double(post.longitude!), radiusInMeter: 10000) == true {
                if text != nil && text!.characters.count > 0 {
                    if post.name?.lowercaseString.containsString(text!.lowercaseString) == true ||
                        post.place?.lowercaseString.containsString(text!.lowercaseString) == true {
                        self.filterdPosts.append(post)
                    }
                }
                else {
                    self.filterdPosts.append(post)
                }
            }
        }
        self.collectionPosts.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadPosts()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        resetLayoutForCollectionView()
    }
    
    func resetLayoutForCollectionView() {
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSizeMake(self.view.bounds.width/3, self.view.bounds.width/3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.collectionPosts.setCollectionViewLayout(layout, animated: false)
    }
}

extension SearchViewController: UISearchBarDelegate {//Search
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = true
        updateWithSearchKeyword(searchText)
//        if searchText.characters.count > 0 {
            searchBar.showsCancelButton = true
//        }
//        else {
//            searchBar.showsCancelButton = false
//            searchBar.endEditing(true)
//            searchBar.resignFirstResponder()
//        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) { // called when keyboard search button pressed
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) { // called when cancel button pressed
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
}

extension SearchViewController { //Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! PostDetailViewController
        let indexPath = self.collectionPosts.indexPathsForSelectedItems()![0]
        controller.post = self.filterdPosts[indexPath.row]
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filterdPosts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("POST_COLLECTION_CELL", forIndexPath: indexPath) as! PostCollectionViewCell
        cell.resetWithPost(self.filterdPosts[indexPath.row])
        return cell
    }
}