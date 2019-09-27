//
//  MajorTableViewCell.swift
//  Rolique
//
//  Created by Maks on 9/22/19.
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

final class MajorTableViewCell: UITableViewCell {
  private lazy var titleLabel = UILabel()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.backgroundColor = .secondaryBackgroundColor()
    self.selectionStyle = .none
    
    titleLabel.textColor = .mainTextColor()
    titleLabel.font = .boldSystemFont(ofSize: 30.0)
    titleLabel.adjustsFontSizeToFitWidth = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with title: String) {
    configureViews()
    
    titleLabel.text = title
  }
  
  private func configureViews() {
    [titleLabel].forEach(self.addSubviewAndDisableMaskTranslate)
    
    titleLabel.snp.makeConstraints { maker in
      maker.leading.equalToSuperview().offset(Constants.defaultOffset)
      maker.trailing.equalToSuperview().offset(-Constants.defaultOffset)
      maker.bottom.equalToSuperview().offset(-Constants.littleOffset)
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    titleLabel.removeFromSuperview()
  }
}
