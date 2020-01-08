//
//  CashTypeTableViewCell.swift
//  Rolique
//
//  Created by Bohdan Savych on 12/6/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

private struct Constants {
  static var size: CGSize { CGSize(width: 30, height: 30) }
}

final class CashTypeTableViewCell: TableViewCell {
  private(set) lazy var cashTypeView = CashTypeView()
  
  override func configure() {
    [cashTypeView].forEach(contentView.addSubview)

    cashTypeView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
}
