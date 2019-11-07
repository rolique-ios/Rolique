//
//  MoreTableViewCell.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/7/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import SnapKit
import Utils

private struct Constants {
  static var smallerOffset: CGFloat { return 15.0 }
  static var offset: CGFloat { return 20.0 }
  static var iconSize: CGFloat { return 30.0 }
}

class MoreTableViewCell: UITableViewCell {
  private lazy var iconImageView = UIImageView()
  private lazy var titleLabel = UILabel()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  
    self.backgroundColor = Colors.mainBackgroundColor
    self.selectionStyle = .none
    self.accessoryType = .disclosureIndicator
    
    configureViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with title: String, icon: UIImage) {
    titleLabel.text = title
    iconImageView.image = icon
  }
  
  private func configureViews() {
    [iconImageView, titleLabel].forEach(self.addSubviewAndDisableMaskTranslate)
    
    iconImageView.snp.makeConstraints { maker in
      maker.centerY.equalToSuperview()
      maker.left.equalToSuperview().offset(Constants.offset)
      maker.size.equalTo(Constants.iconSize)
    }
    
    titleLabel.snp.makeConstraints { maker in
      maker.left.equalTo(iconImageView.snp.right).offset(Constants.smallerOffset)
      maker.centerY.equalToSuperview()
      maker.right.equalToSuperview().offset(-Constants.offset)
    }
  }
}
