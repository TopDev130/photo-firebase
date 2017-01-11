//
//  WebViewController.swift
//  TryItOut
//
//  Created by Harri Westman on 10/10/16.
//
//

import UIKit

class WebViewController: BaseViewController {
    @IBOutlet weak var webView: UIWebView!
    var fileName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.opaque = false
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]

        let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "html")
        do {
            let fileHtml = try NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
            webView.loadHTMLString(fileHtml as String, baseURL: nil)
        }
        catch {
            print(fileName + ".html file doesnt exist")
        }
    }
}
