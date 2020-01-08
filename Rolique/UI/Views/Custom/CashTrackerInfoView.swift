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
  private lazy var cashView = configuredCashView()
  private lazy var cardView = configuredCardView()
  
  override func configure() {
    attachTitleLabel()
    attachCardView()
    attachCashView()
  }
  
  func configure(title: String, cash: Double, card: Double) {
    titleLabel.text = title
    cashView.configure(text: "\(cash) UAH", image: CashType.cash.image)
    cardView.configure(text: "\(card) UAH", image: CashType.card.image)
  }
}

// MARK: - Private
private extension CashTrackerInfoView {
  func configuredCashView() -> CashTypeView {
    let view = CashTypeView()
    view.configure(text: "0 UAH", image: CashType.cash.image)
    
    return view
  }
  
  func configuredCardView() -> CashTypeView {
    let view = CashTypeView()
    view.configure(text: "0 UAH", image: CashType.card.image)

    return view
  }
  
  func configuredTitleLabel() -> UILabel {
    let label = UILabel()
    return label
  }
  
  func attachCashView() {
    addSubview(cashView)
    
    cashView.snp.makeConstraints {
      $0.top.equalTo(cardView.snp.bottom)
      $0.left.right.equalToSuperview()
      $0.height.equalTo(50)
    }
  }
  
  func attachCardView() {
    addSubview(cardView)
    
    cardView.snp.makeConstraints {
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

