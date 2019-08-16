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
  private lazy var containerView = ShadowView()
  private lazy var nameLabel = UILabel()
  private lazy var titleLabel = UILabel()
  private lazy var phoneImage = UIImageView()
  
  weak var delegate: ColleaguesTableViewCellDelegate?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.selectionStyle = .none
    
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.backgroundColor = .white
    
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    nameLabel.textColor = UIColor.black
    
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.textColor = UIColor.lightGray
    titleLabel.font = UIFont.italicSystemFont(ofSize: 14.0)
    
    phoneImage.translatesAutoresizingMaskIntoConstraints = false
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with name: String, title: String, isButtonEnabled: Bool, isMe: Bool) {
    configureViews()
    
    nameLabel.text = name
    
    if !title.isEmpty {
      titleLabel.text = title
    } else {
      titleLabel.removeFromSuperview()
      nameLabel.snp.remakeConstraints { maker in
        maker.leading.equalTo(containerView).offset(15)
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
    
    containerView.snp.makeConstraints { maker in
      maker.edges.equalTo(self).inset(UIEdgeInsets(top: 10, left: 10, bottom: 15, right: 10))
    }
    
    titleLabel.snp.makeConstraints { maker in
      maker.leading.equalTo(containerView).offset(15)
      maker.bottom.equalTo(containerView).offset(-15)
    }
    
    nameLabel.snp.makeConstraints { maker in
      maker.leading.equalTo(containerView).offset(15)
      maker.top.equalTo(containerView).offset(15)
    }
    
    phoneImage.snp.makeConstraints { maker in
      maker.trailing.equalTo(containerView).offset(-15)
      maker.centerY.equalTo(containerView)
      maker.leading.equalTo(nameLabel.snp.trailing)
      maker.height.equalTo(30)
      maker.width.equalTo(30)
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
