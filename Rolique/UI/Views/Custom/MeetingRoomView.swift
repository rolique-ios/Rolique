//
//  MeetingRoomView.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/11/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import SnapKit
import Utils

final class MeetingRoomView: UIView {
  private lazy var label = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    configureView()
    configureConstraints()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    configureView()
    configureConstraints()
  }
  
  func configure(with name: String) {
    label.text = name
  }
  
  private func configureView() {
    label.textColor = Colors.mainTextColor
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 20.0)
  }
  
  private func configureConstraints() {
    addSubview(label)
    
    label.snp.makeConstraints { maker in
      maker.edges.equalToSuperview()
    }
  }
}
