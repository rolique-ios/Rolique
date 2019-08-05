//
//  UserCollectionViewCell.swift
//  PeopleWidget
//
//  Created by Bohdan Savych on 8/2/19.
//  Copyright © 2019 Bohdan Savych. All rights reserved.
//

import UIKit

final class UserCollectionViewCell: UICollectionViewCell {
  struct Constants {
    static var imageHorizontal: CGFloat { return 8 } 
  }
  
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var label: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    imageView.contentMode = .scaleAspectFill
    imageView.backgroundColor = UIColor(red: 244/256, green: 244/256, blue: 244/256, alpha: 0.7)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    imageView.cancelLoad()
  }
  
  func configure(url: URL?, name: String, imageCornerRadius: CGFloat) {
    imageView.layer.cornerRadius = imageCornerRadius
    imageView.layer.masksToBounds = true
    label.text = name
    imageView.setImage(url: url)
  }
  
  func configure(image: UIImage?, name: String, imageCornerRadius: CGFloat) {
    imageView.layer.cornerRadius = imageCornerRadius
    imageView.layer.masksToBounds = true
    imageView.image = image
    label.text = name
  }
}
