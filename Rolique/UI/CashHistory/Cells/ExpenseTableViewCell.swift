//
//  ExpenseTableViewCell.swift
//  Rolique
//
//  Created by Bohdan Savych on 12/9/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

final class ExpenseTableViewCell: TableViewCell {
  private lazy var expenseValueLabel = UILabel()
  private lazy var dateLabel = UILabel()
  private lazy var descriptionLabel = UILabel()
  
  override func configure() {
    attachViews()
    configureViews()
  }
  
  func configure(description: String, value: Double, dateString: String) {
    descriptionLabel.text = description
    expenseValueLabel.text = "\(value) uah"
    dateLabel.text = dateString
  }
}

// MARK: - Private
private extension ExpenseTableViewCell {
  func attachViews() {
    [expenseValueLabel, dateLabel, descriptionLabel].forEach(contentView.addSubview)
    
    descriptionLabel.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(4)
      $0.left.equalToSuperview().inset(16)
      $0.right.equalToSuperview().inset(48)
    }
    
    expenseValueLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(4)
      $0.left.equalTo(descriptionLabel.snp.right).offset(-4)
      $0.right.equalToSuperview().inset(4)
    }
    
    dateLabel.snp.makeConstraints {
      $0.top.equalTo(expenseValueLabel.snp.bottom).offset(-4)
      $0.left.equalTo(descriptionLabel.snp.right).offset(-4)
      $0.right.equalToSuperview().inset(4)
    }
    
  }
  
  func configureViews() {
    
  }
}
