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
  static var size: CGSize { CGSize(width: 30, height: 30) }
}

final class CashTypeView: View {
  private lazy var typeImageView = UIImageView()
  private lazy var totalLabel = UILabel()
  
  override func configure() {
    [typeImageView, totalLabel].forEach(addSubview)
    
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

    typeImageView.contentMode = .scaleAspectFit
    typeImageView.tintColor = Colors.imageColor
    totalLabel.textAlignment = .left
  }
  
  func configure(text: String, image: UIImage) {
    typeImageView.image = image.withRenderingMode(.alwaysTemplate)
    totalLabel.text = text
  }
}
