//
//  CashTrackerInfoView.swift
//  Rolique
//
//  Created by Bohdan Savych on 1/8/20.
//  Copyright © 2020 Rolique. All rights reserved.
//

import UIKit


final class CashTrackerInfoView: View {
  private lazy var titleLabel = configuredTitleLabel()
  private lazy var paymentMethodView = configuredPaymentMethodView()
  
  override func configure() {
    attachTitleLabel()
    attachPaymentMethodView()
  }
  
  func configure(title: String, description: String, value: Double, image: UIImage) {
    titleLabel.text = title
    paymentMethodView.configure(text: "\(value) UAH", description: description, image: image)
  }
}

// MARK: - Private
private extension CashTrackerInfoView {
  func configuredPaymentMethodView() -> PaymentMethodTypeView {
    let view = PaymentMethodTypeView()
    view.configure(text: "0 UAH", description: "", image: PaymentMethodType.cash.image)
    
    return view
  }
  
  func configuredTitleLabel() -> UILabel {
    let label = UILabel()
    return label
  }
  
  func attachPaymentMethodView() {
    addSubview(paymentMethodView)
    
    paymentMethodView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom)
      $0.left.right.equalToSuperview()
      $0.height.equalTo(50)
    }
  }
  
  func attachTitleLabel() {
    addSubview(titleLabel)

    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(4)
      $0.left.right.equalToSuperview().inset(8)
    }
  }
}

