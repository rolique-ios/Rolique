//
//  ColleaguesTableViewCell.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/15/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import SnapKit
import Utils

protocol ColleaguesTableViewCellDelegate: class {
  func touchPhone(_ cell: ColleaguesTableViewCell)
}

class ColleaguesTableViewCell: UITableViewCell {
  private struct Constants {
    static var defaultOffset: CGFloat { return 15.0 }
    static var littleOffset: CGFloat { return 5.0 }
    static var containerViewInsets: UIEdgeInsets { return UIEdgeInsets(top: 10, left: 10, bottom: 15, right: 10) }
    static var phoneImageSize: CGFloat { return 30.0 }
  }
  private lazy var containerView = UIView()
  private lazy var nameLabel = UILabel()
  private lazy var titleLabel = UILabel()
  private lazy var todayStatusLabel = UILabel()
  private lazy var phoneImage = UIImageView()
  
  weak var delegate: ColleaguesTableViewCellDelegate?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.backgroundColor = .clear
    self.selectionStyle = .none
    
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.backgroundColor = .white
    
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    nameLabel.textColor = UIColor.black
    
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.textColor = UIColor.lightGray
    titleLabel.font = UIFont.italicSystemFont(ofSize: 14.0)
    
    todayStatusLabel.translatesAutoresizingMaskIntoConstraints = false
    todayStatusLabel.textColor = .orange
    todayStatusLabel.layer.borderWidth = 1.0
     todayStatusLabel.layer.borderColor = UIColor.orange.cgColor
    todayStatusLabel.layer.cornerRadius = 4
    todayStatusLabel.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
    
    phoneImage.translatesAutoresizingMaskIntoConstraints = false
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with name: String, todayStatus: String?, title: String, isButtonEnabled: Bool, isMe: Bool) {
    configureViews()
    
    nameLabel.text = name
    if let todayStatus = todayStatus, !todayStatus.isEmpty {
      todayStatusLabel.isHidden = false
      todayStatusLabel.text = " " + todayStatus + " "
    } else {
      todayStatusLabel.isHidden = true
      todayStatusLabel.text = nil
    }
    
    if !title.isEmpty {
      titleLabel.text = title
    } else {
      titleLabel.removeFromSuperview()
      nameLabel.snp.remakeConstraints { maker in
        maker.leading.equalTo(containerView).offset(Constants.defaultOffset)
        maker.centerY.equalTo(containerView)
      }
    }
    
    if isMe {
      phoneImage.isHidden = true
    } else {
      phoneImage.isHidden = false
      let image = Images.Colleagues.phone
      if !isButtonEnabled {
        phoneImage.image = image.withRenderingMode(.alwaysTemplate)
        phoneImage.tintColor = .lightGray
      } else {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(touchEvent))
        phoneImage.addGestureRecognizer(gesture)
        phoneImage.isUserInteractionEnabled = true
        phoneImage.image = image
      }
    }
  }
  
  private func configureViews() {
    self.addSubview(containerView)
    containerView.addSubview(nameLabel)
    containerView.addSubview(titleLabel)
    containerView.addSubview(phoneImage)
    containerView.addSubview(todayStatusLabel)
    
    containerView.snp.makeConstraints { maker in
      maker.edges.equalTo(self).inset(Constants.containerViewInsets)
    }
    
    titleLabel.snp.makeConstraints { maker in
      maker.leading.equalTo(containerView).offset(Constants.defaultOffset)
      maker.bottom.equalTo(containerView).offset(-Constants.defaultOffset)
    }
    
    nameLabel.snp.makeConstraints { maker in
      maker.leading.equalTo(containerView).offset(Constants.defaultOffset)
      maker.top.equalTo(containerView).offset(Constants.defaultOffset)
    }
    
    todayStatusLabel.snp.makeConstraints { maker in
      maker.leading.equalTo(nameLabel.snp.trailing).offset(Constants.littleOffset)
      maker.leading.equalTo(titleLabel.snp.trailing).offset(Constants.littleOffset)
      maker.centerY.equalTo(phoneImage)
      maker.trailing.equalTo(phoneImage.snp.leading).offset(-Constants.littleOffset)
      
    }
    
    phoneImage.snp.makeConstraints { maker in
      maker.trailing.equalTo(containerView).offset(-Constants.defaultOffset)
      maker.centerY.equalTo(containerView)
      maker.size.equalTo(Constants.phoneImageSize)
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    containerView.removeFromSuperview()
    nameLabel.removeFromSuperview()
    titleLabel.removeFromSuperview()
    phoneImage.removeFromSuperview()
  }
  
  @objc func touchEvent() {
    delegate?.touchPhone(self)
  }
}
