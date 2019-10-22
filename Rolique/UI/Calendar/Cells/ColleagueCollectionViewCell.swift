//
//  ColleagueCollectionViewCell.swift
//  Rolique
//
//  Created by Maks on 10/22/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import SnapKit
import Utils

private struct Constants {
  static var userImageSize: CGFloat { return 56 }
  static var littleOffset: CGFloat { return 2 }
  static var separatorWidth: CGFloat { return 10 }
  static var separatorHeight: CGFloat { return 1.0 }
}

final class ColleagueCollectionViewCell: UICollectionViewCell {
  private lazy var userImageView = UIImageView()
  private lazy var nameLabel = UILabel()
  private lazy var separator = UIView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = Colors.secondaryBackgroundColor
    
    nameLabel.textColor = Colors.mainTextColor
    nameLabel.adjustsFontSizeToFitWidth = true
    nameLabel.textAlignment = .center
    
    userImageView.roundCorner(radius: Constants.userImageSize / 2)
    
    separator.backgroundColor = Colors.separatorColor
    
    configureViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with name: String, image: String?) {
    URL(string: image.orEmpty).map(self.userImageView.setImage(with: ))
    nameLabel.text = name
  }
  
  private func configureViews() {
    [nameLabel, userImageView, separator].forEach(self.addSubviewAndDisableMaskTranslate)
    
    userImageView.snp.makeConstraints { maker in
      maker.top.equalToSuperview().offset(Constants.littleOffset)
      maker.size.equalTo(Constants.userImageSize)
      maker.centerX.equalToSuperview()
    }
    
    nameLabel.snp.makeConstraints { maker in
      maker.top.equalTo(userImageView.snp.bottom).offset(Constants.littleOffset)
      maker.left.equalToSuperview().offset(Constants.littleOffset)
      maker.right.bottom.equalToSuperview().offset(-Constants.littleOffset)
    }
    
    separator.snp.makeConstraints { maker in
      maker.bottom.right.equalToSuperview()
      maker.width.equalTo(Constants.separatorWidth)
      maker.height.equalTo(Constants.separatorHeight)
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    userImageView.cancelLoad()
    nameLabel.text = nil
  }
}
