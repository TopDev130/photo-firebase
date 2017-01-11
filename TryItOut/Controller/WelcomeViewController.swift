//
//  WelcomeViewController.swift
//  TryItOut
//
//  Created by Harri Westman on 9/30/16.
//
//

import UIKit

class WelcomeViewController: BaseViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var vwDemo: UIView!
    @IBOutlet weak var lblExplain: UILabel!
    @IBOutlet weak var btnTry: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblExplain.text = "Help others find New Delicious and tasty food, you tried"
        scrollView.delegate = self
        navigationController?.navigationItem.rightBarButtonItem = nil
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if Manager.sharedInstance.isNotFirstLaunch == false {
            Manager.sharedInstance.isNotFirstLaunch = true
            initGuide()
            showGuide(true, animated: true)
        }
    }
}

extension WelcomeViewController: UIScrollViewDelegate { //Guide View
    func showGuide(show: Bool, animated: Bool) {
        var duration = 0.3
        if animated == false {
            duration = 0.0
        }
        
        if show {
            vwDemo.alpha = 0.0
        }
        else {
            vwDemo.alpha = 1.0
        }
        
        UIView.animateWithDuration(duration) { 
            self.vwDemo.alpha = 1.0 - self.vwDemo.alpha
        }
    }
    
    @IBAction func onTryIt(sender: AnyObject) {
        showGuide(false, animated: true)
    }
    
    func initGuide() {
        self.view.layoutSubviews()
        
        let width = scrollView.bounds.size.width
        let height = scrollView.bounds.size.height
        for i in 0..<3 {
            let imageView = UIImageView(image: UIImage(named: "welcome"+"\(i+1)"))
            imageView.frame = CGRectMake(CGFloat(i)*width, 0, width, height)
            imageView.contentMode = .ScaleAspectFill
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentSize = CGSizeMake(scrollView.bounds.width*3, scrollView.bounds.height)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        pageControl.currentPage = Int((scrollView.contentOffset.x + 1.0) / scrollView.bounds.size.width)
        if pageControl.currentPage == 0 {
            lblExplain.text = "Help others find New Delicious\n and tasty food, you tried"
        }
        else if pageControl.currentPage == 1 {
            lblExplain.text = "Help other find New Amazing \n Item you tried"
        }
        else if pageControl.currentPage == 2 {
            lblExplain.text = "Explore around what others tried"
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let realoffset: CGFloat = CGFloat(Int(scrollView.contentOffset.x)%Int(scrollView.bounds.width))
        lblExplain.alpha = fabs(realoffset - scrollView.bounds.width)/(scrollView.bounds.width/2)
        
        let offset = scrollView.contentOffset.x - scrollView.bounds.size.width
        if offset > 0 {
            btnTry.alpha = offset/scrollView.bounds.size.width
            pageControl.alpha = 1 - offset/scrollView.bounds.size.width
        }
    }
}
