//
//  NotificationReminderView.swift
//  ContactKeeper
//
//  Created by Bohdan Savych on 3/10/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import UIKit
import Utils
import SnapKit

private struct Constants {
  static var imageSize: CGSize { return CGSize(width: 40, height: 40) }
  static var defaultOffset: CGFloat { return 8 }
}

public final class NotificationReminderView: UIView {
  private lazy var contentView = UIImageView()
  private lazy var titleLabel = UILabel()
  private lazy var imageView = UIImageView()
  private lazy var button = UIButton()
  
  public var onTap: (() -> Void)?
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }
  
  private func initialize() {
    configureConstraints()
    configureUI()
  }
  
  private func configureConstraints() {
    [contentView].forEach(self.addSubviewAndDisableMaskTranslate)
    [titleLabel, imageView, button].forEach(self.contentView.addSubviewAndDisableMaskTranslate)
    
    contentView.snp.makeConstraints { maker in
      maker.left.equalToSuperview().offset(Constants.defaultOffset)
      maker.right.equalToSuperview().offset(-Constants.defaultOffset)
      maker.top.equalToSuperview()
      maker.bottom.equalToSuperview()
    }
    
    button.snp.makeConstraints { maker in
      maker.edges.equalToSuperview()
    }
    
    imageView.snp.makeConstraints { maker in
      maker.size.equalTo(Constants.imageSize)
      maker.left.equalTo(Constants.defaultOffset)
      maker.centerY.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints { maker in
      maker.left.equalTo(imageView.snp.right).offset(Constants.defaultOffset)
      maker.right.equalTo(-Constants.defaultOffset)
      maker.top.equalToSuperview()
      maker.bottom.equalToSuperview()
    }
  }
  
  private func configureUI() {
    backgroundColor = .clear
    
    contentView.backgroundColor = .white
    contentView.layer.cornerRadius = 8
    contentView.layer.shadowColor = UIColor(red: 0.21, green: 0.22, blue: 0.3, alpha: 0.15).cgColor
    contentView.layer.shadowOpacity = 1
    contentView.layer.shadowRadius = 7
    contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
    contentView.isUserInteractionEnabled = true
    
    imageView.image = R.image.logo()
    imageView.contentMode = .scaleAspectFill
    imageView.roundCorner(radius: 2)
    
    titleLabel.textColor = UIColor(hexString: "#35394B")
    titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    titleLabel.lineBreakMode = .byWordWrapping
    titleLabel.numberOfLines = 0
    
    button.backgroundColor = .clear
    button.setTitle("", for: .normal)
    button.addTarget(self, action: #selector(contentTouchUpInside(sender:)), for: .touchUpInside)
  }
  
  @objc func contentTouchUpInside(sender: UIButton) {
    onTap?()
  }
  
  public func configure(text: String) {
    titleLabel.text = text
  }
}
