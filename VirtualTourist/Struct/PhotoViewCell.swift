//  PhotoViewCell.swift
//  VirtualTourist
//
//  Created by Abdullah Aldakhiel on 31/01/2019.
//  Copyright © 2019 Abdullah Aldakhiel. All rights reserved.
//

import UIKit

class PhotoViewCell: UICollectionViewCell {
    static let identifier = "PhotoViewCell"
    
    var imageUrl: String = ""
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
}
