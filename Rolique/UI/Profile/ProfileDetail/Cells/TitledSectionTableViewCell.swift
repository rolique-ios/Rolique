//
//  TitledSectionTableViewCell.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 9/20/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import SnapKit
import Utils

private struct Constants {
  static var defaultOffset: CGFloat { return 20.0 }
  static var littleOffset:CGFloat { return 2.0 }
  static var separatorHeight: CGFloat { return 1.0 }
}

final class TitledSectionTableViewCell: UITableViewCell {
  private lazy var titleLabel = UILabel()
  private lazy var separator = UIView()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.selectionStyle = .none
    
    titleLabel.textColor = .darkGray
    titleLabel.alpha = 0.5
    titleLabel.font = .italicSystemFont(ofSize: 14.0)
    titleLabel.adjustsFontSizeToFitWidth = true
    
    separator.backgroundColor = Colors.Profile.separatorColor
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with title: String) {
    configureViews()
    
    titleLabel.text = title
  }
  
  private func configureViews() {
    [titleLabel, separator].forEach(self.addSubviewAndDisableMaskTranslate)
    
    titleLabel.snp.makeConstraints { maker in
      maker.leading.equalToSuperview().offset(Constants.defaultOffset)
      maker.trailing.equalToSuperview().offset(-Constants.defaultOffset)
      maker.bottom.equalToSuperview().offset(-Constants.littleOffset)
    }
    separator.snp.makeConstraints { maker in
      maker.top.equalToSuperview()
      maker.leading.equalToSuperview().offset(Constants.defaultOffset)
      maker.trailing.equalToSuperview().offset(-Constants.defaultOffset)
      maker.height.equalTo(Constants.separatorHeight)
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    titleLabel.removeFromSuperview()
    separator.removeFromSuperview()
  }
}
