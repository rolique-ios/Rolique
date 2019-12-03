//
//  BookedTimeView.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 12/3/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils
import SnapKit

private struct Constants {
  static var titleLabelInsets: UIEdgeInsets { return UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0) }
}

final class BookedTimeView: UIView {
  private lazy var titleLabel = LabelWithInsets(insets: Constants.titleLabelInsets)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }
  
  func update(with title: String?) {
    titleLabel.text = title
  }
  
  private func initialize() {
    backgroundColor = Colors.Colleagues.lightBlue
    self.roundCorner(radius: 5.0)
    
    titleLabel.textColor = .white
    titleLabel.font = .systemFont(ofSize: 14.0)
    titleLabel.numberOfLines = 0
    titleLabel.adjustsFontSizeToFitWidth = true
    titleLabel.minimumScaleFactor = 0.5
    
    configureConstraints()
  }

  private func configureConstraints() {
    [titleLabel].forEach(addSubview)
    
    titleLabel.snp.makeConstraints { maker in
      maker.edges.equalToSuperview()
    }
  }
}
