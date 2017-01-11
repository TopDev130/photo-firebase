//
//  PostCollectionViewCell.swift
//  TryItOut
//
//  Created by Harri Westman on 10/5/16.
//
//

import UIKit

class PostCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgView: CacheImageView!
    var post: FPost!

    func resetWithPost(post: FPost) {
        self.post = post
        if post.image != nil {
            imgView.image = post.image
        }
        else
            if post.photoUrl != nil{
                if let image = UIImage.imageFrom(post.objectId(), subfolder: "post") {
                    imgView.image = image
                }
                else {
                    imgView.setImageWithURL(NSURL(string: post.photoUrl!)!, placeholder: UIImage(named: "no_image")!, completion: { (image, error) in
                        if error == nil && image != nil{
                            image!.saveToFile(post.objectId(), subfolder: "post")
                        }
                    })
                }
        }

    }
}
