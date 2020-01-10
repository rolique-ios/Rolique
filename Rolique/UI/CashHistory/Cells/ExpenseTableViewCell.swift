//
//  ExpenseTableViewCell.swift
//  Rolique
//
//  Created by Bohdan Savych on 12/9/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

final class ExpenseTableViewCell: TableViewCell {
  private lazy var expenseValueLabel = UILabel()
  private lazy var dateLabel = UILabel()
  private lazy var descriptionLabel = UILabel()
  
  override func configure() {
    attachViews()
    configureViews()
  }
  
  func configure(description: String, value: Double, dateString: String) {
    let color = value > 0 ? UIColor.systemGreen : UIColor.systemRed
    let attributedString = NSMutableAttributedString(string: "\(value) uah", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
    attributedString.addAttributes([NSAttributedString.Key.foregroundColor: color], range: NSRange(location: 0, length: "\(value)".count))
    
    descriptionLabel.text = description
    expenseValueLabel.attributedText = attributedString
    dateLabel.text = dateString
  }
}

// MARK: - Static
extension ExpenseTableViewCell {
  static func height(for text: String, width: CGFloat) -> CGFloat {
    let height = text.height(withConstrainedWidth: width - 116 - 16, font: .systemFont(ofSize: 15))
    
    return height + 12 + 12
  }
}

// MARK: - Private
private extension ExpenseTableViewCell {
  func attachViews() {
    [expenseValueLabel, dateLabel, descriptionLabel].forEach(contentView.addSubview)
    
    descriptionLabel.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(12)
      $0.left.equalToSuperview().inset(16)
      $0.right.equalToSuperview().inset(116)
    }
    
    expenseValueLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(4)
      $0.left.equalTo(descriptionLabel.snp.right).offset(4)
      $0.right.equalToSuperview().inset(4)
    }
    
    dateLabel.snp.makeConstraints {
      $0.top.equalTo(expenseValueLabel.snp.bottom).offset(4)
      $0.left.equalTo(descriptionLabel.snp.right).offset(2)
      $0.right.equalToSuperview().inset(2)
    }
    
  }
  
  func configureViews() {
    descriptionLabel.numberOfLines = 0
    descriptionLabel.lineBreakMode = .byWordWrapping
    descriptionLabel.font = .systemFont(ofSize: 15)
    
    dateLabel.font = .systemFont(ofSize: 10)
    expenseValueLabel.font = .systemFont(ofSize: 13)
    expenseValueLabel.adjustsFontSizeToFitWidth = true
    expenseValueLabel.minimumScaleFactor = 0.5
  }
}
