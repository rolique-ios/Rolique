//
//  CashTypeView.swift
//  Rolique
//
//  Created by Bohdan Savych on 1/8/20.
//  Copyright © 2020 Rolique. All rights reserved.
//

import UIKit
import Utils

private struct Constants {
  static var size: CGSize { CGSize(width: 30, height: 22) }
}

final class PaymentMethodTypeView: View {
  private lazy var typeImageView = UIImageView()
  private lazy var totalLabel = UILabel()
  private lazy var descriptionLabel = UILabel()
  
  override func configure() {
    [typeImageView, totalLabel, descriptionLabel].forEach(addSubview)
    
    typeImageView.snp.makeConstraints {
      $0.size.equalTo(Constants.size)
      $0.left.equalToSuperview().inset(16)
      $0.centerY.equalToSuperview()
    }
    
    totalLabel.snp.makeConstraints {
      $0.left.equalTo(typeImageView.snp.right).offset(16)
      $0.right.equalToSuperview().inset(16)
      $0.centerY.equalToSuperview()
    }
    
    descriptionLabel.snp.makeConstraints {
      $0.top.equalTo(typeImageView.snp.bottom)
      $0.left.equalToSuperview().inset(16)
    }

    typeImageView.contentMode = .scaleAspectFit
    typeImageView.tintColor = Colors.imageColor
    totalLabel.textAlignment = .left
    descriptionLabel.textAlignment = .left
    descriptionLabel.textColor = .lightGray
    descriptionLabel.font = .systemFont(ofSize: 11)
  }
  
  func configure(text: String, description: String, image: UIImage) {
    typeImageView.image = image.withRenderingMode(.alwaysTemplate)
    totalLabel.text = text
    descriptionLabel.text = description.capitalizingFirstLetter()
  }
}
